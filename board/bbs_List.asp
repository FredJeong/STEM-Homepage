<%=TopSortListTag%>
<div class="board_search">
<form name='searchfrm' method='get' style='margin:0' onsubmit="searchGo();event.returnValue= false;">
<%=BBsSelectField%>
<input type='hidden' name='storeidx' value='<%=storeidx%>'>
<select name="search" class="input">
    <option value="title" selected="selected">제 목</option>
    <option value="writer" <%=SelCheck("writer",search)%>>글쓴이</option>
    <option value="content" <%=SelCheck("content",search)%>>글내용</option>
</select>
<input name="searchstr" type="text" style="width:150px;" class="input" value='<%=ReplaceTextField(searchStr)%>'>
<input type='button' value='검색' class='button1' onclick='searchGo();' style='cursor:pointer'>
<% IF HK_NotYN="False" AND HK_MemYN="1" AND Session("MemberShip")="1" Then %>
<input type='button' value='쓰기' class='button1' onclick="<%=WriteModeChk(HK_MemYN,"location.href='?mode=write&storeidx="&storeidx&"'",prepage)%>" style='cursor:pointer'>
<% ElseIF HK_NotYN="False" AND (HK_MemYN="" OR HK_MemYN="0") Then %>
<input type='button' value='쓰기' class='button1' onclick="<%=WriteModeChk(HK_MemYN,"location.href='?mode=write&storeidx="&storeidx&"'",prepage)%>" style='cursor:pointer'>
<% End IF %>
</form>
</div>

<table cellspacing="0" border="0" summary="게시판의 글제목 리스트" class="tbl_type" style='table-layout:fixed; word-wrap:break-word;'>
<colgroup>
<col width="70">
<col>
<col width="115">
<col width="80">
<col width="55">
</colgroup>
<thead>
    <tr>
        <th scope="col">번호</th>
        <th scope="col">제목</th>
        <th scope="col">글쓴이</th>
        <th scope="col">날짜</th>
        <th scope="col">조회수</th>
    </tr>
</thead>
<tbody>
    <%=PT_BoardList%>
</tbody>
</table>

<% IF HK_NotYN="False" Then %>
<!-- <div style='padding-top:10px;float:right;'><input type='button' value='쓰기' class='button5' onclick="<%=WriteModeChk(HK_MemYN,"location.href='?mode=write&storeidx="&storeidx&"'",prepage)%>" style='cursor:pointer'></div> -->
<% End IF %>

<center><div style='padding-top:10px;'><%=PT_SpPageLink("","storeidx="&storeidx&"&serboardsort="&serboardsort&"&search="& Search &"&SearchStr="& SearchStr,"")%></div></center>

<form name='boardActfrm' id='boardActfrm' method='get' action='' style='margin:0;'>
<input type='hidden' name='mode'>
<input type='hidden' name='sort'>
<input type='hidden' name='idx'>
<input type='hidden' name='Page' value='<%=Page%>'>
<input type='hidden' name='BBSCode' value='<%=BBSCode%>'>
<input type='hidden' name='serboardsort' value='<%=serboardsort%>'>
<input type='hidden' name='Search' value='<%=Search%>'>
<input type='hidden' name='SearchStr' value='<%=SearchStr%>'>
<input type='hidden' name='storeidx' value='<%=storeidx%>'>
</form>