Pox_Login(username,password)
	{
	GLOBAL
	;Get JSessionID Cookie
	RunWait, "%A_ScriptDir%\Files\Curl\curl.exe" https://www.poxnora.com -k --anyauth --tlsv1 -A "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; MS-RTC LM 8; .NET4.0C; .NET4.0E; InfoPath.3; Tablet PC 2.0; Zune 4.0)" --cacert "%A_ScriptDir%\Files\Curl\Cert\ca-bundle.crt" -L --ssl --proxytunnel --keepalive-time 20 -b "%A_ScriptDir%\Files\Curl\cookies.txt" -c "%A_ScriptDir%\Files\Curl\cookies.txt",,hide  
	FileRead ,Cookies,%A_ScriptDir%\Files\Curl\cookies.txt
	RegExMatch(Cookies,"JSESSIONID\s*(.*)",JSessionID)
	JSessionID := JSessionID1
;msgbox 1
	;Get login token
	RunWait, "%A_ScriptDir%\Files\Curl\curl.exe" https://www.poxnora.com/security/login.do;jsessionid=%JSessionID% -k --anyauth --tlsv1 -A "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; MS-RTC LM 8; .NET4.0C; .NET4.0E; InfoPath.3; Tablet PC 2.0; Zune 4.0)" --cacert "%A_ScriptDir%\Files\Curl\Cert\ca-bundle.crt" -L --ssl --proxytunnel --keepalive-time 20 -b "%A_ScriptDir%\Files\Curl\cookies.txt" -c "%A_ScriptDir%\Files\Curl\cookies.txt" -o "%A_ScriptDir%\Files\Curl\LoginPage.txt",,hide 
	FileRead ,Cookies,%A_ScriptDir%\Files\Curl\LoginPage.txt
	RegExMatch(Cookies,"value=""(\w*)""",Token)
	Token := Token1
;msgbox 2
	;login
	RunWait, "%A_ScriptDir%\Files\Curl\curl.exe" --data "org.apache.struts.taglib.html.TOKEN=%token%&username=%UserName%&password=%Password%" https://www.poxnora.com/security/dologin.do  -e "https://www.poxnora.com/security/login.do;jsessionid=%JSessionID%" -k --anyauth --tlsv1 -A "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; MS-RTC LM 8; .NET4.0C; .NET4.0E; InfoPath.3; Tablet PC 2.0; Zune 4.0)" --cacert "%A_ScriptDir%\Files\Curl\Cert\ca-bundle.crt" -L --ssl --proxytunnel --keepalive-time 20 -b "%A_ScriptDir%\Files\Curl\cookies.txt" -c "%A_ScriptDir%\Files\Curl\cookies.txt" -o "%A_ScriptDir%\Files\Curl\LoginResponse.txt",,hide 
	;msgbox 3
	return token
	}