;=====================================================================================
; x64dbg plugin SDK for Masm - fearless 2016 - www.LetTheLight.in
;
; APISearch.asm
;
; v1.0.0.4 - Last updated: 03/08/2016 
; 
; - Added fix for registered commands using C prototype, otherwise they crashed
; - Added function APISearchLoadMenuIcon to load png resource image as raw bytes 
; - Added menu icon for plugin (uses _plugin_menuseticon)
; - Added menu entry icons for google, msdn and pinvoke (uses _plugin_menuentryseticon) 
; 
;-------------------------------------------------------------------------------------

.686
.MMX
.XMM
.model flat,stdcall
option casemap:none

;DEBUG32 EQU 1

IFDEF DEBUG32
    PRESERVEXMMREGS equ 1
    includelib M:\Masm32\lib\Debug32.lib
    DBG32LIB equ 1
    DEBUGEXE textequ <'M:\Masm32\DbgWin.exe'>
    include M:\Masm32\include\debug32.inc
ENDIF
Include x64dbgpluginsdk.inc                 ; Main x64dbg Plugin SDK for your program, and prototypes for the main exports 

Include APISearch.inc                       ; plugin's include file

pluginit	        PROTO C :DWORD          ; Required prototype and export for x64dbg plugin SDK
plugstop            PROTO C                 ; Required prototype and export for x64dbg plugin SDK
plugsetup           PROTO C :DWORD          ; Required prototype and export for x64dbg plugin SDK
;=====================================================================================


.CONST
PLUGIN_VERSION      EQU 1

.DATA
PLUGIN_NAME         DB "APISearch",0

.DATA?
;-------------------------------------------------------------------------------------
; GLOBAL Plugin SDK variables
;-------------------------------------------------------------------------------------
PUBLIC              pluginHandle
PUBLIC              hwndDlg
PUBLIC              hMenu
PUBLIC              hMenuDisasm
PUBLIC              hMenuDump
PUBLIC              hMenuStack

pluginHandle        DD ?
hwndDlg             DD ?
hMenu               DD ?
hMenuDisasm         DD ?
hMenuDump           DD ?
hMenuStack          DD ?
;-------------------------------------------------------------------------------------


.CODE

;=====================================================================================
; Main entry function for a DLL file  - required.
;-------------------------------------------------------------------------------------
DllEntry PROC hInst:HINSTANCE, reason:DWORD, reserved:DWORD
    .IF reason == DLL_PROCESS_ATTACH
        mov eax, hInst
        mov hInstance, eax
    .ENDIF
    mov eax,TRUE
    ret
DllEntry Endp


;=====================================================================================
; pluginit - Called by debugger when plugin.dp32 is loaded - needs to be EXPORTED
; 
; Arguments: initStruct - a pointer to a PLUG_INITSTRUCT structure
;
; Notes:     you must fill in the pluginVersion, sdkVersion and pluginName members. 
;            The pluginHandle is obtained from the same structure - it may be needed in
;            other function calls.
;
;            you can call your own setup routine from within this function to setup 
;            menus and commands, and pass the initStruct parameter to this function.
;
;-------------------------------------------------------------------------------------
pluginit PROC C PUBLIC USES EBX initStruct:DWORD
    mov ebx, initStruct

    ; Fill in required information of initStruct, which is a pointer to a PLUG_INITSTRUCT structure
    mov eax, PLUGIN_VERSION
    mov [ebx].PLUG_INITSTRUCT.pluginVersion, eax
    mov eax, PLUG_SDKVERSION
    mov [ebx].PLUG_INITSTRUCT.sdkVersion, eax
    Invoke lstrcpy, Addr [ebx].PLUG_INITSTRUCT.pluginName, Addr PLUGIN_NAME
    
    mov ebx, initStruct
    mov eax, [ebx].PLUG_INITSTRUCT.pluginHandle
    mov pluginHandle, eax
    
    ; Do any other initialization here
    Invoke CoInitializeEx, NULL, COINIT_APARTMENTTHREADED + COINIT_DISABLE_OLE1DDE
	mov eax, TRUE
	ret
pluginit endp


;=====================================================================================
; plugstop - Called by debugger when the plugin.dp32 is unloaded - needs to be EXPORTED
;
; Arguments: none
; 
; Notes:     perform cleanup operations here, clearing menus and other housekeeping
;
;-------------------------------------------------------------------------------------
plugstop PROC C PUBLIC 
    
    ; remove any menus, unregister any callbacks etc
    Invoke _plugin_menuclear, hMenu
    Invoke CoUninitialize
    mov eax, TRUE
    ret
plugstop endp


;=====================================================================================
; plugsetup - Called by debugger to initialize your plugins setup - needs to be EXPORTED
;
; Arguments: setupStruct - a pointer to a PLUG_SETUPSTRUCT structure
; 
; Notes:     setupStruct contains useful handles for use within x64_dbg, mainly Qt 
;            menu handles (which are not supported with win32 api) and the main window
;            handle with this information you can add your own menus and menu items 
;            to an existing menu, or one of the predefined supported right click 
;            context menus: hMenuDisam, hMenuDump & hMenuStack
;            
;            plugsetup is called after pluginit. 
;-------------------------------------------------------------------------------------
plugsetup PROC C PUBLIC USES EBX setupStruct:DWORD
    LOCAL hIconData:ICONDATA
    
    mov ebx, setupStruct

    ; Extract handles from setupStruct which is a pointer to a PLUG_SETUPSTRUCT structure  
    mov eax, [ebx].PLUG_SETUPSTRUCT.hwndDlg
    mov hwndDlg, eax
    mov eax, [ebx].PLUG_SETUPSTRUCT.hMenu
    mov hMenu, eax
    ;PrintText 'APISearch'
    ;PrintDec hMenu
    mov eax, [ebx].PLUG_SETUPSTRUCT.hMenuDisasm
    mov hMenuDisasm, eax
    mov eax, [ebx].PLUG_SETUPSTRUCT.hMenuDump
    mov hMenuDump, eax
    mov eax, [ebx].PLUG_SETUPSTRUCT.hMenuStack
    mov hMenuStack, eax
    
    ; Do any setup here: add menus, menu items, callback and commands etc
    
    Invoke _plugin_menuaddentry, hMenuDisasm, MENU_SEARCH_GOOGLE, Addr szMenuSearchGoogle
    Invoke _plugin_menuaddentry, hMenuDisasm, MENU_SEARCH_MSDN, Addr szMenuSearchMSDN
    Invoke _plugin_menuaddentry, hMenuDisasm, MENU_SEARCH_PINVOKE, Addr szMenuSearchPinvoke

    Invoke APISearchLoadMenuIcon, IMG_APISEARCH, Addr hIconData
    .IF eax == TRUE
        Invoke _plugin_menuseticon, hMenuDisasm, Addr hIconData
    .ENDIF
    
    Invoke APISearchLoadMenuIcon, IMG_SEARCHGOOGLE, Addr hIconData
    .IF eax == TRUE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_SEARCH_GOOGLE, Addr hIconData
    .ENDIF
    
    Invoke APISearchLoadMenuIcon, IMG_SEARCHMSDN, Addr hIconData
    .IF eax == TRUE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_SEARCH_MSDN, Addr hIconData
    .ENDIF
    
    Invoke APISearchLoadMenuIcon, IMG_SEARCHPINVOKE, Addr hIconData
    .IF eax == TRUE
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_SEARCH_PINVOKE, Addr hIconData
    .ENDIF
    
    ; register commands for searching google, msdn and pinvoke
    Invoke _plugin_registercommand, pluginHandle, Addr szGoogle, Addr cbSearchGoogle, FALSE
    Invoke _plugin_registercommand, pluginHandle, Addr szMSDN, Addr cbSearchMSDN, FALSE
    Invoke _plugin_registercommand, pluginHandle, Addr szPinvoke, Addr cbSearchPinvoke, FALSE

    Invoke GuiAddLogMessage, Addr szAPISearchInfo    
    
    Invoke GuiGetWindowHandle
    mov hwndDlg, eax 
    mov eax, TRUE
    ret
plugsetup endp


;=====================================================================================
; CBMENUENTRY - Called by debugger when a menu item is clicked - needs to be EXPORTED
;
; Arguments: cbType
;            cbInfo - a pointer to a PLUG_CB_MENUENTRY structure. The hEntry contains 
;            the resource id of menu item identifiers
;  
; Notes:     hEntry can be used to determine if the user has clicked on your plugins
;            menu item(s) and to do something in response to it.
;            Needs to be PROC C type procedure call to be compatible with debugger
;-------------------------------------------------------------------------------------
CBMENUENTRY PROC C PUBLIC USES EBX cbType:DWORD, cbInfo:DWORD
    mov ebx, cbInfo
    mov eax, [ebx].PLUG_CB_MENUENTRY.hEntry
    
    .IF eax == MENU_SEARCH_GOOGLE
        Invoke SearchForAPIKeyword, 0 ;testDisasm
    
    .ELSEIF eax == MENU_SEARCH_MSDN
        Invoke SearchForAPIKeyword, 1 ;testDisasm
    
    .ELSEIF eax == MENU_SEARCH_PINVOKE
        Invoke SearchForAPIKeyword, 2 ; pinvoke
        
    .ENDIF
    mov eax, TRUE
    ret
CBMENUENTRY endp


;=====================================================================================
; Search Google
;-------------------------------------------------------------------------------------
cbSearchGoogle PROC C PUBLIC USES EBX argc:DWORD, argv:DWORD
    LOCAL dwSearchTerm:DWORD
    
    .IF argc == 1 ; just launch google if google is only thing typed
        Invoke GuiAddLogMessage, Addr szOpeningGoogle
        Invoke lstrcpy, Addr szWebSearchKeyword, Addr szGoogleHomeAddress
    .ELSE
        mov ebx, argv
        add ebx, 4d ; argv +1
        mov eax, [ebx] ; get pointer at argv[1] address to point to argv[1] string
        mov dwSearchTerm, eax
    
        Invoke lstrcpy, Addr szLogMsg, Addr szGoogleSearchingFor
        Invoke lstrcat, Addr szLogMsg, dwSearchTerm
        Invoke lstrcat, Addr szLogMsg, Addr szCRLF
        Invoke GuiAddLogMessage, Addr szLogMsg
        
        Invoke lstrcpy, Addr szWebSearchKeyword, Addr szGoogleSearchUrl
        Invoke lstrcat, Addr szWebSearchKeyword, dwSearchTerm
        
    .ENDIF
    Invoke ShellExecute, Addr szOpen, NULL, Addr szWebSearchKeyword, NULL, NULL, SW_SHOWNORMAL
    mov eax, TRUE
    ret
cbSearchGoogle endp


;=====================================================================================
; Search MSDN
;-------------------------------------------------------------------------------------
cbSearchMSDN PROC C PUBLIC USES EBX argc:DWORD, argv:DWORD
    LOCAL dwSearchTerm:DWORD
    
    .IF argc == 1 ; just launch google if google is only thing typed
        Invoke GuiAddLogMessage, Addr szOpeningMSDN
        Invoke lstrcpy, Addr szWebSearchKeyword, Addr szMSDNHomeAddress
    .ELSE
        mov ebx, argv
        add ebx, 4d ; argv +1
        mov eax, [ebx] ; get pointer at argv[1] address to point to argv[1] string
        mov dwSearchTerm, eax
    
        Invoke lstrcpy, Addr szLogMsg, Addr szMSDNSearchingFor
        Invoke lstrcat, Addr szLogMsg, dwSearchTerm
        Invoke lstrcat, Addr szLogMsg, Addr szCRLF
        Invoke GuiAddLogMessage, Addr szLogMsg
        
        Invoke lstrcpy, Addr szWebSearchKeyword, Addr szMSDNSearchUrl
        Invoke lstrcat, Addr szWebSearchKeyword, dwSearchTerm
        
    .ENDIF
    Invoke ShellExecute, Addr szOpen, NULL, Addr szWebSearchKeyword, NULL, NULL, SW_SHOWNORMAL
    mov eax, TRUE
    ret
cbSearchMSDN endp


;=====================================================================================
; Search Pinvoke
;-------------------------------------------------------------------------------------
cbSearchPinvoke PROC C PUBLIC USES EBX argc:DWORD, argv:DWORD
    LOCAL dwSearchTerm:DWORD
    
    .IF argc == 1 ; just launch google if google is only thing typed
        Invoke GuiAddLogMessage, Addr szOpeningPinvoke
        Invoke lstrcpy, Addr szWebSearchKeyword, Addr szPinvokeHomeAddress
    .ELSE
        mov ebx, argv
        add ebx, 4d ; argv +1
        mov eax, [ebx] ; get pointer at argv[1] address to point to argv[1] string
        mov dwSearchTerm, eax
    
        Invoke lstrcpy, Addr szLogMsg, Addr szPinvokeSearchingFor
        Invoke lstrcat, Addr szLogMsg, dwSearchTerm
        Invoke lstrcat, Addr szLogMsg, Addr szPinvokeNamespace
        Invoke lstrcat, Addr szLogMsg, Addr szCRLF
        Invoke GuiAddLogMessage, Addr szLogMsg
        
        Invoke lstrcpy, Addr szWebSearchKeyword, Addr szPinvokeSearchUrl
        Invoke lstrcat, Addr szWebSearchKeyword, dwSearchTerm
        Invoke lstrcat, Addr szWebSearchKeyword, Addr szPinvokeNamespace
        
    .ENDIF
    Invoke ShellExecute, Addr szOpen, NULL, Addr szWebSearchKeyword, NULL, NULL, SW_SHOWNORMAL
    mov eax, TRUE
    ret
cbSearchPinvoke endp


;=====================================================================================
; Plugin Dialog Procedure
;-------------------------------------------------------------------------------------
PluginDlgProc PROC hWin:HWND,iMsg:DWORD,wParam:WPARAM, lParam:LPARAM

    mov eax, iMsg
    .IF eax == WM_INITDIALOG
        ; Any initialization here
        
	.ELSEIF eax == WM_CLOSE
        Invoke EndDialog, hWin, NULL
        
	.ELSEIF eax == WM_COMMAND
        mov eax, wParam
        and eax, 0FFFFh
        .IF eax == IDC_PLUGINDLG_OK
            Invoke SendMessage, hWin, WM_CLOSE, NULL, NULL
        .ENDIF
    .ELSE
        mov eax, FALSE
        ret
	.ENDIF
    mov eax, TRUE
    ret
PluginDlgProc endp


;=====================================================================================
; Search online for API keyword using specified search provider
;-------------------------------------------------------------------------------------
SearchForAPIKeyword PROC USES EBX EDI ESI dwSearchProvider:DWORD ; google = 0, msdn = 1, pinvoke = 3
    LOCAL sel:SELECTIONDATA
    LOCAL lenDisasmText:DWORD
    
    Invoke GuiSelectionGet, GUI_DISASSEMBLY, Addr sel
    Invoke GuiGetDisassembly, sel.start, Addr szDisasmText
    
    Invoke lstrlen, Addr szDisasmText
    mov lenDisasmText, eax

    lea ebx, szDisasmText
    mov eax, [ebx]
    .IF eax == 'llac' ; good to go
        ; strip out call and <> brackets and @ param stuff
        
        lea esi, szDisasmText
        lea edi, szAPISearchKeyword
        
        movzx eax, byte ptr [esi]
        .WHILE al != '.' && al != '&' ; 64bit have & in the api calls, so to check for that as well
            .IF al == 0h
                Invoke GuiAddLogMessage, Addr szCouldNotFindAPI
                mov eax, FALSE
                ret
            .ENDIF
            inc esi
            movzx eax, byte ptr [esi]
        .ENDW

        inc esi ; jump over the . and the first _ if its there
        movzx eax, byte ptr [esi]
        .IF al == '_'
            inc esi
        .ENDIF

        movzx eax, byte ptr [esi]
        .WHILE al != '@' && al != '>'
            .IF al == 0h
                Invoke GuiAddLogMessage, Addr szCouldNotFindAPI
                mov eax, FALSE
                ret
            .ENDIF
            mov byte ptr [edi], al
            inc edi
            inc esi
            movzx eax, byte ptr [esi]
        .ENDW
        mov byte ptr [edi], 0h ; null out string
        
        ; check if 2nd last byte was lowercase, if so if the last byte is 'A' or 'W' we strip that off - ansi/unicode part
        dec edi
        dec edi
        movzx eax, byte ptr [edi]
        .IF al >= 'a' && al <= 'z'
            inc edi
            movzx eax, byte ptr [edi]
            .IF al == 'A' || al == 'W'
                mov byte ptr [edi], 0h ; null out string
            .ENDIF
        .ENDIF 
        
        Invoke lstrcpy, Addr szLogMsg, Addr szSearchingForAPI
        Invoke lstrcat, Addr szLogMsg, Addr szAPISearchKeyword
        Invoke lstrcat, Addr szLogMsg, Addr szCRLF
        Invoke GuiAddLogMessage, Addr szLogMsg
        .IF dwSearchProvider == 0
            Invoke lstrcpy, Addr szWebSearchKeyword, Addr szGoogleSearchUrl
        
        .ELSEIF dwSearchProvider == 1
            Invoke lstrcpy, Addr szWebSearchKeyword, Addr szMSDNSearchUrl
        
        .ELSEIF dwSearchProvider == 2
            Invoke lstrcpy, Addr szWebSearchKeyword, Addr szPinvokeSearchUrl
        .ENDIF
        Invoke lstrcat, Addr szWebSearchKeyword, Addr szAPISearchKeyword
        
        .IF dwSearchProvider == 2
            Invoke lstrcat, Addr szWebSearchKeyword, Addr szPinvokeNamespace
        .ENDIF
        
        Invoke ShellExecute, Addr szOpen, NULL, Addr szWebSearchKeyword, NULL, NULL, SW_SHOWNORMAL
        
    .ELSE
        Invoke GuiAddLogMessage, Addr szCanOnlySearchForAPI
        ret
    .ENDIF
    ret
SearchForAPIKeyword endp


;=====================================================================================
; APISearchLoadMenuIcon - Loads RT_RCDATA png resource and assigns it to ICONDATA
; Returns TRUE in eax if succesful or FALSE otherwise.
;-------------------------------------------------------------------------------------
APISearchLoadMenuIcon PROC USES EBX dwImageResourceID:DWORD, lpIconData:DWORD
    LOCAL hRes:DWORD
    
    ; Load image for our menu item
    Invoke FindResource, hInstance, dwImageResourceID, RT_RCDATA ; load png image as raw data
    .IF eax != NULL
        mov hRes, eax
        Invoke SizeofResource, hInstance, hRes
        .IF eax != 0
            mov ebx, lpIconData
            mov [ebx].ICONDATA.size_, eax
            Invoke LoadResource, hInstance, hRes
            .IF eax != NULL
                Invoke LockResource, eax
                .IF eax != NULL
                    mov ebx, lpIconData
                    mov [ebx].ICONDATA.data, eax
                    mov eax, TRUE
                .ELSE
                    ;PrintText 'Failed to lock resource'
                    mov eax, FALSE
                .ENDIF
            .ELSE
                ;PrintText 'Failed to load resource'
                mov eax, FALSE
            .ENDIF
        .ELSE
            ;PrintText 'Failed to get resource size'
            mov eax, FALSE
        .ENDIF
    .ELSE
        ;PrintText 'Failed to find resource'
        mov eax, FALSE
    .ENDIF    
    ret

APISearchLoadMenuIcon ENDP


END DllEntry
















