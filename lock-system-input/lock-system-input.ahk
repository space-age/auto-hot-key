#singleinstance force
; from https://autohotkey.com/board/topic/79318-lock-the-computer/
; and partially from https://autohotkey.com/board/topic/63975-cool-screen-lock-usb-is-the-key-try-to-crack/
;*******************************************
; --------------- Lock.ahk ------------------
; Locks keyboard and mouse input upon hotkey (win alt l), 
; unlock with password
;
; Timer for locking the computer at idle,
; turned off at default
;
; KST 2012
;*******************************************

autolockDelayInMinutes := 30	; Minutes that keyboard and mouse locks continuously
autolockDelay := autolockDelayInMinutes*60*1000

messageDisplaying := 0			;Tracks if lock message displaying, 0=false,1=true
checkIfLockRunning := 1			;Tracks if activity is lock, 0=fasle,1=true

SysGet, MonitorDefault, Monitor
BottomX := % MonitorDefaultRight/2
BottomY := % MonitorDefaultBottom-200

SetTimer, start_LockPC, % autolockDelay
SetTimer, start_lock, -250					;Starts program by locking everything immediately

#NoEnv ; Avoids checking empty variables to see if they are environment variables

;Tray Menu
	Menu, Tray, Icon,shell32.dll,48    ; systray icon is a padlock
	Menu, TRAY, NoStandard
	Menu, TRAY, Add, Lock (Win Alt l), start_lock
	Menu, TRAY, Add, Set Timer, set_timer
	Menu, Tray, Add
	Menu, Tray, Add, Exit, lock_exit
	Menu, Tray, default, Lock (Win Alt l)
	return
return
	
set_timer:		;GUI for setting the time (min) at idle until locking
				;if time = 0 no timer will be set
	Gui, Add, Text,, Idle time until lock (in min)
	Gui, Add, Edit ,  ym  
	Gui, Add, UpDown, vTime Range0-500, -1
	Gui, Add, Button, default ym, OK  
		
	Gui, Show,, Time until lock
	return  

	GuiClose:
	ButtonOK:
		Gui, Submit  
		Gui, Destroy
			
		if (Time < 1)	
			{
			SetTimer, UpdateIdleState, Off
			}
		else
			{
			SetTimer, UpdateIdleState, 5000
			}
	
return

UpdateIdleState:	;check if idle every 5 seconds
	Timems := Time*60*1000
	
	if (A_TimeIdlePhysical > Timems)
		{
		gosub, start_lock
		}
return

lock_exit:						
	ExitApp
return
	
start_LockPC:
	SetTimer,start_LockPC, off
	Gosub, start_lock
return

start_lock:						;turn on lock
#!l::
	checkIfLockRunning := 1
	MouseMove, 1920, 1080
    BlockKeyboardInputs("On")
	BlockMouseClicks("On")
	BlockInput MouseMove
    SetTimer, CloseTaskMgr, On
	SetTimer, start_LockPC, off					;Turns off immediately so timer only runs when is unlock
	SetTimer, CheckMouseKeyBoardMovement, -250
return

checkNoMovement:
		if((messageDisplaying = 1 && A_TimeIdle > 3000) or checkIfLockRunning = 0)
		{
			Gosub,CloseMessageBox
			messageDisplaying := 0
			SetTimer, checkNoMovement, off
		}
return

CheckMouseKeyBoardMovement:
	Loop
	{		
		if(messageDisplaying = 0 && A_TimeIdle <= 0)
		{
			messageDisplaying := 1
			SetTimer, checkNoMovement, 250
			Gosub, DisplayMsgBoxLockScript
		}
		if(checkIfLockRunning = 0)
			break
	}
return

changeCheckIfLockRunning:
	checkIfLockRunning := 0
return

DisplayMsgBoxLockScript:
	SetTimer, WinMoveMsgBox, 50
	MsgBox, ,Lock Script, Enter Password to unlock. Window will dissapear once correct password is enter.
return

WinMoveMsgBox:
	SetTimer, WinMoveMsgBox, OFF
	WinMove, Lock Script, Enter Password to unlock. Window will dissapear once correct password is enter., % BottomX, % BottomY
return

CloseMessageBox:
	WinClose, Lock Script, Enter Password to unlock. Window will dissapear once correct password is enter.
return

CloseTaskmgr:
	Process, Wait, taskmgr.exe, 4
	Process, Close, taskmgr.exe
return

ResetBlock()					;turn off lock
{ 
	Gosub, changeCheckIfLockRunning
	SetTimer, start_LockPC, on		;Restarts the continously lock time after certain minutes
	BlockKeyboardInputs("Off")
	BlockMouseClicks("Off")
	BlockInput MouseMoveOff
    SetTimer, CloseTaskMgr, Off
	return
}     

  
BlockKeyboardInputs(state = "On")
{
   static keys, pass
   keys=Space,Enter,Tab,Esc,BackSpace,Del,Ins,Home,End,PgDn,PgUp,Up,Down,Left,Right,CtrlBreak,ScrollLock,PrintScreen,CapsLock,Pause,AppsKey,LWin,RWin,Control,Alt,Shift,LCtrl,RCtrl,LShift,RShift,LAlt,RAlt,NumLock,Numpad0,Numpad1,Numpad2,Numpad3,Numpad4,Numpad5,Numpad6,Numpad7,Numpad8,Numpad9,NumpadDot,NumpadDiv,NumpadMult,NumpadAdd,NumpadSub,NumpadEnter,NumpadIns,NumpadEnd,NumpadDown,NumpadPgDn,NumpadLeft,NumpadClear,NumpadRight,NumpadHome,NumpadUp,NumpadPgUp,NumpadDel,Media_Next,Media_Play_Pause,Media_Prev,Media_Stop,Volume_Down,Volume_Up,Volume_Mute,Browser_Back,Browser_Favorites,Browser_Home,Browser_Refresh,Browser_Search,Browser_Stop,Launch_App1,Launch_App2,Launch_Mail,Launch_Media,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12,F13,F14,F15,F16,F17,F18,F19,F20,F21,F22,F23,F24,1,2,3,4,5,6,7,8,9,0,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,ä,ü,ö,å,ø,æ,²,&,é,",',(,-,è,_,ç,à,),=,$,£,ù,*,~,#,{,[,|,``,\,^,@,],},;,:,!,?,.,/,§,<,>,vkBC
	
	pass = cool 				;PASSWORD
	
	passcounter := 0
	
   Loop,Parse,keys, `,
      Hotkey, *%A_LoopField%, passcheck, %state% UseErrorLevel
   
    Return

		passcheck:			
			StringReplace, CurrentChar, A_ThisHotkey, *			; remove the leading "*" in the Hotkey variable
			
			StringMid, PassChar, pass, passcounter+1, 1			;get the effective character from pass
						
			if (CurrentChar = PassChar)							;check if the pass character equals the pressed key
				{
				passcounter++									;if yes, next character from the password gets effective
				if (passcounter = StrLen(pass))					;if all characters did match, stop the lock			
					{
					ResetBlock()
					return
					}
							
				} 
			else
				{
				passcounter := 0								;if one character didn't match, the first character gets effective again
				 
				}
						
			Return
			
		
		
}


BlockMouseClicks(state = "On")
{
   static keys="RButton,LButton,MButton,WheelUp,WheelDown,XButton1,XButton2"
   Loop,Parse,keys, `,
      Hotkey, *%A_LoopField%, MouseDummyLabel, %state% UseErrorLevel
   Return

		MouseDummyLabel:		; hotkeys need a label, so give them one that do nothing
			Return
}
