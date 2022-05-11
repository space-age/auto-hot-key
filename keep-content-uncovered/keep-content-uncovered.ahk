;To configure this, change the number in the line below to match the bottom of the content
bottomOfContent := 448


CoordMode, Mouse, Screen
Loop 
{
    Winget, windowsList, List
    Loop %windowsList%
    {
        winId := windowsList%A_Index%
        WinGet, winProcName, ProcessName,ahk_id %winId% 
        if (winProcName = "AWMPlayer.exe" or winProcName = "AutoHotKey.exe") {
            continue
        }
        WinGetPos, x, y, ,,ahk_id %winId%
        if (y <= bottomOfContent) {
            WinGet, winState, MinMax,ahk_id %winId% 
            if (winState = 1) 	
            {
                WinRestore, ahk_id %winId%
            }
            if (winState = -1)
            {
            ;minimized
                continue
            }	
            WinMove, ahk_id %winId%,,%x%, (bottomOfContent+10)
        }	

    }
    MouseGetPos, x, y
    if (y <= bottomOfContent) {
        MouseMove, %x%, (bottomOfContent+35)
    }
    Sleep,250
}