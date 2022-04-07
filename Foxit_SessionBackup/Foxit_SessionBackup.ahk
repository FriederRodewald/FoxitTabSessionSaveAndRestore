#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Menu, Tray, Icon, Foxit_SessionBackup.ico 

Gui, Add, Text, x22 y20 w60 h20 , &Filename:
Gui, Add, Edit, r1 vFilename x82 y18 w300 h20
Gui, Add, Button, gSHOW_FILE_DIALOG x392 y18 w30 h20 , ...
Gui, Add, GroupBox, x22 y50 w400 h240 , Status
Gui, Add, Edit, v_Log x32 y70 w380 h210 , 
Gui, Add, Button, gBACKUP_ROUTINE Default x40 y295 w150 h40 , &Backup Session
Gui, Add, Button, gRESTORE_ROUTINE Default x250 y295 w150 h40 , &Restore Session
Gui, +alwaysOnTop 
 
Gui, Show, x1200 yCenter, Foxit Session Backup
return


Log = ""

BACKUP_ROUTINE:
Log = %Log%Do you have checked the LastSession-Box ?`nIf not: File -> Preferences -> History -> Restore last session...`n
Log = %Log%If done, close Foxit!`n`n
GuiControl, , _Log, %Log%
Sleep 2000
Log = %Log%-- waiting for Foxit to be closed --`n
GuiControl, , _Log, %Log%
; Looks if Foxit still running and continues backup if closed.
Loop
{
	Process, Exist, FoxitPDFEditor.exe
	IfWinNotExist, % "ahk_pid " errorlevel
		{
		Break
		}
Sleep 1000
}

Log = %Log%Starting Registry Editor`nExporting the Keys...`n
GuiControl, , _Log, %Log%

sleep 2000
; change the following line, if new Foxit version!
Run %comspec% /c "reg export "HKEY_CURRENT_USER\SOFTWARE\Foxit Software\Foxit PDF Editor 11.0\Preferences\History\LastSession" "%_Filename%"", ,UseErrorLevel
if ErrorLevel=0
 Log = %Log%Outcome : Session was exported and saved.`n`n
else
 Log = %Log%Outcome : %ErrorLevel%`n`n
GuiControl, , _Log, %Log%
; disable LastSession again 
RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Foxit Software\Foxit PDF Editor 11.0\Preferences\History\Options, bLastSession , 0
Run %Filename_dir% ;Open the destination folder
 
Return


RESTORE_ROUTINE:
Log = %Log%Starting Registry Editor`nWriting the Keys and Opening Foxit...`n
IfNotExist, HKEY_CURRENT_USER\SOFTWARE\Foxit Software\Foxit PDF Editor 11.0\Preferences\History\LastSession
 RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Foxit Software\Foxit PDF Editor 11.0\Preferences\History\LastSession

Run %comspec% /c "reg import "%_Filename%" ", ,UseErrorLevel
if ErrorLevel=0
 Log = %Log%Outcome : Success (Exit Code: 0)`n`n
else
 Log = %Log%Outcome : %ErrorLevel%`n`n

RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Foxit Software\Foxit PDF Editor 11.0\Preferences\History\Options, bLastSession, 1

GuiControl, , _Log, %Log%

Sleep 1000

Run, C:\Program Files (x86)\Foxit Software\Foxit PDF Editor\FoxitPDFEditor.exe,,, NewPID

Log = %Log%Closing Registry Editor and Running in Background until Foxit closes`nHave a Good Day...`n
GuiControl, , _Log, %Log%

Sleep 5000

Gui, Destroy

Loop
{
	Process, Exist, %NewPID%
	IfWinNotExist, % "ahk_pid " errorlevel
		{
		RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Foxit Software\Foxit PDF Editor 11.0\Preferences\History\Options, bLastSession , 0
		Break
		}
Sleep 5000
}

ExitApp

Return

 
SHOW_FILE_DIALOG:
FileSelectFile, _Filename, 2, , Select Backup Filename and Location, Registry Files (*.reg; *.txt)
SplitPath, _Filename, Filename_name, Filename_dir, Filename_ext, Filename_nameNoExt, Filename_drive
;Log = %Log%Name: %Filename_name%`nDir: %Filename_dir%`nExtension: %Filename_ext%`nName w/o Ext: %Filename_nameNoExt%`nDrive: %Filename_drive%`n`n
 
if _Filename !=
{
 if Filename_ext=
  _Filename = %_Filename%.reg
}
GuiControl, , Filename, %_Filename%
if _Filename !=
{
 Log = %Log%File to be saved : %_Filename%`n`n
 ;SplitPath, _Filename, Filename_name, Filename_dir, Filename_ext, Filename_nameNoExt, Filename_drive
 ;Log = %Log%Name: %Filename_name%`nDir: %Filename_dir%`nExtension: %Filename_ext%`nName w/o Ext: %Filename_nameNoExt%`nDrive: %Filename_drive%`n`n
 GuiControl, , _Log, %Log%
}
return
 
GuiClose:
ExitApp
ESC::ExitApp