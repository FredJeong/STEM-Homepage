<!-- #include virtual = common/dbcon.asp -->
<%
Dim Writer,Page,UserIdx,Search,SearchStr,BoardSort
Dim Idx,Sort,Title,Content,Pass,publicYN,AlertTag,imgName(0),imgDel_Chk(0)
Dim Sql,ObjCmd,Wip,UploadForm,Result
Dim BBsCode,strLocation,i,ReLevel

Session.Contents.Remove("boardPass")
WIP=Request.ServerVariables("REMOTE_ADDR")

Server.ScriptTimeOut=7200
set uploadform=server.CreateObject("DEXT.FileUpload")
uploadform.DefaultPath=Server.MapPath("/upload/board/")

prePage=UploadForm("prePage")
BBsCode=Cint(UploadForm("bbscode"))
Call HK_BBSSetup(BBsCode)
BBsViewModeChk("write")
BbsAdminChk()

BoardSort=ChangeNull(UploadForm("BoardSort"))
ReLevel=UploadForm("ReLevel")
storeidx=UploadForm("storeidx")
serboardsort=UploadForm("serboardsort")
Search=UploadForm("Search")
Searchstr=UploadForm("Searchstr")
Page=UploadForm("page")
Writer=ReplaceNoHtml(UploadForm("Writer"))
Title=ReplaceNoHtml(UploadForm("title"))
Email=ReplaceNoHtml(UploadForm("Email"))
Content = Replace(UploadForm("content"),"http://"&Request.Servervariables("Server_name")&"/","/")
Pass=UploadForm("Pass")
Idx=UploadForm("idx")
Sort=UploadForm("sort")
UserIdx=UploadForm("useridx")
imgDel_Chk(0)=UploadForm("imgDel_Chk")
imgName(0)=UploadForm("imgname")
publicYN=spaceToZero(UploadForm("publicYN"))

IF storeidx="" Then storeidx=null
IF UserIdx="" Then UserIdx=null
IF Pass="" Then Pass=Null

Dim ThumbFileName,tmpFileName
For i=1 To UploadForm("imgfiles").count
	IF imgDel_Chk(i-1)<>"" And imgName(i-1)<>"" Then
		ImgDelete imgName(i-1),UploadForm.DefaultPath
		ImgDelete getImageThumbFilename(imgName(i-1)),UploadForm.DefaultPath
	End IF

	IF imgDel_Chk(i-1)<>"" Or Sort="" Then 
		IF UploadForm("imgfiles")(i)<>"" Then 
			imgName(i-1)=ImgSaves(UploadForm("imgfiles")(i),uploadform.defaultpath,30720000)
			IF imgName(i-1)=False Then Result=1

			IF Result=1 Then
				Set UploadForm=Nothing
				DBcon.Close
				Set DBcon=Nothing
				Response.Write ExecJavaAlert("업로드 허용용량(30M)을 초과하여 업로드를 실패하였습니다.",0)
				Response.End
			Else
				ThumbSaves 500 , 500 , UploadForm("imgfiles")(i) , uploadform.DefaultPath, imgName(i-1), "thumbs"
			End IF
		Else
			imgName(i-1)=""
		End IF
	End IF
Next

IF Sort="edit" Then
	IF ReLevel="A" Then
		Sql="Update BBslist Set BoardSort="&ChangeStrNull(BoardSort)&" Where ref="&Idx
		DBcon.Execute Sql
	End IF
	AlertTag="수정"
	Sql="Update BBslist Set email=?,BoardSort=?,writer=?,Title=?,Content=?,wip=?,imgnames=? Where idx="&idx
Else
	AlertTag="등록"
	Sql="INSERT INTO BBslist(email,BoardSort,writer,Title,Content,wip,imgnames,regdate,boardidx,useridx,pwd,publicYN) "
	Sql = Sql & "VALUES(?, ?, ?, ?, ?, ?, ?, Getdate(), ?, ?, ?, ?)"
End IF

Set objCmd = Server.CreateObject("ADODB.Command")
With objCmd
	.ActiveConnection = DBcon
	.CommandType = adCmdText
	.CommandText = Sql
	
	.Parameters.Append .CreateParameter("@email", adVarWChar, adParamInput, 100, email)
	.Parameters.Append .CreateParameter("@BoardSort", adInteger, adParamInput, 4, BoardSort)
	.Parameters.Append .CreateParameter("@Writer", adVarWChar, adParamInput, 20, Writer)
	.Parameters.Append .CreateParameter("@title", adVarWChar, adParamInput, 100, title)
	.Parameters.Append .CreateParameter("@content", adVarWChar, adParamInput, 2147483647, content)
	.Parameters.Append .CreateParameter("@Wip", adVarChar, adParamInput, 50, WIP)
	.Parameters.Append .CreateParameter("@imgNames", adVarWChar, adParamInput, 100, imgName(0))
	IF Sort<>"edit" Then
	.Parameters.Append .CreateParameter("@BoardIdx", adInteger, adParamInput, 4, BBsCode)
	.Parameters.Append .CreateParameter("@UserIdx", adInteger, adParamInput, 4, UserIdx)
	.Parameters.Append .CreateParameter("@Pwd", adVarWChar, adParamInput, 15, Pass)
	.Parameters.Append .CreateParameter("@PublicYN", adBoolean, adParamInput, 1, PublicYN)
	End IF
	.Execute,,adExecuteNoRecords
End With
Set objCmd = Nothing

Dim bIdx,MaxIdx
IF Sort="edit" Then
	bIdx=Idx
Else
	Sql="Select Max(Idx) From bbslist"
	MaxIdx=DBcon.Execute(Sql)
	bIdx=MaxIdx(0)
	
	Sql="UPDATE BBslist Set Ref="&MaxIdx(0)&",ReLevel='A' Where idx="&MaxIdx(0)
	DBcon.Execute Sql
End IF

'====================첨부파일 업로드 작업==========================================================
For i=1 To UploadForm("files").count
	IF Sort<>"edit" Then 
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
	Else
		IF UploadForm("filedel_idx")(i)<>"" Then
			IF UploadForm("filedel_idx")(i)<>"0" Then
				Sql="Select filenames From BBSData WHERE idx="&UploadForm("filedel_idx")(i)
				Set Rs=DBcon.Execute(Sql)
				IF Not(Rs.Bof Or Rs.Eof) Then
					ImgDelete Rs("filenames"),UploadForm.DefaultPath
				End IF
				Set Rs=NOthing

				IF UploadForm("files")(i)="" Then
					Sql="DELETE BBSData WHERE idx="&UploadForm("filedel_idx")(i)
					DBcon.Execute Sql
				Else
					filenames=ImgSaves(UploadForm("files")(i),uploadform.defaultpath,30720000)
					IF filenames=False Then Result=1

					IF Result=1 Then
						Set UploadForm=Nothing
						DBcon.Close
						Set DBcon=Nothing
						Response.Write ExecJavaAlert("업로드 허용용량(30M)을 초과하여 업로드를 실패하였습니다.",0)
						Response.End
					Else
						Sql="Update BBSData Set filenames='"&filenames&"',regdate=getdate() Where idx="&UploadForm("filedel_idx")(i)
						DBcon.Execute Sql
					End IF
				End IF
			Else
				IF UploadForm("files")(i)<>"" Then 
					filenames=ImgSaves(UploadForm("files")(i),uploadform.defaultpath,30720000)
					IF filenames=False Then Result=1

					IF Result=1 Then
						Set UploadForm=Nothing
						DBcon.Close
						Set DBcon=Nothing
						Response.Write ExecJavaAlert("업로드 허용용량(30M)을 초과하여 업로드를 실패하였습니다.",0)
						Response.End
					Else
						Sql="INSERT INTO BBSData(bidx,filenames,regdate) values("&idx&",'"&filenames&"',getdate())"
						DBcon.Execute Sql
					End IF
				End IF
			End IF
		End IF
	End IF
Next
'===============================================================================================

DBcon.Close
Set DBcon=Nothing

strLocation=prePage&"?page="&Page&"&storeidx="&storeidx&"&serboardsort="&serboardsort&"&search="&Search&"&searchstr="&SearchStr
Response.Write ExecJavaAlert("게시물이 "&AlertTag&"되었습니다.",2)
%>