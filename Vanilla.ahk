#Include %A_ScriptDir%\ahkpm-modules\github.com\pstaszko\AHK_PSKill\PSKill.ahk
#Include %A_ScriptDir%\ahkpm-modules\github.com\pstaszko\AHK-Notification\Growl.ahk
#include %a_scriptdir%\ahkpm-modules\github.com\pstaszko\AHK_Diagnostics\Vanilla_Diagnostics.ahk
#if
Standard_SendInput(txt){
	SendInput %txt%
}
WinActiveRegex(title){
	SetTitleMatchMode Regex
	return WinActive(title)
}
Run(target, workingDir:="",flags:=""){
	run %target%, %workingDir%, %flags%
}
MsgBox(text){
	msgbox,,%text%
}
WinNotActive(title,text:="",seconds:=0,excludeTitle:="",excludeText:=""){
	return WinActive(title,text,excludeTitle,excludeText)
}
WinWait(title,text:="",seconds:=0,excludeTitle:="",excludeText:=""){
	WinWait %title%,%text%,%seconds%,%excludeTitle%,%excludeText%
}
WinWaitNotActive(title,text:="",seconds:=0,excludeTitle:="",excludeText:=""){
	WinWaitNotActive %title%,%text%,%seconds%,%excludeTitle%,%excludeText%
}
WinWaitActiveNative(title,text:="",seconds:=0,excludeTitle:="",excludeText:=""){
	WinWaitActive %title%,%text%,%seconds%,%excludeTitle%,%excludeText%
}
WinWaitActive(titles,mode="default",timeout=0,delimiter="|",DetectHiddenText="default",Text=""){
	startingDetectHiddenText:=A_DetectHiddenText
	startingTitleMatchMode:=A_TitleMatchMode
	StartTime := A_TickCount
	if mode<>default
		SetTitleMatchMode(mode)
	if DetectHiddenText<>default
		DetectHiddenText %DetectHiddenText%
	loop
	{
		Loop Parse,titles,%delimiter%
		{
			t(a_loopfield " - " text)
			IfWinActive %A_LoopField%,%text%
			{
				SetTitleMatchMode("2")
				;wingetclass x,A
				;msgbox matched %A_LoopField% with %x%
				SetTitleMatchMode(startingTitleMatchMode)
				return 1
			}
			sleep 50
		}
		if timeout
		{
			if (A_TickCount - StartTime > Timeout)
			{
				SetTitleMatchMode("2")
				SetTitleMatchMode(startingTitleMatchMode)
				return 0
			}
		}
	}
	SetTitleMatchMode(startingTitleMatchMode)
	DetectHiddenText %startingDetectHiddenText%
}
WinClose(title,text:="",seconds:=0,excludeTitle:="",excludeText:=""){
	WinClose %title%,%text%,%seconds%,%excludeTitle%,%excludeText%
}
IsMaximized(simple:=0){
	global
	;simple=0
	if simple
	{
		WinGet MX, MinMax, A
		If MX
			return 1
		Else
			return 0
	} else {
		WinGetPos winx, winy, winw, winh, A
		if (winx=-4 and winy=-4 and winw=screenwidth+8 and winh=screenheight+28)
			return 1
		if ((winy=-4 or winy=(screenwidth/2)) and (winw=screenwidth or winw-8=((screenwidth)/2)))
			return 1
		return 0
	}
}
WinGetActiveID(){
	return WinGetID("A")
}
WinGetID(spec){
	WinGet id,id,%spec%
	return id
}
AutoRespondToDebugger(){
	t("AutoRespondToDebugger")
	WinWait("Choose Just-In-Time Debugger ahk_class #32770 ahk_exe vsjitdebugger.exe",,10)

	If ErrorLevel
		return
	WinActivate("Choose Just-In-Time Debugger ahk_class #32770 ahk_exe vsjitdebugger.exe")
	If WinActive("Choose Just-In-Time Debugger ahk_class #32770 ahk_exe vsjitdebugger.exe")
	{
		if !IsCapsLock()
		{
			sleep 250
			SendInput {end}{enter}
			growl("Sent")
		}
		WinWaitNotActive("Choose Just-In-Time Debugger ahk_class #32770 ahk_exe vsjitdebugger.exe",,3)
		If ErrorLevel
		{
			growl("Timed out")
			return
		}
		WinWaitActiveNative("ahk_exe devenv.exe",,1)
		If ErrorLevel
			growl("Timed out waiting for vs")
		else
		{
			;SetTitleMatchMode_RegEx()
			SetTitleMatchMode 2
			/*
			WinWaitActive Atomic.fs ahk_exe devenv.exe,,2
			If not ErrorLevel
			{
			*/
				SendInput ^w
				SendInput {F5}
			/*
			}else{
				t:=WinGetActiveTitle()
				growl("No dice on title. Got: " t)
			}
			*/
		}
	}
	sleep 3000
}
CloseMinorWindows(){
	GroupClose MinorWindows,a
	SetTitleMatchMode("3")
	WinClose Library ahk_class MozillaWindowClass ahk_exe firefox.exe
	WinClose smtp4dev ahk_exe smtp4dev.exe
}
CloseWindowsExplorerWindows(forceIE,level:=1){
	global
	WinGet id,id,A

	_CloseWindowsExplorerWindows(forceIE, level)

	WinActivate ahk_id %id%
	If WinNotActive("ahk_id " id)
	{
		loop 10
		{
			sleep 100
			WinActivate ahk_id %id%
			IfWinActive ahk_id %id%
				return
		}
	}
}
_CloseWindowsExplorerWindows(forceIE,level:=1){
	global
	If NoClose
		return
	DetectHiddenWindows On
	DetectHiddenWindows Off
	WinHide Terminal server connection
	CloseMinorWindows()
	if level=2
	{
		CloseMinorWindows()
		GroupClose MinorWindowsLevel2,a
		_CloseWindowsExplorerWindows(0,1)
		;CloseWindowsExplorerWindows(0,2) ;recursive loop
	}
	if forceIE
		WinClose ahk_class IEFrame
	GroupClose MSIE, A

	DetectHiddenWindows On
	WinClose Terminal Services Manager
	WinHide Windows Task Manager
}
WinControlEscape(){
	If (A_PriorHotkey <> "Esc" or A_TimeSincePriorHotkey > 750)
		CloseWindowsExplorerWindows(0,2)
	else
		CloseWindowsExplorerWindows(0)
	KeyWait esc
}
Calling(fn, arg1:="", arg2:=""){
	announce:=false
	if(fn = "WinMaximize") ;ok
		announce:=true
	if(announce){
		t("Calling " fn ", " arg1 ", " arg2)
	}
}
MaxFunction(ForceSingleMonitor:=0,ForceToRight:=0,ForceToLeft:=0){
	global
	;t("Max " A_ScriptFullPath)
	WinGet hwin,ID,A
	IfWinActive ahk_group NoMax
		return
	if IsDesktop()
		return false

	AssertNotSciteFindWindow()
	If WinActive("Find in Files ahk_class #32770")
		ListLines
	If WinActive("ahk_group NoMax")
		return
	;logHere("Maximize")
	If WinActive("ahk_id " hwin)
	{
		WinMaxFromHwnd(hwin)
		;logHere("maximize " hwin)
	}else{
		;logHere("skipped maximize " hwin)
	}
}
MaxFn(){
	Calling("WinMaximize", "A")
	WinMaximize A ;ok
}
WinMaxFromHwnd(hwnd){
	MaximizeFromHwnd(hwnd)
}
MaximizeFromHwnd(hwnd){
	;Calling("WinMaximize", "DetectHiddenWindows off", "ahk_id " hwnd)
	DetectHiddenWindows off
	WinMaximize ahk_id %hwnd% ;ok
}
LoadGlobalVars(){
	GLOBAL PaulDir:="c:\dev\Paul\"
	GLOBAL log4net:=true
	GLOBAL MyPath:=new psPath()
	;GLOBAL PsPath:=new psPath()
	GLOBAL dev:="c:\dev\"
	GLOBAL kpError:="C:\Users\Paul\AppData\Local\kp\kperror.txt"
	GLOBAL kpResp:="C:\Users\Paul\AppData\Local\kp\kpresp.json"
	GLOBAL kpReq:="C:\Users\Paul\AppData\Local\kp\kpreq.txt"
	GLOBAL globalVariables:=Object()
}
/*
GetBits(){
	EnvGet progVar,ProgramFiles(x86)
	if progVar
		return 64
	else
		return 32
}
*/
RunOrSwitchClass(cmdLine, ROSCtitle,Class,Regex:=0){
	startingTitleMatchMode:=A_TitleMatchMode
	If Regex
		SetTitleMatchMode("regex") ;swapped
	Winactivate %ROSCtitle% ahk_class %class%
	WinGetActiveTitle x
	WinGetClass c, A
	hit:=0
	If Regex
	{
		IfWinActive %ROSCtitle% ahk_class %class%
			Hit:=1
	} else {
		If Instr(x,ROSCtitle) and Instr(c,Class)
			Hit:=1
	}
	If Hit
	{
		tDebug("Hit")
		Max()
	} else {
		tDebug("No Hit")
		If WinExist(ROSCtitle " ahk_class " class)
			TempTooltip("1 Failed to show: " . ROSCtitle,2000)
		else {
			TempTooltip(ROSCtitle,1500)
			If FileExist(cmdLine) {
				tDebug("FileExist(cmdLine)")
				RunFailover(cmdLine)
			} else {
				tDebug("FileExist false " cmdLine)
				StringReplace cmdLine,cmdLine,Program Files,Program Files (x86)
				If FileExist(cmdLine)
				{
					tDebug("If FileExist(cmdLine) #2")
					RunFailover(cmdLine)
				} else {
					tDebug("If FileExist(cmdLine) #3")
					StringReplace cmdLine,cmdLine,Program Files (x86),Program Files
					RunFailover(cmdLine)
				}
			}
			SetTitleMatchMode(startingTitleMatchMode)
			return true
		}
	}
	SetTitleMatchMode(startingTitleMatchMode)
	return false
}
WinHideActive(){
	t:=WinGetActiveTitle()
	t("Minimizing " t " instead of hiding")
	WinMinimize A
}
#if
RunFailover(cmd,NoMax:=0,AllowRetry:=1){
	If NoMax
	{
		Loop %cmd%
			x:=A_LoopFileDir
		;x.shout
		Run %cmd%,%x%,UseErrorLevel
		If Errorlevel
		{
			if (cmd.startswith("w:") and AllowRetry)
			{
				run w:
				sleep 100
				RunFailover(cmd,NoMax,0)
			}
			autoYes:=0
			if cmd=iis
				autoYes:=1
			if cmd=tsadmin
				autoYes:=1
			if not AutoYes
			{
				msgbox 4, Prompt,Fail over for "%cmd%"?
				IfMsgBox Yes
					AutoYes:=1
			}
			if AutoYes
			{
				SendInput #r
				WinWait("Run ahk_class #32770")
				IfWinNotActive Run ahk_class #32770,,WinActivate, Run ahk_class #32770
				WinWaitActive Run ahk_class #32770
				SendInput !o%cmd%{enter}
			}
		}
	} else {
		OutDir:=""
		IfExist % cmd
			SplitPath cmd, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		Run %cmd%,%OutDir%,UseErrorLevel max,PID
		WinActivate ahk_pid %pid%,,3
		If not ErrorLevel
		{
			WinWaitActive ahk_pid %pid%,,5
			If not ErrorLevel
				MaxFunction()
		}
	}
}
RunOrSwitch(cmdLine, ROStitle,NoMax:=0,Class:="",Group:="",ForceSingleMonitor:=0,ForceToRight:=0,ForceToLeft:=0,TipTitle:=""){
	global ROSCount
	global RunOrSwitch_Recursion_Level
	;msgbox hi1
	WinClose Search ahk_class Windows.UI.Core.CoreWindow ahk_exe SearchHost.exe
	logParams()
	logHere("Recursion level: " RunOrSwitch_Recursion_Level)
	ROSCount+=1
	ThisROSCount:=ROSCount
	RunOrSwitch_Recursion_Level+=1
	WinShow % ROStitle
	if !TipTitle
		TipTitle:=ROStitle
	If cmdLine=tsadmin
	{
		If PostXP()
		{
			cmdLine:="tsadmin.msc"
		}
		If PostVista()
			ROStitle:="Remote Desktop Services Manager"
	}
	x:=""
	Full:=ROStitle
	Exclude=""
	If Class
		Full=%Full% ahk_Class %Class%
	If Group
		Full=%Full% ahk_Group %Group%
	;logHere("Activate")
	WinActivate(Full,"",Exclude)
	if (ThisROSCount<ROSCount)
		return
	IfWinActive %Full%,,%Exclude%
	{
		If not NoMax
			IfWinNotActive A,Find and Replace
			{
				MaxFunction(ForceSingleMonitor,ForceToRight,ForceToLeft)
			}
	} else {
		IfWinExist %Full%,,%Exclude%
		{
			IfWinActive ahk_group AbortRecursiveDive
			{
				RunOrSwitch_Recursion_Level=0
				return true
			}
			if RunOrSwitch_Recursion_Level>5
			{
				AlertCallStack("Recursive dive maximum depth")
				return false
			}
			if RunOrSwitch_Recursion_Level>1
				t("Recursive dive: " RunOrSwitch_Recursion_Level)
			sleep 100
			RunOrSwitch(cmdLine, ROStitle,NoMax,Class,Group,ForceSingleMonitor,ForceToRight,ForceToLeft,TipTitle)
		} else {
			TempTooltip(TipTitle,1500)
			StringReplace cmdLine,cmdLine,`%username`%,%username%
			If FileExist(cmdLine)
				RunFailover(cmdLine,NoMax)
			else
			{
				StringReplace cmdLine,cmdLine,Program Files,Program Files (x86)
				RunFailover(cmdLine,NoMax)
			}
			RunOrSwitch_Recursion_Level=0
			return true
		}
	}
	RunOrSwitch_Recursion_Level=0
	return false
}
GetURLofExplorerWindow(){
	WinGetText txt,A
	RegExMatch(txt,"O)Address: (.*)", Match)
	;Match.Count.shout
	Return % Match.Value(1)
}
MySplitPath(InputVar,Byref OutFileName="",Byref OutDir="",Byref OutExtension="",Byref OutNameNoExt="",Byref OutDrive="",ByRef OutFolderName=""){
	SplitPath InputVar, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	if OutDir
	{
		d=%OutDir%
		RegExMatch(OutDir,"O).*\\([^\\]+$)", Match)
		OutFolderName:=Match.Value(1)
	}
}
Esc(x=1){
	SendInput {esc %x%}
}
Enter(x=1){
	t("Enter")
	SendInput {enter %x%}
}
GetReleasedEXE(name, additional=""){
	x=C:\Dev\Releases\%name%\Stable\%name%.exe %additional%
	return % x
}
/*
class WS_MQTT extends WebSocket
{
	Bonk(){
		return "bonked"
	}
	TrySend(Message){
		;t(message " - " this.readyState)
		;t(a " - " this.readyState)
		if this.readyState
		{
			try {
				;t(message)
				this.Send(Message)
			}
		}
	}

	OnOpen(Event){
		this.Closed := false
	}

	OnMessage(Event){
		;RunMySendMessageLabel(Event.data)
		MsgBox, % "Received Data: " Event.data
		this.Close()
	}

	OnClose(Event){
		this.Closed := true
		this.Disconnect()
	}

	OnError(Event){
		MsgBox Websocket Error %A_ScriptFullPath% %event%
	}

	__Delete(){
		;t("__Delete Fired")
	}
}
*/
/*
MqttPub(topic, message, host="localhost"){
	global mqtt
	;fileappend MQTTPUB %A_ScriptFullPath% - pub - %topic% / %message%`r`n, c:\temp\mqtt.txt
	static mqtt_history := {}
	z:=mqtt_history[topic]
	if(z <> message)
	{
		;mqtt.TrySend(topic "|||" message)

		run mosquitto_pub.exe -r -h %host% -t "%topic%" -m "%message%", , hide
		mqtt_history[topic]:=message
	}
}
*/
shout(this,title=""){
	_shout(this,title)
}
_shout(this,title=""){
	if !assert.quiet
		if title
			msgbox % title ": " this
		else
			msgbox % this
	;AlertCallStack()
}
tDebug(msg,delay=-1){
	global
	if delay>-1
		d:=delay
	else
		d:=tDebugDelay
	if tDebugOn
	{
		logHere(msg)
		if ShoutDebug
			shout(msg)
		else
			if tGrowlDebug
				growl("tDebug","Debugging",msg)
			else
				t(msg)
		if d
			sleep %d%
	}
}
WinGetActiveHwnd(){
	DetectHiddenWindows on
	winget hwnd, id, A
	return hwnd
}
Requires(var){
	if !var
		AlertCallStack("Missing Value")
}
CycleWindowOnEXE(x=0, mode=""){
	DetectHiddenWindows off
	if x > 5
		msgbox Abort deep dive in CycleWindowOnEXE
	WinGet exe,ProcessName,A
	;logHere(exe)
	exe:=EscapeName(exe)
	gn:="CycleWindow_" strreplace(exe,".","_")
	gn:=strreplace(gn,"-","_")
	gn:=strreplace(gn," ","_")
	if (gn = "CycleWindow_datagrip_exe" or gn = "CycleWindow_datagrip64_exe"){
		GroupAdd %gn%,ahk_exe ssms.exe,,,ahk_group NoCycleOnEXE
		;GroupAdd %gn%,ahk_exe Ssms.exe,,,ahk_group NoCycleOnEXE
	}
	if (gn = "CycleWindow_ssms_exe")
		GroupAdd %gn%,ahk_exe datagrip64.exe,,,ahk_group NoCycleOnEXE
	if (gn = "CycleWindow_devenv_exe")
		GroupAdd %gn%,ahk_exe rider64.exe,,,ahk_group NoCycleOnEXE
	if (gn = "CycleWindow_rider64_exe")
		GroupAdd %gn%,ahk_exe devenv.exe,,,ahk_group NoCycleOnEXE
	GroupAdd %gn%,ahk_exe %exe%,,,ahk_group NoCycleOnEXE
	GroupActivate %gn%, %mode%
	IfWinActive ahk_Group HideOnCycleEXE
	{
		WinHide ahk_group HideOnCycleEXE
		CycleWindowOnEXE(x+1)
	}
}
SParams(args*){
	return % Join(", ",args*)
}
GParams(args*){
	Join(", ",args*).g
}
_log(context,msg,synchronous=0,IncludePath=1){
	global Log4Net
	global Log4Net_Last
	global Log4Net_ForceSynchronous
	global Log4Net_ForceAsynchronous
	global Log4Net_Contexts
	last:=Log4Net_Last
	Log4Net_Last:=A_TickCount
	contextStart:=Log4Net_Contexts[context]
	msg:=SubStr(msg,1,15001)
	if(Log4Net_ForceSynchronous && Log4Net_ForceAsynchronous){
		msgbox % "Log4Net_ForceSynchronous && Log4Net_ForceAsynchronous = true. Invalid Config. (Log4Net: " Log4Net ")"
		return
	}
	if Log4Net_ForceSynchronous
	{
		synchronous=1
		msg=*Sync: %msg%
	}
	if Log4Net_ForceAsynchronous
	{
		synchronous=0
		msg=*Async: %msg%
	}
	if !Log4Net
	{
		msg=AHK, "%c% - %msg%"
		return
	}
	c:=context
	if(IncludePath){
		SplitPath A_ScriptFullPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		x:=SubStr(OutFileName . "                      ",1,25)
		c:=x ": " context
	}
	elapsed:=Log4Net_Last-last

	if(contextStart)
	{
		elapsed:=elapsed . " / " (Log4Net_Last - contextStart)
	}

	msg=AHK, "%c% - %msg%"
	exe=C:\dev\Releases\WriteLog\Stable\writelog.exe
	IfExist % exe
	{
		cmd=%exe% %msg%
		x=hide
		if synchronous
			RunWait %cmd%,C:\DEV\uiauto\WriteLog\bin\Debug,%x%
		else
			run %cmd%,C:\DEV\uiauto\WriteLog\bin\Debug,%x%
	} else
		MsgBox missing C:\dev\Releases\WriteLog\Stable\writelog.exe
}
URLDownloadToVar(url){
	hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	hObject.Open("GET",url)
	hObject.Send()
	return hObject.ResponseText
}
CurrentEXE(){
	WinGet ProcessName,ProcessName
	return ProcessName
}
EscapeName(name){
	a:=StrReplace(name,"+","_plus_")
	return %a%
}
GetActiveTitle(){
	WinGetActiveTitle x
	return x
}
RunDesktopRDP(File){
	t("RDP: " file)
	SetTitleMatchMode regex
	WinActivate i)^%File%\b ahk_exe mstsc.exe
	IfWinNotActive i)^%File%\b ahk_exe mstsc.exe
	{
		a:=userprofile "\Desktop\" File ".RDP"
		b:=userprofile "\Desktop\RDP\" File ".RDP"
		x:=FirstValidPath(a,b)
		IfExist % x
			run % x
		else
			msgbox missing %a% and %b%
	} else {
		;t("a")
	}
}
GetModifiers(){
	x:=""
	if GetKeyState("Shift")
		x .= ",Shift"
	if GetKeyState("Alt")
		x .= ",Alt"
	if GetKeyState("Control")
		x .= ",Control"
	return x
}
ConvertCricketPathToDevPath(path){
	return % RegExReplace(path,"i)^c:\\inetpub\\Intranet(test)?","C:\dev\WesternCap\Cricket.Intranet")
}
ChangeOffset(delta){
	global
	mOffset+=delta
	if mOffset<=0
		mOffset=1
	t(mOffset)
}
AppendToActiveTitle(strAppend){
	WinGetActiveTitle activeTitle
	SetActiveTitle(activeTitle strAppend)
}
SetActiveTitle(strTitle){
	WinSetTitle A,,%strTitle%
}
StripFromActiveTitle(strStrip){
	WinGetActiveTitle activeTitle
	activeTitle.Strip(strStrip)
	SetActiveTitle(activeTitle)
}
ToggleZoom(){
	IfWinActive - Maxed
	{
		StripFromActiveTitle(" - Maxed")
		SendInput ^0
	} else {
		AppendToActiveTitle(" - Maxed")
		SendInput !^0
	}
}
T(msg,duration=2000){ ;t()
	TempToolTip(msg,duration)
}
TempTooltip(TTTtitle,duration){
	global
	Tooltip %TTTtitle%
	SetTimer("RemoveToolTip",duration)
}
TempTooltipSimple(TTTtitle){
	TempTooltip(TTTtitle, 2000)
}
RemoveToolTip:
	SetTimer RemoveToolTip, Off
	ToolTip
return
IsWinActive(WinTitle, WinText="", ExcludeTitle="", ExcludeText=""){
	IfWinActive %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
		return 1
	else
		return 0
}
IsWinActiveRegex(WinTitle, WinText="", ExcludeTitle="", ExcludeText=""){
	SetTitleMatchMode regex
	IfWinActive %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
		return 1
	else
		return 0
}
WinActivate(WinTitle, WinText="", ExcludeTitle="", ExcludeText=""){
	WinActivate %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	IfWinActive %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
		return 1
	else
		return 0
}
WinActivateRegex(WinTitle, WinText="", ExcludeTitle="", ExcludeText=""){
	SetTitleMatchMode regex
	WinActivate %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	;t:=wingetactivetitle()
	IfWinActive %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
		ret=1
	else
		ret=0
	return %ret%
}
WinShowAndActivateRegex(WinTitle, WinText="", ExcludeTitle="", ExcludeText=""){
	SetTitleMatchMode regex
	WinShow %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	WinActivate %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	IfWinActive %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
		ret=1
	else
		ret=0
	return %ret%
}
ToggleAlwaysOnTop(){
	WinGetTitle title, A
	StringLeft title2,title,1
	WinSet AlwaysOnTop,toggle,A
	WinGet ExStyle, ExStyle, A
	if (ExStyle & 0x8)
	{
		T("Always on top: " title)
		return 1
	} else {
		T("Not always on top: " title)
		return 0
	}
}
ClickAndReturn(x,y,cnt=1,mode="ul",TitleX="",shift=false){
	SetDefaultMouseSpeed 0
	SetTitleMatchMode 2
	CoordMode Mouse,Screen
	MouseGetPos xx1, yy1
	CoordMode Mouse,Relative
	if shift
		SendInput {shift down}
	if mode=lr
	{
		WinGetPos X1, Y1, Width, Height,A
		x:=Width-x-4
		y:=Height-y-4
	}
	else if mode=ll
	{
		WinGetPos X1, Y1, Width, Height,A
		y:=Height-y-4
	}
	else if mode=ur
	{
		WinGetPos X1, Y1, Width, Height,A
		x:=Width-x-4
	}
	if (!Titlex or WinActive(TitleX))
	{
		click %x%,%y%,%cnt%
		CoordMode Mouse,Screen
		MouseMove xx1, yy1,0
	}
	else
	{
		growl("Safely aborted click: " x ", y: " y ", mode:" mode ". Looking for window: " titlex ", but found: " GetActiveTitle())
	}
	if shift
		SendInput {shift up}
}
Click(x, y){
	CoordMode mouse, relative
	click %x%, %y%
}
RightClickHere(){
	click right
}
RightClick(x, y){
	CoordMode mouse, relative
	click right, %x%, %y%
}
ImageSearch(X1, Y1, X2, Y2, ImageFile){
	ImageSearch x,y,%x1%,%y1%,%x2%,%y2%,*10 %imagefile%
	ret=%x%,%y%
	if x
		return %ret%
	else
		return
}
RememberMouse(){
	global screen_mouse_x
	global screen_mouse_y
	CoordMode mouse, screen
	mousegetpos x,y
	screen_mouse_x=%x%
	screen_mouse_y=%y%
}
RestoreMouse(){
	global screen_mouse_x
	global screen_mouse_y
	CoordMode mouse, screen
	MouseMove %screen_mouse_x%, %screen_mouse_y%
}
DoubleClickTaskTray(x,y){
	RememberMouse()
	WinActivate ahk_class Shell_TrayWnd ahk_exe Explorer.EXE
	CoordMode mouse, relative
	WinActivate ahk_class Shell_TrayWnd ahk_exe Explorer.EXE
	click(x, y)
	sleep 50
	click(x, y)
	RestoreMouse()
}
WinGetList(title){
	detecthiddenwindows on
	SetTitleMatchMode Regex
	WinGet arr, List, %title%
	z:=""
	Loop %arr%
	{
		element := arr%A_Index%
		z:=z element "`r`n"
	}
	return % z
}
WinResizeFromHwnd(hwnd, width, height){
	wingetpos x,y,w,h,a_ahkid %hwnd%
	winmove a_ahkid %hwnd%,,%x%,%y%,%width%,%height%
}
WinWaitTimeout(title,timeoutSeconds){
	WinWait %title%,,%timeoutSeconds%
	if errorlevel
		return "false"
	else
		return "true"
}
WinWaitClose(title,timeoutSeconds){
	WinWaitClose %title%,,%timeoutSeconds%
	if errorlevel
		return "false"
	else
		return "true"
}
WinExists(winSpec, DetectHiddenWindows){
	DetectHiddenWindows %DetectHiddenWindows%
	IfWinExist %winspec%
		return "true"
	else
		return "false"
}
WinExistsFull(winSpec,DetectHiddenWindows,TitleMatchMode){
	DetectHiddenWindows %DetectHiddenWindows%
	SetTitleMatchMode %TitleMatchMode%
	IfWinExist %winspec%
		return "true"
	else
		return "false"
}
WinHideFromHwnd(hwnd){
	WinHide ahk_id %hwnd%
}
WinMoveFromHwnd(hwnd,x,y){
	WinMove ahk_id %hwnd%,,x,y
}
WinShowFromHwnd(hwnd){
	DetectHiddenWindows on
	WinShow ahk_id %hwnd%
}
WinCloseFromHwnd(hwnd){
	DetectHiddenWindows on
	WinClose ahk_id %hwnd%
}
WinActivateByExe(exe){
	DetectHiddenWindows off
	SetTitleMatchMode regex
	WinActivate .*\w+.* ahk_exe %exe%
}
WinRestoreTitle(title){
	DetectHiddenWindows off
	WinRestore %title%
	IfWinActive %title%
		return "true"
	else
		return "false"
}
WinActivateTitle(title){
	DetectHiddenWindows off
	WinActivate %title%
	IfWinActive %title%
		return "true"
	else
		return "false"
}
WinActivatePID(hwnd){
	return % WinActivateTitle("ahk_pid " hwnd)
}
WinRestorePID(hwnd){
	return % WinRestoreTitle("ahk_pid " hwnd)
}
WinShowTitle(title){
	DetectHiddenWindows on
	winshow %title%
}
WinActivateTitleRegexVisibleOnly(titlex){
	SetTitleMatchMode 2
	SetTitleMatchMode regex
	DetectHiddenWindows off
	WinActivate %titlex%
	IfWinActive %titlex%
		ret:=true
	else
		ret:=false
	return %ret%
}
WinActivateTitleRegex(titlex){
	SetTitleMatchMode 2
	SetTitleMatchMode regex
	DetectHiddenWindows on
	WinShow %titlex%
	WinActivate %titlex%
	IfWinActive %titlex%
		ret:=true
	else
		ret:=false
	return %ret%
}
WinGetPIDFromHwnd(hwnd){
	DetectHiddenWindows on
	winget pid, pid, ahk_id %hwnd%
	return %pid%
}
WinGetHwndFromPID(pid){
	DetectHiddenWindows on
	WinGet hwnd, id, ahk_pid %pid%
	return %hwnd%
}
WinGetHwndFromExe(exe){
	DetectHiddenWindows on
	WinGet hwnd, id, ahk_exe %exe%
	return %hwnd%
}
WinGetActivePID(){
	WinGet pid, pid, A
	return %pid%
}
WinGetExe(hwnd){
	WinGet retVal,ProcessPath,ahk_id %hwnd%
	return % retVal
}
WinGetVisible(hwnd){
	IfWinExist ahk_id %hwnd%
		return % true
	else
		return % false
}
WinGetText(hwnd){
	DetectHiddenWindows on
	WinGetText OutputVar, ahk_id %hwnd%
	return % OutputVar
}
WinGetTitle(winSpec){
	WinGetTitle t,%winSpec%
	return % t
}
ActivateFromHwnd(hwnd){
	WinActivate ahk_id %hwnd%
}
RestoreFromHwnd(hwnd){
	winRestore ahk_id %hwnd%
}
WinGetTitleFromPID(pid){
	DetectHiddenWindows on
	WinGetTitle title, ahk_pid %pid%
	if !title
		title:=""
	return % title
}
/*
logMsg(script,fnc,txt){
	FileAppend ``%script% | %fnc% | %txt%```r`n, C:\Dev\Desire\log.md
}
*/
WinGetTitleFromHwnd(hwnd){
	DetectHiddenWindows on
	WinGetTitle title, ahk_id %hwnd%
	if !title
		title:=""
	;logMsg(A_ScriptFullPath, a_thisfunc, hwnd " " title)
	return % title
}
MinimizeFromHwnd(hwnd){
	DetectHiddenWindows off
	WinMinimize ahk_id %hwnd%
}
WinGetPositionFromHwnd(hwnd){
	WinGetPos X, Y, Width, Height, ahk_id %hwnd%
	ret=%X%|%Y%|%Width%|%Height%
	return %ret%
}
WinGetClassFromHwnd(hwnd){
	DetectHiddenWindows on
	WinGetClass x, ahk_id %hwnd%
	return % x
}
GetHWnds(winSpec,DetectHiddenWindows,wintext="",excludeSpec=""){
	DetectHiddenWindows %DetectHiddenWindows%
	WinGet process, PID, %winSpec%, %wintext%, %excludeSpec%
	return % GetHWndsByPID(process,DetectHiddenWindows,wintext,excludeSpec)
}
GetHWndsByPID(PID,DetectHiddenWindows,wintext="",excludeSpec=""){
	DetectHiddenWindows %DetectHiddenWindows%
	WinGet winIDs, List, ahk_pid %pid%
	titles:=""
	Loop %winIDs%
	{
		title:=winids%A_Index%
		if title
			titles=%titles%`r%title%
	}
	return % RegExReplace(titles,"^\s","")
}
GetTitles(winSpec){
	WinGet process, PID, %winSpec%
	WinGet winIDs, List, ahk_pid %process%
	titles:=""
	Loop %winIDs%
	{
		id := winids%A_Index%
		WinGetTitle title, ahk_id %id%
		if title
			titles=%titles%`r%title%
	}
	return % RegExReplace(titles,"^\s","")
}
GetHwndsNew(winSpec){
	SetTitleMatchMode regex
	WinGet process, PID, %winSpec%
	WinGet winIDs, List, ahk_pid %process%
	titles:=""
    Loop %winIDs%
	{
		title := winids%A_Index%
		if title
			titles=%titles%`r%title%
	}
	return % RegExReplace(titles,"^\s","")
}
GetAllHwnds(){
	SetTitleMatchMode regex
	DetectHiddenWindows on
	WinGet winIDs, List, \w+,,(Default IME|MSCTFIME UI|.*BroadcastEventWindow.*|CiceroUIWndFrame|DDE Server Window|MediaContextNotificationWindow)
	titles:=""
    Loop %winIDs%
	{
		title := winids%A_Index%
		if title
			titles=%titles%`r%title%
	}
	return % RegExReplace(titles,"^\s","")
}
GetPidsByWinSpec(winSpec){
	SetTitleMatchMode regex
	WinGet winIDs, List, %winSpec%
	titles:=""
    Loop %winIDs%
	{
		id := winids%A_Index%
		WinGet title, PID, ahk_id %id%
		if title
			titles=%titles%`r%title%
	}
	return % RegExReplace(titles,"^\s","")
}
GetMousePosition(mode){
	CoordMode Mouse %mode%
	MouseGetPos x, y
	ret=%mode%,%x%,%y%
	return % ret
}
g(message,title="AHK Message",MessageType="Standard Message"){
	Growl(message,title,MessageType)
}
Close(){
	WinClose A
}
SetTitleMatchMode(mode){
	Requires(mode)
	SetTitleMatchMode %mode%
}
MinFn(){
	WinMinimize A
}
Restore(){
	WinRestore A
}
MinmizeAllButActiveWindow(){
	WinGet id,id,A
	SendInput #d
	WinWaitNotActive ahk_id %id%
	WinActivate ahk_id %id%
}
SetTimer(timer, interval){
	global TimerLog
	ThisTimer=%timer%

	If IsLabel(ThisTimer){
		;log(A_ThisFunc,"Timer Set: " ThisTimer " for " interval " ms",0)
		SetTimer %ThisTimer%,%interval%
	}else{
		;log(A_ThisFunc,"Timer not found: " ThisTimer,0)
	}
}
KeyWaitModifiersUp(){
		keywait = Ctrl|Alt|Shift|LWin|RWin
		Loop Parse, keywait, |
			KeyWait %A_LoopField%
	}
IsControlDown(){
	If getkeystate("control")
		return % true
	else
		return % false
}
IsShiftDown(){
	If getkeystate("shift")
		return % true
	else
		return % false
}
WorkComputer(){
	if computername=rad
		return true
	if computername=raven
		return true
	if computername=bmo
		return true
	else
		return false
}
FileCopy(SourcePattern, DestPattern, Replace=1,attempts=1){
	if attempts>1
	{
		loop % attempts-1
			try
			{
				FileCopy %SourcePattern%, %DestPattern%, %Replace%
				if !errorlevel
					return
			} catch e {
				t("Retrying to copy " SourcePattern)
			}
	}
	try
	{
		FileCopy %SourcePattern%, %DestPattern%, %Replace%
		if errorlevel
			msgbox Could not copy %sourcepattern% to %destpattern% due to error(s)
	} catch e {
		msg=
		(
File copy exception:
Source: %sourcepattern%
Dest: %destpattern%
Exception: %e%
Errorlevel: %ErrorLevel%
Last Error: %A_LastError%
		)
		em:=e.message
		msg=%msg%`nException Message: %em%
		growl(msg)
	}
}
CopyIfDifferent(source,destination){
	src:=new FileStats(source)
	dest:=new FileStats(destination)
	if (!dest.exists or src.sizeb<>dest.sizeb or src.ModTime<>dest.ModTime){
		FileCopy(source,destination)
	}
}
MyRTrim(str,OmitChars = " `t`n"){
	return % Rtrim(str,OmitChars)
}
MyLTrim(str,OmitChars = " `t`n"){
	return % ltrim(str,OmitChars)
}
MyTrim(this,OmitChars = " `t`r`n"){ ;;ext
	return % Rtrim(ltrim(this,OmitChars),OmitChars)
}
RequiredFile(filePath){
	IfExist % filepath
		return true
	msgbox Missing file: %filepath%
	return false
}
CreateSymbolicLink(real,fake){
	global
	exe=%pauldir%Util\Linkd\linkd.exe
	if RequiredFile(exe)
		RunWait %exe% %fake% %real%
}
DoKeepass(Long){
	global
	WinActivate KeePass ahk_exe KeePass.exe,,GDI
	IfWinActive KeePass ahk_exe KeePass.exe,,GDI
		return
	WinActivate Open Database ahk_exe KeePass.exe,,GDI
	IfWinActive Open Database ahk_exe KeePass.exe,,GDI
		return
	t("Keepass")
	rd:="C:\Users\Paul\scoop\apps\keepass\current\"
	FileGetVersion v1,%rd%KeePass.exe
	FileGetVersion v2,C:\Program Files (x86)\KeePass Password Safe 2\KeePass.exe
	if (v1<>v2)
	{
		msgbox Keepass does not appear to be symbolically linked (the folder under C:\Program Files (x86) may just need to be deleted or renamed)
	}
	kpdir=C:\Program Files (x86)\KeePass Password Safe 2
	IfNotExist %kpdir%
	{
		msgbox initializing keepass symbolic link
		CreateSymbolicLink(rd,"""" kpdir """")
	}
	kpdir:=MyTrim(kpdir,"""")
	pathx:=firstvalidpath(kpdir "\KeePass.exe")
	rd:=rd "Plugins\"
	old:=false
	old:=true

	if old {
		CopyIfDifferent("C:\dev\UIauto\KeePassMaster\bin\KeePassMaster.dll",rd "KeePassMaster.dll")
		CopyIfDifferent("C:\dev\UIauto\KeePassMaster\bin\KeePassMasterInterface.dll",rd "KeePassMasterInterface.dll")
		CopyIfDifferent("C:\dev\UIauto\KeePassMaster\bin\Newtonsoft.Json.dll",rd "Newtonsoft.Json.dll")
	} else {
		CopyIfDifferent("C:\Dev\FlowPass\FlowPassKP\bin\Debug\FlowPassKP.dll",rd "FlowPassKP.dll")
		CopyIfDifferent("C:\Dev\FlowPass\FlowPassKP\bin\Debug\FSharp.Core.dll",rd "FSharp.Core.dll")
		CopyIfDifferent("C:\Dev\FlowPass\FlowPassKP\bin\Debug\FSharp.Data.dll",rd "FSharp.Data.dll")
		CopyIfDifferent("C:\Dev\FlowPass\FlowPassKP\bin\Debug\KeePass.XmlSerializers.dll",rd "KeePass.XmlSerializers.dll")
		CopyIfDifferent("C:\Dev\FlowPass\FlowPassKP\bin\Debug\KeePassMasterInterface.dll",rd "KeePassMasterInterface.dll")
		CopyIfDifferent("C:\Dev\FlowPass\FlowPassKP\bin\Debug\Newtonsoft.Json.dll",rd "Newtonsoft.Json.dll")
	}
	t("Going long")
	key=1
	if key
	{
		k:=ReferenceManager.DropboxPath() "Keys\Key.key"
		k:=FirstValidPath("c:\key.key",k)
		if k
		{
			;msgbox % dropbox
			;full=%pathx% "%dropbox%fastball" -preselect:"%k%"
			full=%pathx% "c:\dropbox\fastball" -preselect:"%k%"
			run %full%
		}
		else
			t("No valid path for key " q)
	} else {
		run %pathx% "%dropbox%fastball"
	}
}
Hide(){
	WinHideActive()
}
Bailing(){
	logHere(GetCallStack)
	t("Bailing func")
}
CheckIfFileExists(pathToCheck,quiet=1){
	hit:=FileExist(pathToCheck)
	if !quiet
		if hit
			logHere(a_thisfunc,"Exists:     " pathToCheck)
		else
			logHere(a_thisfunc,"Not Exists: " pathToCheck)
	return % hit
}
FirstValidPath(pathsArray*){
	global FirstValidPath_ApplicationDrives
	for index,paths in pathsArray
	{
		Loop parse, paths, `,
		{
			if CheckIfFileExists(A_LoopField)
				return %A_LoopField%
			loop % FirstValidPath_ApplicationDrives.length()
			{
				el:=FirstValidPath_ApplicationDrives[A_Index]
				StringReplace CtoElement,A_LoopField,c:,%el%:
				if CheckIfFileExists(CtoElement)
					return %CtoElement%
			}
			z:=A_LoopField
			DriveGet list, list,fixed
			loop parse, list
				if a_loopfield<>c
				{
					StringReplace CtoWhatever,z,c:,%A_LoopField%:
					if CheckIfFileExists(CtoWhatever)
						return %CtoWhatever%
				}

			StringReplace RemoveX86,A_LoopField,Program Files (x86),Program Files
			if CheckIfFileExists(RemoveX86)
				return %RemoveX86%

			StringReplace RemoveX86,CtoD,Program Files (x86),Program Files
			if CheckIfFileExists(RemoveX86)
				return %RemoveX86%

			StringReplace RemoveX86,CtoE,Program Files (x86),Program Files
			if CheckIfFileExists(RemoveX86)
				return %RemoveX86%

			StringReplace SwitchToX86,A_LoopField,Program Files,Program Files (x86)
			if CheckIfFileExists(SwitchToX86)
				return %SwitchToX86%

			StringReplace SwitchToX86,CtoD,Program Files,Program Files (x86)
			if CheckIfFileExists(SwitchToX86)
				return %SwitchToX86%

			StringReplace SwitchToX86,CtoE,Program Files,Program Files (x86)
			if CheckIfFileExists(SwitchToX86)
				return %SwitchToX86%
		}
	}
	return
}
GetWindowsID(){
	i=0
	if IsXP()
		return % i
	i+=1
	if IsVista()
		return % i
	i+=1
	if Is7()
		return % i
	i+=1
	if Is8()
		return % i
	i+=1
	if Is10()
		return % i
	i+=1
	/*
	if Is11()
		return % i
	*/
	i+=1
	return % i
}
RegExMatch_(haystack,needle){
	x:=RegExMatch(haystack,needle)
	return % x
}
IsXP(){
	return % RegExMatch_(A_OSVersion, "i)win_xp")
}
IsVista(){
	return % RegExMatch_(A_OSVersion, "i)Win_Vista")
}
Is7(){
	return % RegExMatch_(A_OSVersion, "i)win_7.*")
}
Is8(){
	return % RegExMatch_(A_OSVersion, "i)win_8.*")
}
Is10(){
	return % RegExMatch_(A_OSVersion, "i)10\.")
}
/*
Is11(){
	return % RegExMatch_(A_OSVersion, "i)11\.")
}
*/
PostXP(){
	return % GetWindowsID() > 0
}
PostVista(){
	return % GetWindowsID() > 1
}
Post7(){
	return % GetWindowsID() > 2
}
Post8(){
	return % GetWindowsID() > 3
}
Post10(){
	return % GetWindowsID() > 4
}
Post11(){
	return % GetWindowsID() > 5
}
ClassUnderMouse(){
	MouseGetPos OutputVarX, OutputVarY, OutputVarWin, OutputVarControl
	t(OutputVarControl)
	return % OutputVarControl
}
ShowExplorer(){
	global
	if Post7()
		IfWinExist This PC ahk_class CabinetWClass ahk_exe Explorer.EXE
			WinActivate This PC ahk_class CabinetWClass ahk_exe Explorer.EXE
		else
			run %dropbox%shortcuts\Windows10MyComputer.lnk
	else
		IfWinExist Computer ahk_class CabinetWClass
			WinActivate Computer ahk_class CabinetWClass
		else
			send #e

	if Post7()
		IfWinExist This PC ahk_class CabinetWClass ahk_exe Explorer.EXE
			t("WinActivate This PC ahk_class CabinetWClass ahk_exe Explorer.EXE")
		else
			t("run %dropbox%shortcuts\Windows10MyComputer.lnk")
	else
		IfWinExist Computer ahk_class CabinetWClass
			t("WinActivate Computer ahk_class CabinetWClass")
		else
			t("send #e")
}
/*
StrSplitFug(ByRef text, delimiter := "", omitChars := ""){
	; Using ByRef for performance (you can pass non-variables too)
	ret := []
	Loop, Parse, text, % delimiter, % omitChars
		ret.Insert(A_LoopField)
	return ret
}
*/
SendAppsKey(){
	KeyWait alt
	KeyWait Ctrl
	KeyWait shift
	SendInput {AppsKey}
}
/*
MakeLessTransparent(){
	WinGet, t, Transparent, A
	WinSet, Transparent, % t+10, A
	return
}
MakeMoreTransparent(){
	WinGet, t, Transparent, A
	t :=  (t == "" ? 255 : t)
	WinSet, Transparent, % t-10, A
	return
}
*/
IsDesktop(){
	IfWinActive Program Manager ahk_class Progman ahk_exe explorer.exe
		return true
	IfWinActive  ahk_class WorkerW ahk_exe explorer.exe
		return true
	return false
}
GetProcessName(winspec){
	winget x,processname,%winspec%
	return %x%
}
GetProcessPID(winspec){
	winget x,PID,%winspec%
	return %x%
}
AssertNotSciteFindWindow(){
	hit=0
	IfWinActive Find ahk_class #32770
		hit=1
	IfWinActive Replace ahk_class #32770
		hit=1
	IfWinActive Find in Files ahk_class #32770
		hit=1
	if hit
		If GetProcessName("A")="scite.exe"
		{
			AlertCallStack("Why is this happening, maximizing this stupid window?")
		}
}
/*
ForticlientAutoDisconnecter(){
	IfWinActive FortiClient ahk_class Chrome_WidgetWin_1 ahk_exe FortiClient.exe
	{
		start:=A_Now
		Loop{
			if A_Now > (start + 1000 * 60 * 2)
			{
				ClickAndReturn(418,603)
				sleep 1000
				ClickAndReturn(418,603)
				WinWaitNotActive FortiClient ahk_class Chrome_WidgetWin_1 ahk_exe FortiClient.exe
				break
			}
			sleep 100
		}
	}
}
*/
WinGetActiveTitle(){
	WinGetActiveTitle x
	return % x
}
DiffMerge_ClearSavedPaths(){
	FileDelete c:\temp\DiffMergeHits.txt
	g("Cleared")
}
DiffMerge_SavePathToFile(){
	WinGetActiveTitle t
	file:=RegExReplace(t,".*,\s+(.*?) - SourceGear DiffMerge.*","$1")
	g("Saved to file: " file)
	FileAppend %file%`r`n,c:\temp\DiffMergeHits.txt
}
DiffMerge_ClipGitAdds(){
	global GitAdds
	FileRead x,C:\temp\DiffMergeHits.txt
	x:=x.trim()
	clipboard=gitoff`r`n%x%`r`ngiton`r`n
	t("Clipped GitAdds")
}
#If
/*
GetFileFromVSTitle(){
	WinGetTitle title, A
	regex=O)(?<solution>[\w\.]+)\s*(?<path>[^\(]+)(\s*\((?<mode>.*)?\))\s*(?<other>.*)\s*\|
	RegExMatch(title, regex, obj)
	return % obj.path
}
*/
AlertCallStack(reason="No specified reason", depth = 10, printLines = 1){
	msgbox % reason "`n" GetCallStack(depth, printLines)
}
GetCallStack(depth = 5, printLines = 1){
	loop % depth
	{
		lvl := -1 - depth + A_Index
		oEx := Exception("", lvl)
		oExPrev := Exception("", lvl - 1)
		FileReadLine, line, % oEx.file, % oEx.line
		if(oEx.What = lvl)
			continue
		stack .= (stack ? "`n" : "") "File '" oEx.file "', Line " oEx.line (oExPrev.What = lvl-1 ? "" : ", in " oExPrev.What) (printLines ? ":`n" line : "") "`n"
	}
	return stack
}
Join(sep, params*){
    for index,param in params
        str .= param . sep
    return SubStr(str, 1, -StrLen(sep))
}
DumpParams(args*){
	msgbox % Join(", ",args*)
}
Contains(needle,haystack){
	if haystack contains %needle%
		return True
	else
		return False
}
/*
SetGlobalVariables(){
	global SciTEPath
	SciTEPath=%PAULDIR%\SCITE\SCITE.EXE
	SciTEPath:=FirstValidPath("C:\Users\Paul\scoop\apps\notepadplusplus\current\notepad++.exe", "C:\Program Files (x86)\Notepad++\notepad++.exe")
}
*/
GoSub(name){
	If Islabel(name)
		gosub %name%
}
RunWait(cmd){
	runwait %cmd%
}
IsScrollLock(){
	if GetKeyState("ScrollLock", "T")
		return 1
	else
		return 0
}
IsCapsLock(){
	if GetKeyState("Capslock", "T")
		return 1
	else
		return 0
}
IsNumLock(){
	if GetKeyState("Numlock", "T")
		return 1
	else
		return 0
}
IsProcessRunning(ProcName){
	process exist,%procname%
	return % errorlevel
}
WriteToTempFile(val,extension="txt",dir="",prefix=""){
	tmp:=GetTempFile(extension,dir,prefix)
	FileAppend %val%,%tmp%
	return % tmp
}
GetTempFile(extension="txt",dir="",prefix="AHK_PS_Temp_"){
	global
	if !dir
		dir=c:\temp\trash\
	file=\
	tmp:=prefix tmp
	dir:=MyRTrim(dir,"\")
	Loop
	{
		file=%dir%\%prefix%%A_TickCount%.%extension%
		IfNotExist %file%
			return % file
	}
}
SendInputFn(txt){
	SendInput % txt.value
}
/*
GetActiveExplorerPath() {
	; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=69925
	explorerHwnd := WinActive("ahk_class CabinetWClass")
    if (explorerHwnd)
    {
        for window in ComObjCreate("Shell.Application").Windows
        {
            if (window.hwnd==explorerHwnd)
                return window.Document.Folder.Self.Path
        }
    }
}
*/
Max(msg="",depth=0){
	if depth > 5
		return
	if msg
		t("Maximize " msg)
	AssertNotSciteFindWindow()
	IfWinActive ahk_exe autohotkey.exe
		return
	IfWinActive Find in Files ahk_class #32770
		ListLines
	d:=depth + 1
	Max(msg, d)
}
OpenMainScript(OpenOrSwitchAHK){
	Global
	t("Opening script")
	Hit:=0
	WinShow SciTE4AutoHotkey ahk_class SciTEWindow ahk_exe SCITE.EXE
	WinActivate SciTE4AutoHotkey ahk_class SciTEWindow ahk_exe SCITE.EXE
	IfWinActive SciTE4AutoHotkey ahk_class SciTEWindow ahk_exe SCITE.EXE
		return
	If OpenOrSwitchAHK
	{
		Loop %PAULDIR%\*.ahk, 1
		{
			Match=0
			IfWinExist %A_LoopFileName% - SciTE
			{
				Match=1
			}
			IfWinExist %A_LoopFileName% * SciTE
			{
				Match=1
			}
			if a_loopfilename.contains("bin.")
			{
				match=0
			}
			t:=""
			IfWinExist SciTE4AutoHotkey ahk_class SciTEWindow ahk_exe SCITE.EXE
				t=SciTE4AutoHotkey
			If Match
			{
				;window(A_LoopFileName)
				WinActivate %A_LoopFileName% ahk_class SciTEWindow,,SciTE - Jump
				WinMaximize %A_LoopFileName% ahk_class SciTEWindow,,SciTE - Jump ;ok
				Hit=1
				IfWinActive ahk_class SciTEWindow ahk_exe SCITE.EXE,,SciTE - Jump
				{
					Max()
				}
				Return
			}
		}
	}
	If not Hit
	{
		If OpenOrSwitchAHK
		{
			t("starting new ahk")
			SciTE4AHKPath:="C:\Dev\Paul\SciTE4AutoHotkey\SciTE.exe"
			Run %SciTE4AHKPath% %scripts%
			Return
		}
	}
	WinActivate Untitled ahk_class SciTEWindow
	IfWinNotActive Untitled ahk_class SciTEWindow
	{
		t("run scite")
		Run %SciTEPath%
		WinActivate Untitled ahk_class SciTEWindow
	}
	WinWaitActive Untitled ahk_class SciTEWindow,,5
	If not Errorlevel
	{
		if OpenOrSwitchAHK
			Max()
	}
}
