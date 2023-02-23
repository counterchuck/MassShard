#include Pox_ParseChecklist.ahk
#include Pox_Login.ahk
#include Splash.ahk
#singleinstance, force

Splash()
winwaitclose, Please Login - PoxBros Mass Shard
token := Pox_Login(username,password)

ChecklistPath := Pox_GetRuneChecklist()
Pox_ParseChecklist(ChecklistPath)
return

Pox_GetRuneChecklist()
	{
	;Get Rune Checklist
	FileDelete,%A_ScriptDir%\Files\Curl\RuneChecklist.txt
	RunWait, "%A_ScriptDir%\Files\Curl\curl.exe" https://www.poxnora.com/runes/load-forge.do?m=checklist&_=1405990460745 -e https://www.poxnora.com/runes/checklist.do -k --anyauth --tlsv1 -A "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; MS-RTC LM 8; .NET4.0C; .NET4.0E; InfoPath.3; Tablet PC 2.0; Zune 4.0)" --cacert "%A_ScriptDir%\Files\Curl\Cert\ca-bundle.crt" -L --ssl --proxytunnel --keepalive-time 20 -b "%A_ScriptDir%\Files\Curl\cookies.txt" -c "%A_ScriptDir%\Files\Curl\cookies.txt" -o "%A_ScriptDir%\Files\Curl\RuneChecklist.txt",,hide 
	ChecklistPath = %A_ScriptDir%\Files\Curl\RuneChecklist.txt
	return ChecklistPath
	}

Pox_GetForgeToken(id=300,type="s",place=1) ;get new token, advance forge place, and find data-id for sacrifice -always call with baseid
	{
	GLOBAL
	;msgbox calling rune forge for id=%id% type = %type% and place=%place%
	RunWait, "%A_ScriptDir%\Files\Curl\curl.exe" https://www.poxnora.com/runes/launch-forge.do?m=forge&i=%id%&t=%type%&p=%place% -k --anyauth --tlsv1 -A "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; MS-RTC LM 8; .NET4.0C; .NET4.0E; InfoPath.3; Tablet PC 2.0; Zune 4.0)" --cacert "%A_ScriptDir%\Files\Curl\Cert\ca-bundle.crt" -L --ssl --proxytunnel  --keepalive-time 20 -b "%A_ScriptDir%\Files\Curl\cookies.txt" -c "%A_ScriptDir%\Files\Curl\cookies.txt" -o "%A_ScriptDir%\Files\Curl\ForgeLaunch.txt",,hide 

	FileRead ,ForgeLaunch,%A_ScriptDir%\Files\Curl\ForgeLaunch.txt
	RegExMatch(ForgeLaunch,"id=""rune-level"">(\d)<",RuneLevel)
;msgbox rune is level %runelevel1%. 
	while (skipleveled and RuneLevel1 > 2)
		{
;msgbox dont sac leveled runes. skipping to next rune
		CurrentRune.Place++
		place++
		if (CurrentRune.Place > CurrentRune.Count)
			return 0 ;all remaining runes are leveled and must be skipped
		RunWait, "%A_ScriptDir%\Files\Curl\curl.exe" https://www.poxnora.com/runes/launch-forge.do?m=forge&i=%id%&t=%type%&p=%place% -k --anyauth --tlsv1 -A "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; MS-RTC LM 8; .NET4.0C; .NET4.0E; InfoPath.3; Tablet PC 2.0; Zune 4.0)" --cacert "%A_ScriptDir%\Files\Curl\Cert\ca-bundle.crt" -L --ssl --proxytunnel --keepalive-time 20 -b "%A_ScriptDir%\Files\Curl\cookies.txt" -c "%A_ScriptDir%\Files\Curl\cookies.txt" -o "%A_ScriptDir%\Files\Curl\ForgeLaunch.txt",,hide 
		FileRead ,ForgeLaunch,%A_ScriptDir%\Files\Curl\ForgeLaunch.txt
		if !(RegExMatch(ForgeLaunch,"id=""rune-level"">(\d)<",RuneLevel)) ;non champion rune, no level found
			RuneLevel1 := 1 ;set level to 1
		}
	RegExMatch(ForgeLaunch,"currentToken\s=\s'([\w-]*)'",token)
	RegExMatch(ForgeLaunch,"data-id=""(\d*)""\sid=""sacrifice-link""",dataid)
	CurrentRune.Dataid := dataid1
	;msgbox GetForgetoken finished. Data-id is now %dataid1%. token is %token1%.
	return token1
	}

Pox_Forge_Sacrifice(Dataid,runetype,ByRef token)
	{
	;listvars
	;msgbox saccing now
	;msgbox not skipping. skipleveled=%skipleveled% and runelevel1=%RuneLevel1%`n`n%forgelaunch%
	RunWait, "%A_ScriptDir%\Files\Curl\curl.exe" https://www.poxnora.com/runes/do-forge.do?i=%Dataid%&t=%RuneType%&k=%token%&a=1 -k --anyauth --tlsv1 -A "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; MS-RTC LM 8; .NET4.0C; .NET4.0E; InfoPath.3; Tablet PC 2.0; Zune 4.0)" --cacert "%A_ScriptDir%\Files\Curl\Cert\ca-bundle.crt" -L --ssl --proxytunnel --keepalive-time 20 -b "%A_ScriptDir%\Files\Curl\cookies.txt" -c "%A_ScriptDir%\Files\Curl\cookies.txt" -o "%A_ScriptDir%\Files\Curl\SacResponse.txt",,hide  
	FileRead ,SacResponse,%A_ScriptDir%\Files\Curl\SacResponse.txt
	RegExMatch(SacResponse,"""status"":(-?\d*),",Status)
	RegExMatch(SacResponse,"""token"":""([\w-]*)""",Token)
	token := token1 ;sets ByRef variable to new token
	return status1
	}

Sacrifice(RunesToSac)
	{
	GLOBAL
	TotalSacCount := 0
	SacCounter := 0
	ErrorLog := ""
	;msgbox %RunesToSac%
	Loop, Parse,RunesToSac,$ ;count up total to sac for progress bar
		{
		if a_index = 1
			continue
		StringSplit, ToSac, a_loopfield,|
		if !ToSac1 ;uniqueKey
			continue
		if ToSac2 < 1 ;quantity to sac
			continue
		TotalSacCount += ToSac2
		}
	;----launch progress GUI
	Gui 2:+alwaysontop -SysMenu +Owner
	Gui, 2:Add, Text, x6 y10 w220 vSacStatusText +wrap, Sacrificing %runename%: %a_index% out of %ToSac2%`nOverall: %SacCounter% out of %TotalSacCount% total runes to sacrifice.
	Gui, 2:Add, Progress, x6 y75 w220 h15 vCurrentRuneprogress, 0
	Gui, 2:Add, Progress, x6 y105 w220 h15 vOverAllProgress cGreen, 0
	Gui, 2:Show, NoActivate h140 w236, Mass Shard - Rune Sacrificer
	;----begin sacrifice routine
	;msgbox looping through %RunesToSac% delimited by $
	Loop, Parse,RunesToSac,$ ;loop through all runes to sac, delimited by $
		{
		ErrMsg := ""
		Guicontrol, 2:, CurrentRuneprogress, 0	
		innerloop := 0
		StringSplit, ToSac, a_loopfield,|
		;msgbox %tosac1%`n%tosac2%
		if !ToSac1 ;uniqueKey
			continue
		if ToSac2 < 1 ;quantity to sac
			continue
		CurrentRune := AllRunes[ToSac1]
		CurrentRune.Place++
		RuneType := CurrentRune.RuneType
		StringLeft, RuneType, RuneType, 1
		if !(token := Pox_GetForgeToken(CurrentRune.baseid,RuneType,CurrentRune.Place)) ;also updates currentrune's data id)
			skipthis = 1 ;all remaining copies are leveled and must be skipped
		else
			skipthis = 0
		runename := CurrentRune.name
		;msgbox looping %ToSac2%
		Loop %ToSac2% ;sacrifice requested quantity for current rune
			{
			InnerLoop++
			CurrentCurrentRuneProgress := (innerloop/ToSac2)*100
			Guicontrol, 2:, CurrentRuneprogress, %CurrentCurrentRuneProgress%
			SacCounter++
			if (SacCounter > TotalSacCount)
				break
			CurrentOverallProgress := (SacCounter/TotalSacCount)*100
			Guicontrol, 2:, OverAllProgress, %CurrentOverallProgress%
			Guicontrol, 2:Text, SacStatusText, Sacrificing %runename%: %innerloop% out of %ToSac2%`nOverall: %SacCounter% out of %TotalSacCount%`nVisit www.poxbrothers.info for the cheapest runes!
			if !skipthis
				SacrificeResult := Pox_Forge_Sacrifice(CurrentRune.Dataid,runetype,token) ;also updates token using ByRef
			else
				SacrificeResult = -1, ErrMsg := "All Remaining copies are leveled"
			if (SacrificeResult != 1) ;sac failed
				{
				While (SacrificeResult = -2) ;"rune is in a deck"
					{
					CurrentRune.Place += 1 ;increment current rune's "place" in the forge to try skipping over runes in a deck
					if (CurrentRune.Place > CurrentRune.Count)
						SacrificeResult := -1, ErrMsg := "All Remaining copies are in BGs"
					else
						{
						if !(Token := Pox_GetForgeToken(CurrentRune.baseid,RuneType,CurrentRune.Place)) ;advance forge place, get new token
							SacrificeResult := -1, ErrMsg := "All Remaining copies are leveled"
						SacrificeResult := Pox_Forge_Sacrifice(CurrentRune.Dataid,runetype,token)
						}
					}
				if (SacrificeResult = -1)
					{
					if !ErrMsg
						ErrMsg := "Unknown Error"
					ErrorLog .= runename . "-" . ErrMsg . "`n"
					token := Pox_GetForgeToken()
					if (SacCounter >= TotalSacCount)
						break
					else
						continue
					}
				}
			CurrentRune.count-- ;decrement count if sac success
			}
		;msgbox finished
		}
	if ErrorLog
		{
		Gui, ErrorLog:Add, Text, w350, The following rune sacrifice operations failed. This can occur randomly or can be caused if all remaining copies of a rune were in a deck or are Leveled when you set leveled runes to be skipped
		Gui, ErrorLog:Add, edit, readonly vscroll h250 w350, %ErrorLog%
		Gui, ErrorLog:Show, , Mass Shard - Error Log
		}
	msgbox,4100,, Sacrifice finished! `n`nDo you want to reload your checklist? `n`nClick No to exit this app.
	ifmsgbox Yes
		{
		Gui, confirm: destroy
		Gui, 2: destroy
		Gui, Checklist: destroy
		Gui, ErrorLog: destroy
		ChecklistPath := Pox_GetRuneChecklist()
		Pox_ParseChecklist(ChecklistPath)
		}
	else
		exitapp
	}

ErrorLogGuiClose:
Gui, ErrorLog: destroy
return
