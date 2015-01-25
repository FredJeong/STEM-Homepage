<!-- #include virtual = common/dbcon.asp -->
<%
Dim Writer,Page,Search,SearchStr,UserIdx
Dim Idx,Title,Content,Pass,Ref,ReLevel
Dim Sql,ObjCmd,Wip,UploadForm,Result,serboardsort
Dim FileName(1),i,Rs
Dim BBsCode,strLocation

WIP=Request.ServerVariables("REMOTE_ADDR")

Server.ScriptTimeOut=7200
set uploadform=server.CreateObject("DEXT.FileUpload")
uploadform.DefaultPath=Server.MapPath("/upload/board/")

BBsCode=Cint(UploadForm("bbscode"))
Call HK_BBSSetup(BBsCode)
BBsViewModeChk("reply")
BbsAdminChk()

prePage=UploadForm("prePage")
Page=UploadForm("page")
storeidx=UploadForm("storeidx")
serboardsort=UploadForm("serboardsort")
Search=UploadForm("Search")
SearchStr=UploadForm("SearchStr")
Writer=ReplaceNoHtml(UploadForm("Writer"))
Title=ReplaceNoHtml(UploadForm("title"))
Email=ReplaceNoHtml(UploadForm("Email"))
Content = Replace(UploadForm("content"),"http://"&Request.Servervariables("Server_name")&"/","/")
Pass=UploadForm("Pass")
Idx=UploadForm("idx")
Ref=UploadForm("Ref")
ReLevel=UploadForm("ReLevel")
UserIdx=UploadForm("UserIdx")

IF UserIdx="" Then UserIdx=null
IF Pass="" Then Pass=null

Sql="Select Top 1 BoardSort FROM bbslist Where Ref="&Ref&" AND ReLevel='A'"
Set Rs=DBcon.Execute(Sql)
BoardSort=Rs("boardSort")

Dim MaxReLevelRec,MaxReLevel
Sql="Select Top 1 ReLevel From bbslist Where ref="&Ref&" And ReLevel Like '"&ReLevel&"_' Order By ReLevel DESC"
Set MaxReLevelRec=DBcon.Execute(Sql)

IF MaxReLevelRec.Eof Then
	MaxReLevel = ReLevel&"A"
Else
	MaxReLevel = ReLevel&Chr(ASC(Right(MaxReLevelRec(0),1))+1)
End IF

Set MaxReLevelRec=Nothing

Sql="INSERT INTO bbslist(email,boardsort,writer,Title,Content,wip,regdate,boardidx,useridx,pwd,ref,reLevel) "
Sql = Sql & "VALUES(?, ?, ?, ?, ?, ?, Getdate() ,?,?,?,?,?)"

Set objCmd = Server.CreateObject("ADODB.Command")
With objCmd
	.ActiveConnection = DBcon
	.CommandType = adCmdText
	.CommandText = Sql
	'.Prepared = True

	.Parameters.Append .CreateParameter("@Email", adVarWChar, adParamInput, 100, Email)
	.Parameters.Append .CreateParameter("@BoardSort", adInteger, adParamInput, 4, BoardSort)
	.Parameters.Append .CreateParameter("@Writer", adVarWChar, adParamInput, 20, Writer)
	.Parameters.Append .CreateParameter("@title", adVarWChar, adParamInput, 100, title)
	.Parameters.Append .CreateParameter("@content", adVarWChar, adParamInput, 2147483647, content)
	.Parameters.Append .CreateParameter("@Wip", adVarChar, adParamInput, 50, WIP)
	.Parameters.Append .CreateParameter("@BoardIdx", adInteger, adParamInput, 4, BBsCode)
	.Parameters.Append .CreateParameter("@UserIdx", adInteger, adParamInput, 4, UserIdx)
	.Parameters.Append .CreateParameter("@Pwd", adVarWChar, adParamInput, 15, Pass)
	.Parameters.Append .CreateParameter("@Ref", adInteger, adParamInput, 4, Ref)
	.Parameters.Append .CreateParameter("@ReLevel", adVarChar, adParamInput, 50, MaxReLevel)
	.Execute,,adExecuteNoRecords

End With
Set objCmd = Nothing

Sql="Select Max(Idx) From BBsList"
MaxIdx=DBcon.Execute(Sql)
bIdx=MaxIdx(0)

'====================첨부파일 업로드 작업==========================================================
For i=1 To UploadForm("files").count
	IF UploadForm("files")(i)<>"" Then 
		Filenames=ImgSaves(UploadForm("files")(i),uploadform.defaultpath,30720000)
		IF Filenames=False Then Result=1

		IF Result=1 Then
			Set UploadForm=Nothing
			DBcon.Close
			Set DBcon=Nothing
			Response.Write ExecJavaAlert("업로드 허용용량(30M)을 초과하여 업로드를 실패하였습니다.",0)
			Response.End
		Else
			Sql="INSERT INTO BBSData(bidx,filenames,regdate) values("&bIdx&",'"&Filenames&"',getdate())"
			DBcon.Execute Sql
		End IF
	End IF
Next
'===============================================================================================

DBcon.Close
Set DBcon=Nothing

strLocation=prePage&"?page="&Page&"&&storeidx="&storeidx&"&serboardsort="&serboardsort&"&Search="&Search&"&SearchStr="&SearchStr
Response.Write ExecJavaAlert("게시물이 등록 되었습니다.",2)
%>