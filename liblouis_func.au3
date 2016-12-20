#include <MsgBoxConstants.au3>

Global $LIBLOUISDLL = DllOpen('liblouis.dll')

If $LIBLOUISDLL == -1 Then
	MsgBox($MB_SYSTEMMODAL, 'Error', 'Unable to open liblouis.dll!' & @CRLF & _
	       'Please download it from http://liblouis.org/downloads/' & @CRLF & _
	       'and put it in the application directory.')
	Exit
EndIf

OnAutoItExitRegister('_lou_dllClose')

; Logging constants
Global Const $LOU_LOG_ALL = 0
Global Const $LOU_LOG_DEBUG = 10000
Global Const $LOU_LOG_INFO = 20000
Global Const $LOU_LOG_WARN = 30000
Global Const $LOU_LOG_ERROR = 40000
Global Const $LOU_LOG_FATAL = 50000
Global Const $LOU_LOG_OFF = 6000

; Mode constants
Global Const $LOU_MODE_NONE = 0
Global Const $LOU_MODE_NO_CONTRACTIONS = 1
Global Const $LOU_MODE_COMPBRL_ALT_CURSOR = 2
Global Const $LOU_MODE_DOTS_IO = 4
Global Const $LOU_MODE_COMP_8DOTS = 8
Global Const $LOU_MODE_PASS_1ONLY = 16
Global Const $LOU_MODE_COMPBRL_LEFT_CURSOR = 32
Global Const $LOU_MODE_OTHER_TRANS = 64
Global Const $LOU_MODE_UC_BRL = 128

Func lou_version()
	return DllCall($LIBLOUISDLL, 'str', 'lou_version')
EndFunc

Func lou_translateString(Const $tableList, Const $inbuf, $inlen, ByRef $outbuf, ByRef $outlen, ByRef $typeform, ByRef $spacing, $mode)
	$result = DllCall($LIBLOUISDLL, 'int', 'lou_translateString', _
	                  'str', $tableList, 'wstr', $inbuf, 'int*', $inlen, 'wstr', $outbuf, _
	                  'int*', $outlen, 'ptr', $typeform, 'str', $spacing, 'int', $mode)

	if ($result[0] == 1) Then
		$outlen = $result[5]
		$outbuf = StringLeft($result[4], $outlen)
		$typeform = $result[6]
		$spacing = $result[7]
	EndIf

	Return $result[0]
EndFunc

Func lou_logFile($fileName)
	DllCall($LIBLOUISDLL, 'none', 'lou_logFile', 'str', $fileName)
EndFunc

Func lou_setLogLevel($level)
	DllCall($LIBLOUISDLL, 'none', 'lou_setLogLevel', 'int', $level)
EndFunc

Func lou_charToDots (Const $tableList, Const $inbuf, ByRef $outbuf, $length, $mode)
	$result = DllCall($LIBLOUISDLL, 'int', 'lou_charToDots', _
	                  'str', $tableList, 'wstr', $inbuf, 'wstr', $outbuf, 'int', $length, 'int', $mode)

	if ($result[0] == 1) Then
		$outbuf = StringLeft($result[3], $length) ; Using StringLeft() to avoid extra characters.
	EndIf

	Return $result[0]
EndFunc

Func lou_setDataPath (ByRef $path)
	return DllCall($LIBLOUISDLL, 'str', 'lou_setDataPath', 'str', $path)
EndFunc

Func lou_free ()
	return DllCall($LIBLOUISDLL, 'none', 'lou_free')
EndFunc

Func _lou_DllClose ()
	lou_free()
	DllClose($LIBLOUISDLL)
EndFunc