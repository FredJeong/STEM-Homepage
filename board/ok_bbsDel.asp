<!-- #include virtual = common/dbcon.asp -->
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<%
Dim Sql,UploadForm,strLocation,Rs
Dim Page,Search,SearchStr,Idx,InputPwd,BBsCode,serboardsort
Dim pwd,useridx,Ref,ReLevel,AlertMsg,AdWrite,imgnames
Dim souchk : souchk=0
Dim ThumbFileName,tmpFileName

prepage=Request("prepage")
Page=Request("page")
storeidx=Request("storeidx")
serboardsort=Request("serboardsort")
Search=Request("Search")
SearchStr=Request("SearchStr")
idx=Request("idx")
BBsCode=Cint(Request("bbscode"))
inputPwd=Session("boardPass")
Session.Contents.Remove("boardPass")

Call HK_BBSSetup(BBsCode)

Sql="SELECT pwd,IsNull(UserIdx,0) As Useridx,Ref,ReLevel,AdWrite,imgnames FROM bbslist WHERE idx="&Idx
Rs=DBcon.Execute(Sql)

Pwd=Rs("pwd") : UserIdx=Rs("useridx")
Ref=Rs("Ref") : ReLevel=Rs("ReLevel") : AdWrite=Rs("AdWrite") : imgnames=Rs("imgnames")

IF AdWrite="False" Then
	IF inputPwd="" Then
		IF CStr(UserIdx)=CStr(Session("useridx")) THen souchk=souchk+1
		AlertMsg="작성자 정보와 일치하지 않습니다."
	Else
		IF inputPwd=Pwd THen souchk=souchk+1
		AlertMsg="비밀번호가 일치하지 않습니다."
	End IF
Else
	AlertMsg="작성자 정보와 일치하지 않습니다."
End IF

IF souchk=false Then
	Response.Write ExecJavaalert(AlertMsg&"\n다시시도해주세요.",0)
	Response.End
End IF

Server.ScriptTimeOut=7200
set UploadForm=server.CreateObject("DEXT.FileUpload")
uploadform.DefaultPath=Server.MapPath("/upload/board/")

IF imgnames<>"" Then
	ImgDelete imgnames,UploadForm.DefaultPath
	ImgDelete getImageThumbFilename(imgnames),UploadForm.DefaultPath
End IF

'=====================첨부파일 삭제======================
Sql="SELECT filenames FROM BBSData WHERE bidx="&idx
Set FileRs=DBcon.Execute(Sql)
IF Not(FileRs.Bof Or FileRs.Eof) Then
	Do Until FileRs.Eof
		If FileRs("filenames")<>""  Then ImgDelete FileRs("filenames"),UploadForm.DefaultPath
		FileRs.MoveNext()
	Loop
End IF
Sql="DELETE BBSData WHERE bidx="&idx
DBcon.Execute Sql
'========================================================

Sql="Select idx,ReLevel From bbslist Where Ref="&Ref&" AND ReLevel Like '"&ReLevel&"_'"
Set Rs=DBcon.Execute(Sql)

IF Rs.Bof Or Rs.Eof Then
	Dim i

	Sql="DELETE bbslist WHERE idx="&Idx
	DBcon.Execute Sql

	For i=Len(ReLevel)-1 To i=1 step i-1
		Sql="Select idx From bbslist Where Ref="&Ref&" And ReLevel like '"&Left(ReLevel,i)&"%' AND DelYN<>1 AND idx<>"&IDx
		Set Rs=DBcon.Execute(Sql)

		IF Rs.Bof Or Rs.Eof Then
			Sql="Delete bbslist Where Ref="&Ref&" And ReLevel Like '"&Left(ReLevel,i)&"%'"
			DBcon.Execute Sql
		Else
			Exit For
		End IF
	Next
Else
	Sql="Update bbslist Set DelYN=1 Where idx="&Idx
	DBcon.Execute Sql
End IF

Set UploadForm=Nothing
DBcon.Close
Set DBcon=Nothing

strLocation=prepage&"?page="&Page&"&storeidx="&storeidx&"&serboardsort="&serboardsort&"&Search="&Search&"&SearchStr="&SearchStr
Response.Write ExecJavaAlert("선택하신 글이 삭제되었습니다.",2)
%>