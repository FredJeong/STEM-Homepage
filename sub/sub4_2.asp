{% extends "base.html" %}
{% block container %}
    <!--container-->
    <div id="container">
        <div class="contain">
            <div class="s_contents">
                <!--#include virtual = "/inc/right_login.asp"-->
                <!--#include virtual = "/inc/left.asp"-->
            </div>
            <div class="con">
                <ul>
                    <li class="stit"><img src="/images/stit{{mNum}}_{{sNum}}.gif" alt="" /></li>
                    <li class="con_img">
                        <table>
                            <tr>
                                <td style="padding:40px 60px 40px 60px; "><a href="http://eng.snu.ac.kr/" target="_blank"><img src="/images/a1.gif"></a></td>
                                <td><a href="http://gwanak.go.kr/" target="_blank"><img src="/images/a2.gif"></a></td>
                            </tr>
                            <tr>
                                <td style="padding:0 60px 0 60px; "><a href="http://www.dongbuhitek.co.kr/" target="_blank"><img src="/images/a3.gif"><a/></td>
                                <td><a href="http://www.postech.ac.kr/" target="_blank"><img src="/images/a4.gif"></a></td>
                            </tr>
                            <tr>
                                <td style="padding:40px 60px 40px 60px; "><a href="#"><img src="/images/a5.gif"></a></td>
                            </tr>
                        </table>
                    </li>
                </ul>
            </div>
        </div>
    </div>
    <!--//container-->
{% endblock %}