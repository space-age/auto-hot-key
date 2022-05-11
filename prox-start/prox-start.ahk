; only allow one instance of this starter script to run and if another is launched, ignore that attempt to launch it
#singleinstance ignore

autoRestartProxDays := 30			; days to auto restart software

minutesInAutoRestartProxInDays:= autoRestartProxDays*60*24
autoRestartTime:= minutesInAutoRestartProxInDays*60*1000

SetTimer, resetProx, % autoRestartTime

Start:
	
	;set the working dir to the prox folder
	SetWorkingDir, C:\a\prox

	;start the program
	Run, C:\a\prox\prox-masks.py

	Sleep, 5000
	
	; if the software closes, wait 3 seconds and then restart it by going back to the beginning of this script
	WinWaitClose, ahk_exe py.exe
	SetTimer, resetProx, On
	Sleep, 3000
	Goto, Start
	
resetProx:
	Process, Close, py.exe
return
