#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=text2dots.ico
#AutoIt3Wrapper_UseX64=N
#AutoIt3Wrapper_Res_Description=Text2Dots
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_ProductVersion=1.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=© 2016 Rimas Kudelis
#AutoIt3Wrapper_Res_Language=0x0409
#AutoIt3Wrapper_Res_Field=Productname|Text2Dots
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include "liblouis_func.au3"
#include <File.au3>
#include <GUIConstants.au3>

OnAutoItExitRegister("DoBeforeExit")

;------------------------------------------------------------------------------------------------
; Global variables and stuff
;------------------------------------------------------------------------------------------------

Dim $CONFIG_FILE = 'text2dots.ini'
Dim $PROGRAM_TITLE = 'Text2Dots'
Dim $MAIN_WINDOW
;Dim $SETTINGS_WINDOW

Dim $debugFileName
Dim $debugFile
Dim $sourceField
Dim $targetField

;------------------------------------------------------------------------------------------------
; Load configuration settings.
;------------------------------------------------------------------------------------------------
FileChangeDir(@ScriptDir)

Dim $DEBUG = Int(IniRead($CONFIG_FILE, 'Text2Dots', 'debug', '0'))
Dim $tableName = IniRead($CONFIG_FILE, 'Text2Dots', 'table_file', 'en-us-g2.ctb')
Dim $translate = Int(IniRead($CONFIG_FILE, 'Text2Dots', 'translate', '0'))
Dim $fontSize = Int(IniRead($CONFIG_FILE, 'Text2Dots', 'font_size', '0'))
Dim $dataPath = IniRead($CONFIG_FILE, 'Text2Dots', 'data_path', _PathFull(@ScriptDir & '\tables'))
Dim $startText = IniRead($CONFIG_FILE, 'Text2Dots', 'start_text', '')

$table = $dataPath & '\' & $tableName

;------------------------------------------------------------------------------------------------
; Set up Debugging
;------------------------------------------------------------------------------------------------
If ($DEBUG > 0) Then
	$debugFileName = "Text2Dots-dump-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC & ".txt"
	$debugFile = FileOpen($debugFileName, 1)
	; Check if file opened for reading OK
	If ($debugFile == -1) Then
		MsgBox(16, "DEBUG", "Unable to open debug dump file.:" & $debugFile)
	EndIf
	lou_setLogLevel($LOU_LOG_ALL)
Else
	FileClose($debugFile)
EndIf
;------------------------------------------------------------------------------------------------

;------------------------------------------------------------------------------------------------
; Functions
;------------------------------------------------------------------------------------------------
Func DoDebug($text)
	If $DEBUG == 1 Then
		BlockInput(0)
		SplashOff()
	EndIf
	If $DEBUG == 2 Then
		BlockInput(0)
		SplashOff()
		MsgBox(16, "DEBUG", $text)
	EndIf
	;Write to file
	$debugFile = FileOpen($debugFileName, 1)
	If (Not ($debugFile = -1)) Then
		FileWriteLine($debugFile, $text)
		FileClose($debugFile)
	EndIf
EndFunc   ;==>DoDebug

Func SaveConfig()
	Local $settings = [ _
			['debug', $DEBUG], ['table_file', $tableName], ['translate', $translate], _
			['font_size', $fontSize], ['data_path', _PathGetRelative(@ScriptDir, $dataPath)], _
			['start_text', $startText] _
			]
	IniWriteSection($CONFIG_FILE, 'Text2Dots', $settings)
EndFunc   ;==>SaveConfig

Func _IsChecked($idControlID)
	Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

;------------------------------------------------------------------------------------------------
; GUI code
;------------------------------------------------------------------------------------------------
DoDebug("***Starting Text2Dots***")

lou_setDataPath($dataPath)

$MAIN_WINDOW = GUICreate($PROGRAM_TITLE, 520, 410)

GUICtrlCreateLabel("Text:", 10, 10, 420, 20)
$sourceField = GUICtrlCreateEdit($startText, 10, 30, 420, 170, $ES_MULTILINE + $ES_AUTOVSCROLL + $WS_VSCROLL + $ES_WANTRETURN)

GUICtrlCreateLabel("Braille dots:", 10, 210, 420, 20)
$targetField = GUICtrlCreateEdit('', 10, 230, 420, 170, $ES_MULTILINE + $ES_AUTOVSCROLL + $WS_VSCROLL + $ES_WANTRETURN)

If ($fontSize > 0) Then
	GUICtrlSetFont($sourceField, $fontSize)
	GUICtrlSetFont($targetField, $fontSize)
EndIf

$translateCb = GUICtrlCreateCheckbox("Translate", 440, 30, 70, 20)
If ($translate) Then
	GUICtrlSetState($translateCb, $GUI_CHECKED)
EndIf

$convertButton = GUICtrlCreateButton("Convert", 440, 50, 70)

;$SETTINGS_WINDOW = GUICreate(StringReplace('„%PROGRAM_TITLE%“ parametrai', '%PROGRAM_TITLE%', $PROGRAM_TITLE), 300, 300)

GUISetState(@SW_SHOW, $MAIN_WINDOW)

;-----------------------------------------------------------
;START MAIN LOOP
;-----------------------------------------------------------
While 1
	;two while loops so exitlooop can be used to escape button functions
	While 1
		$msg = GUIGetMsg()
		; Exit Tool.
		If $msg == $GUI_EVENT_CLOSE Then
			Exit

			; Translate checkbox state changed.
		ElseIf ($msg == $translateCb) Then
			$translate = Int(_IsChecked($translateCb))

			; Convert button clicked.
		ElseIf ($msg == $convertButton) Then
			Dim $sourceText = GUICtrlRead($sourceField)
			Dim $translatedText = ''
			Dim $targetText = ''
			Dim $sourceTextLength = StringLen($sourceText)
			Dim $targetTextLength = $sourceTextLength

			If ($translate) Then
				$typeform = Null
				$spacing = Null
				lou_translateString($table, $sourceText, $sourceTextLength, $translatedText, $targetTextLength, $typeform, $spacing, $LOU_MODE_NONE)
			Else
				$translatedText = $sourceText
			EndIf

			lou_charToDots($table, $translatedText, $targetText, $targetTextLength, $LOU_MODE_UC_BRL)

			GUICtrlSetData($targetField, $targetText)
		EndIf
	WEnd

WEnd
;-------------------------------------------------------------------------
;End of Program when loop ends
;-------------------------------------------------------------------------
Exit

Func DoBeforeExit()
	SaveConfig()
	DoDebug("***Exiting Text2Dots***")
EndFunc   ;==>DoBeforeExit
