#include-once

#include <GDIPlus.au3>
#include <WinAPISysWin.au3>
#include <WinAPIShellEx.au3>
#include <WindowsConstants.au3>

#include "ResourcesEX.au3"

Global Const $GDIP_COLORCURVEEFFECT = "{DD6A0022-58E4-4a67-9D9B-D48EB881A53D}"
Global Const $tagCOLORCURVEEFFECTPARAMS = "int type;int channel;int value"

Global Enum $iAdjustExposure = 0, $iAdjustDensity, $iAdjustContrast, $iAdjustHighlight, $iAdjustShadow, _ ;http://msdn.microsoft.com/en-us/library/windows/desktop/ms534098(v=vs.85).aspx
		$iAdjustMidtone, $iAdjustWhiteSaturation, $iAdjustBlackSaturation
Global Enum $iCurveChannelAll = 0, $iCurveChannelRed, $iCurveChannelGreen, $iCurveChannelBlue ;http://msdn.microsoft.com/en-us/library/windows/desktop/ms534100(v=vs.85).aspx
Global $tColorCurve = DllStructCreate($tagCOLORCURVEEFFECTPARAMS), $iType = $iAdjustExposure, $iChannel = $iCurveChannelAll

;######################################################################################################################################
; #FUNCTION# ====================================================================================================================
; Name ..........: _GDIPlus_GraphicsGetDPIRatio
; Description ...:
; Syntax ........: _GDIPlus_GraphicsGetDPIRatio([$iDPIDef = 96])
; Parameters ....: $iDPIDef             - [optional] An integer value. Default is 96.
; Return values .: None
; Author ........: UEZ
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: http://www.autoitscript.com/forum/topic/159612-dpi-resolution-problem/?hl=%2Bdpi#entry1158317
; Example .......: No
; ===============================================================================================================================
Func _GDIPlus_GraphicsGetDPIRatio($iDPIDef = 96)
	_GDIPlus_Startup()
	Local $hGfx = _GDIPlus_GraphicsCreateFromHWND(0)
	If @error Then Return SetError(1, @extended, 0)
	#forcedef $__g_hGDIPDll

	Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipGetDpiX", "handle", $hGfx, "float*", 0)

	If @error Then Return SetError(2, @extended, 0)
	Local $iDPI = $aResult[2]
	Local $aResults[2] = [$iDPIDef / $iDPI, $iDPI / $iDPIDef]
	_GDIPlus_GraphicsDispose($hGfx)
	_GDIPlus_Shutdown()
	Return $aResults
EndFunc   ;==>_GDIPlus_GraphicsGetDPIRatio

Func _GDIPlus_ColorCurve($tColorCurve, $iType, $iChannel, $iValue)
	If Not IsDllStruct($tColorCurve) Then Return SetError(1, @error, 0)
	DllStructSetData($tColorCurve, "type", $iType)
	DllStructSetData($tColorCurve, "channel", $iChannel)
	DllStructSetData($tColorCurve, "value", $iValue)
	Local $pEffect = _GDIPlus_EffectCreate($GDIP_COLORCURVEEFFECT)
	If @error Then Return SetError(2, @error, 0)
	_GDIPlus_EffectsSetParameters($pEffect, $tColorCurve)
	If @error Then Return SetError(3, @error, 0)
	Return $pEffect
EndFunc   ;==>_GDIPlus_ColorCurve

Func _GDIPlus_EffectsSetParameters($pEffectObject, $tEffectParameters, $iSizeAdj = 1)
	Local $aSize = DllCall($__g_hGDIPDll, "uint", "GdipGetEffectParameterSize", "ptr", $pEffectObject, "uint*", 0)
	Local $iSize = $aSize[2] * $iSizeAdj
	Local $aResult = DllCall($__g_hGDIPDll, "uint", "GdipSetEffectParameters", "ptr", $pEffectObject, "struct*", $tEffectParameters, "uint", $iSize)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetError($aResult[0], 0, $aResult[3])
EndFunc   ;==>_GDIPlus_EffectsSetParameters

Func _SetBkIcon($ControlID, $iForeground, $iBackground, $sIcon, $iIndex, $iWidth, $iHeight)

    Local Static $STM_SETIMAGE = 0x0172
    Local $hBitmap, $hGfx, $hImage, $hIcon, $hBkIcon

    $hIcon = _WinAPI_ShellExtractIcon($sIcon, $iIndex, $iWidth, $iHeight)
    $hImage = _GDIPlus_BitmapCreateFromHICON32($hIcon)

    Local $r = BitShift(BitAND($iForeground, 0xFF0000), 16), $g = BitShift(BitAND($iForeground, 0xFF00), 8), $b = BitAND($iForeground, 0xFF)
    Local $hEffect = _GDIPlus_EffectCreateColorCurve($GDIP_AdjustExposure, $GDIP_CurveChannelRed, $r) ;GDI+ v1.1 is needed -> Win7+
    _GDIPlus_BitmapApplyEffect($hImage, $hEffect)
    _GDIPlus_EffectDispose($hEffect)
    $hEffect = _GDIPlus_EffectCreateColorCurve($GDIP_AdjustExposure, $GDIP_CurveChannelGreen, $g)
    _GDIPlus_BitmapApplyEffect($hImage, $hEffect)
    _GDIPlus_EffectDispose($hEffect)
    $hEffect = _GDIPlus_EffectCreateColorCurve($GDIP_AdjustExposure, $GDIP_CurveChannelBlue, $b)
    _GDIPlus_BitmapApplyEffect($hImage, $hEffect)
    _GDIPlus_EffectDispose($hEffect)

    If $iBackground Then
		$iBackground = "0xFF" & Hex($iBackground, 6)
        $hBitmap = _GDIPlus_BitmapCreateFromScan0($iWidth, $iHeight)
        $hGfx = _GDIPlus_ImageGetGraphicsContext($hBitmap)
        _GDIPlus_GraphicsClear($hGfx, $iBackground)
        _GDIPlus_GraphicsDrawImageRect($hGfx, $hImage, 0, 0, $iWidth, $iHeight)
        _GDIPlus_ImageDispose($hImage)
        $hImage = _GDIPlus_ImageClone($hBitmap)
        _GDIPlus_GraphicsDispose($hGfx)
        _GDIPlus_ImageDispose($hBitmap)
    EndIf

    $hBkIcon = _GDIPlus_HICONCreateFromBitmap($hImage)
    GUICtrlSendMsg($ControlID, $STM_SETIMAGE, $IMAGE_ICON, $hBkIcon)
    _WinAPI_RedrawWindow(GUICtrlGetHandle($ControlID))

    _WinAPI_DeleteObject($hIcon)
    _WinAPI_DeleteObject($hBkIcon)
    _GDIPlus_ImageDispose($hImage)
    Return SetError(0, 0, 1)
EndFunc   ;==>_SetBkIcon

Func _SetBkSelfIcon($ControlID, $iForeground, $iBackground, $sIcon, $iIndex, $iWidth, $iHeight)

    Local Static $STM_SETIMAGE = 0x0172
    Local $hBitmap, $hGfx, $hImage, $hIcon, $hBkIcon

	$hIcon = _Resource_GetAsIcon($iIndex, "RC_DATA", $sIcon)
	$hImage = _GDIPlus_BitmapCreateFromHICON32($hIcon)

    Local $r = BitShift(BitAND($iForeground, 0xFF0000), 16), $g = BitShift(BitAND($iForeground, 0xFF00), 8), $b = BitAND($iForeground, 0xFF)
    Local $hEffect = _GDIPlus_EffectCreateColorCurve($GDIP_AdjustExposure, $GDIP_CurveChannelRed, $r) ;GDI+ v1.1 is needed -> Win7+
    _GDIPlus_BitmapApplyEffect($hImage, $hEffect)
    _GDIPlus_EffectDispose($hEffect)
    $hEffect = _GDIPlus_EffectCreateColorCurve($GDIP_AdjustExposure, $GDIP_CurveChannelGreen, $g)
    _GDIPlus_BitmapApplyEffect($hImage, $hEffect)
    _GDIPlus_EffectDispose($hEffect)
    $hEffect = _GDIPlus_EffectCreateColorCurve($GDIP_AdjustExposure, $GDIP_CurveChannelBlue, $b)
    _GDIPlus_BitmapApplyEffect($hImage, $hEffect)
    _GDIPlus_EffectDispose($hEffect)

    If $iBackground Then
		$iBackground = "0xFF" & Hex($iBackground, 6)
        $hBitmap = _GDIPlus_BitmapCreateFromScan0($iWidth, $iHeight)
        $hGfx = _GDIPlus_ImageGetGraphicsContext($hBitmap)
        _GDIPlus_GraphicsClear($hGfx, $iBackground)
        _GDIPlus_GraphicsDrawImageRect($hGfx, $hImage, 0, 0, $iWidth, $iHeight)
        _GDIPlus_ImageDispose($hImage)
        $hImage = _GDIPlus_ImageClone($hBitmap)
        _GDIPlus_GraphicsDispose($hGfx)
        _GDIPlus_ImageDispose($hBitmap)
    EndIf

    $hBkIcon = _GDIPlus_HICONCreateFromBitmap($hImage)
    GUICtrlSendMsg($ControlID, $STM_SETIMAGE, $IMAGE_ICON, $hBkIcon)
    _WinAPI_RedrawWindow(GUICtrlGetHandle($ControlID))

    _WinAPI_DeleteObject($hIcon)
    _WinAPI_DeleteObject($hBkIcon)
    _GDIPlus_ImageDispose($hImage)
    Return SetError(0, 0, 1)
EndFunc   ;==>_SetBkSelfIcon