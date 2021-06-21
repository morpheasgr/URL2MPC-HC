#NoEnv
SetWorkingDir %A_ScriptDir%
#SingleInstance ignore
clipboard := ""
global copiedtext := ""
global MPCHCPath := ""
global MPCHCExe := ""
RegRead, MPCHCPath, HKEY_CURRENT_USER, SOFTWARE\MPC-HC\MPC-HC, ExePath
if ErrorLevel
{
	MsgBox, MPC-HC is either not installed or could not be found in the Windows registry.
	ExitApp
}
SplitPath, MPCHCPath, MPCHCExe

#Persistent
OnClipboardChange("ClipChanged")

ClipChanged()
{
	if copiedtext = %clipboard% ; clipboard identical to previous
		return
	copiedtext=%clipboard%
	if RegExMatch(copiedtext, "( |\t)") ; spaces in clipboard content
		return
	else if RegExMatch(copiedtext, "^https?:\/\/.*\.(mp4|mkv|avi|mpg|mpeg|m3u8|ogg|wmv|m2ts|mts|ts|mov|rm|rmvb|m4v|vob|webm|flv|3gp)[^\n ]*$") ; single URL
	{
		RegRead, MPCHCPath, HKEY_CURRENT_USER, SOFTWARE\MPC-HC\MPC-HC, ExePath
		if ErrorLevel
		{
			MsgBox, MPC-HC is either not installed or could not be found in the Windows registry.
			ExitApp
		}
		SplitPath, MPCHCPath, MPCHCExe
		TrayTip , URL2MPC-HC, % "Adding link to MPC-HC..." , 10
		if WinExist("ahk_exe " MPCHCExe)
			Run %MPCHCPath% "%clipboard%" /add
		else
			Run %MPCHCPath% "%clipboard%"
		WinWait, % "ahk_exe " MPCHCExe, , 15
		if WinExist("ahk_exe " MPCHCExe)
		{
			if !WinActive("ahk_exe " MPCHCExe)
				WinActivate, % "ahk_exe " MPCHCExe
		}
	}
	else if RegExMatch(copiedtext, "^(https?:\/\/.*\.(mp4|mkv|avi|mpg|mpeg|m3u8|ogg|wmv|m2ts|mts|ts|mov|rm|rmvb|m4v|vob|webm|flv|3gp)[^\n ]*`r`n){1,}https?:\/\/.*\.(mp4|mkv|avi|mpg|mpeg|m3u8|ogg|wmv|m2ts|mts|ts|mov|rm|rmvb|m4v|vob|webm|flv|3gp)[^\n ]*$") ; multiple URLs
	{
		temp := StrReplace(copiedtext,"/","\")
		if WinExist("ahk_exe " MPCHCExe)
		{
			if !WinActive("ahk_exe " MPCHCExe)
					WinActivate, % "ahk_exe " MPCHCExe
		}
		Sort, temp, \
		sortedString := StrReplace(temp,"\","/")
		URLArray := StrSplit(sortedString,"`r`n")
		FilenameArray := []
		Loop % URLArray.MaxIndex()
		{
			inVar := URLArray[A_Index]
			SplitPath, inVar, outVar
			FilenameArray[A_Index] := outVar
		}
		LinkArray := {}
		Loop, % FilenameArray.MaxIndex()
			LinkArray[FilenameArray[A_Index]] := URLArray[A_Index]
		linkcount=0
		for Filename, URL in LinkArray
		{
			linkcount++
		}
		TrayTip , URL2MPC-HC, % "Adding " . linkcount . " links to MPC-HC..." , 10
		counter=0
		for Filename, URL in LinkArray
		{
			this_link := URL
			if counter = 0
			{
				if !WinExist("ahk_exe " MPCHCExe)
					Run %MPCHCPath% "%this_link%" ; start playbaqck of first file
				else
					Run %MPCHCPath% "%this_link%" /add
				WinWait, % "ahk_exe " MPCHCExe, , 15
				if WinExist("ahk_exe " MPCHCExe)
				{
					if !WinActive("ahk_exe " MPCHCExe)
						WinActivate, % "ahk_exe " MPCHCExe
				}
				Sleep, 500
			}
			else
				Run %MPCHCPath% "%this_link%" /add
			Sleep, 750
			counter++
		}
	}
}
