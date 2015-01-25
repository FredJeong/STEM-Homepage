<SCRIPT language=JavaScript src="/ckeditor/ckeditor.js" type='text/javascript'></SCRIPT>

<form name='boardfrm' method='post' action='/board/ok_bbswrite.asp' ENCTYPE="multipart/form-data" style='margin:0;'>
<input type='hidden' name='storeidx' value='<%=storeidx%>'>
<input type="hidden" name='bbscode' value='<%=BBsCode%>'>
<input type="hidden" name='prepage' value='<%=prepage%>'>
<input type="hidden" name='sort' value='edit'>
<input type='hidden' name='Idx' value='<%=Idx%>'>
<input type='hidden' name='Page' value='<%=Page%>'>
<input type='hidden' name='Search' value='<%=Search%>'>
<input type='hidden' name='SearchStr' value='<%=SearchStr%>'>
<input type='hidden' name='serboardsort' value='<%=serboardsort%>'>
<table cellspacing="0" border="0" summary="글 내용을 작성" class="tbl_write">
<colgroup>
<col width="80">
<col>
<col width="80">
<col>
</colgroup>
<thead>
	<tr>
		<th scope="row">작성자</th>
		<td colspan='3'><input name="writer" type="text" size='38' maxlength='10' class='input' value='<%=Writer%>'></td>
	</tr>
</thead>
<tbody>
	<% IF BBsSort<>"" Then %>
	<tr>
		<th scope="row">질문유형</th>
		<td colspan="3"><%=BBsSort%></td>
	</tr>
	<% Else %>
		<input type='hidden' name='boardsort' value='<%=BoardSort%>'>
	<% End IF %>
	<tr>
		<th scope="row">Email</th>
		<td colspan="3"><input name="email" type="text" size="50" maxlength='45' class='input' style="width:98%;" value='<%=email%>'></td>
	</tr>
	<tr>
		<th scope="row">제목</th>
		<td colspan="3"><input name="title" type="text" size="50" maxlength='45' class='input' style="width:98%;" value='<%=Title%>'></td>
	</tr>
	<% IF HK_imgYN<>"False" Then %>
	<tr>
		<th scope="row">이미지첨부</th>
		<td colspan="3"><input type='file' name='imgfiles' style="width:70%" class="input"><input type='hidden' name='imgname' value="<%=imgNames%>">
		<input type='checkbox' name='imgDel_Chk' style='border:none;'> 이미지변경여부</td>
	</tr>
	<% End IF %>
	<tr>
		<td colspan="4" class="cont" style='padding:10px 0 5px 0;'><div id='textareaDIV'><textarea name="content" id="content" style='width:100%; word-break:break-all;' rows="15" class='ckeditor'><%=Content%></textarea></div></td>
	</tr>
	<% IF HK_PdsYN<>"False" Then %>
	<tr>
		<th scope="row">파일첨부</th>
		<td colspan="3">
			<table cellpadding='0' cellspacing='0' width='100%' id="inRow">
			<% IF IsArray(FileRec) Then %>
				<% For i=0 To UBound(FileRec,2) %>
				<tr>
					<td style='padding:1px 0; border:0px solid #ffffff'>
						<input type='file' name='files' style='width:350px' class='input'>
						<a href='/common/download.asp?downfile=<%=FileRec(1,i)%>&path=board'><span style='font-size:11px; color: #A80000'>[다운로드]</span></a>
						<input type='hidden' name='filedel_idx' value='0'>
						<input type='checkbox' name='delchk' onclick='changeFilech(<%=i%>,<%=FileRec(0,i)%>)'> 파일수정여부

						<% IF i=0 Then %><a href='#jLink' onclick="addRow()"><span style='color: #D90000'>&nbsp;필드추가</span></a><% End IF %>
					</td>
				</tr>
				<% Next%>
			<% Else %>
				<tr>
					<td style='padding:1px 0; border:0px solid #ffffff'>
						<input type='file' name='files' style='width:350px' class='input'>
						<input type='hidden' name='filedel_idx' value='0'>
						<a href='#jLink' onclick="addRow()"><span style='color: #D90000'>필드추가</span></a>
					</td>
				</tr>
			<% End IF %>
			</table>
		</td>
	</tr>
	<% End IF %>
</tbody>
</table>

<div style='padding:10px; text-align:center;'>
	<input type='button' value='확인' class='button2' onclick='modifysendit();' style='cursor:pointer'>
	<input type='button' value='취소' class='button1' onclick='history.back();' style='cursor:pointer'>
</div>
</form>

<SCRIPT LANGUAGE="JavaScript">
CKEDITOR.replace( 'content', { customConfig: 'config_user.js' } );
</SCRIPT>