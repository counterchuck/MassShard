Splash()
{
global
Gui, Splash:+alwaysontop +ToolWindow
gui, splash: font, s13 w600
Gui, Splash: Add, Text, xm ym center w300, Mass Shard is Brought to you by...
Gui, splash:Add, Picture, center gLink1 vURL_Link1 x25, %A_ScriptDir%\Files\poxbros_logo.png
gui, splash: font, s10 w400
Gui, Splash: Add, Text, center w300, Click the logo above to visit the only store where you can find the cheapest PoxNora runes`n---------------------------------`nEnter your Poxnora login below to continue.
Gui, Splash: Add, Edit, x95 w150 vUserName, Pox Username
Gui, Splash: Add, Edit, x95 w150 vPassword password, Pox Password
Gui, Splash: Add, button, x95 w150 gLogin Default, Login
gui, splash: font, s9 w300
Gui, Splash: Add, Text, cFF8800 x55 ,Developer: newsbuff - charlesdolson@gmail.com
;Gui, splash:Color, 0f0f0f
Gui, splash: +LastFound  ; Make the GUI window the last found window for use by the line below.
;WinSet, TransColor, EEAA99
Gui, splash: Show,, Please Login - PoxBros Mass Shard
 
  ; Retrieve scripts PID
  Process, Exist
  pid_this := ErrorLevel
 
  ; Retrieve unique ID number (HWND/handle)
  WinGet, hw_gui, ID, ahk_class AutoHotkeyGUI ahk_pid %pid_this%
 
  ; Call "HandleMessage" when script receives WM_SETCURSOR message
  WM_SETCURSOR = 0x20
  OnMessage(WM_SETCURSOR, "HandleMessage")
 
  ; Call "HandleMessage" when script receives WM_MOUSEMOVE message
  WM_MOUSEMOVE = 0x200
  OnMessage(WM_MOUSEMOVE, "HandleMessage")
  return
 
 Login:
 gui, splash: submit
gui, splash: destroy
 return
  
SplashGuiClose:
  ExitApp
  return

Link1:
  Run, http://www.poxpoints.com
Return
}


;######## Function #############################################################
HandleMessage(p_w, p_l, p_m, p_hw)
  {
    global   WM_SETCURSOR, WM_MOUSEMOVE, 
    static   URL_hover, h_cursor_hand, h_old_cursor, CtrlIsURL, LastCtrl
   
    If (p_m = WM_SETCURSOR)
      {
        If URL_hover
          Return, true
      }
    Else If (p_m = WM_MOUSEMOVE)
      {
        ; Mouse cursor hovers URL text control
        StringLeft, CtrlIsURL, A_GuiControl, 3
        If (CtrlIsURL = "URL")
          {
            If URL_hover=
              {
                Gui, Font, cBlue underline
                GuiControl, Font, %A_GuiControl%
                LastCtrl = %A_GuiControl%
               
                h_cursor_hand := DllCall("LoadCursor", "uint", 0, "uint", 32649)
               
                URL_hover := true
              }                 
              h_old_cursor := DllCall("SetCursor", "uint", h_cursor_hand)
          }
        ; Mouse cursor doesn't hover URL text control
        Else
          {
            If URL_hover
              {
                Gui, Font, norm cBlue 
                GuiControl, Font, %LastCtrl%
               
                DllCall("SetCursor", "uint", h_old_cursor)
               
                URL_hover=
              }
          }
      }
  }
;######## End Of Functions #####################################################