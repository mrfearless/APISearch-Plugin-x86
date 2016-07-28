;=====================================================================================
; x64dbg plugin SDK for Masm - fearless 2016 - www.LetTheLight.in
;
; APISearch.inc
;
;-------------------------------------------------------------------------------------
include windows.inc
include user32.inc
include kernel32.inc
include shell32.inc
includelib user32.lib
includelib kernel32.lib
includelib shell32.lib
include ole32.inc
includelib ole32.lib

PluginDlgProc           PROTO :DWORD, :DWORD, :DWORD, :DWORD
SearchForAPIKeyword     PROTO :DWORD
cbSearchGoogle          PROTO :DWORD, :DWORD
cbSearchMSDN            PROTO :DWORD, :DWORD
cbSearchPinvoke         PROTO :DWORD, :DWORD
APISearchLoadMenuIcon   PROTO :DWORD, :DWORD

.CONST
CRLF                    TEXTEQU <13,10,0> ; carriage return and linefeed for strings that require them (GuiAddLogMessage for example) 

IMG_APISEARCH           EQU 101 ; PNG image for plugin menu icon
IMG_SEARCHGOOGLE        EQU 102 ; PNG image for plugin menu icon
IMG_SEARCHMSDN          EQU 103 ; PNG image for plugin menu icon
IMG_SEARCHPINVOKE       EQU 104 ; PNG image for plugin menu icon

MENU_SEARCH_GOOGLE      EQU 11
MENU_SEARCH_MSDN        EQU 12
MENU_SEARCH_PINVOKE     EQU 13
IDD_PluginDlg           EQU 1000
IDC_PLUGINDLG_OK        EQU 1001

.DATA
szMenuSearchGoogle      DB "Search Google...",0
szMenuSearchMSDN        DB "Search MSDN...",0
szMenuSearchPinvoke     DB "Search Pinvoke...",0
szAPISearchInfo         DB 13,10         
                        DB "APISearch x32dbg plugin by fearless 2016 - www.LetTheLight.in",13,10
                        DB 13,10
                        DB "APISearch Features & Usage:",13,10
                        DB " - Search online for API calls in the dissassembly window (lines that begin with 'call')",13,10  
                        DB " - Search from the command bar using google, msdn or pinvoke, ie: 'google <searchterm>' ",13,10
                        DB " - Open web browser to google, msdn or pinvoke, ie: 'msdn' opens browser at msdn.microsoft.com",13,10
                        DB 13,10,0

; status messages
szDebuggingRequired     DB "APISearch: you need to be debugging to use this option.",CRLF
szCanOnlySearchForAPI   DB "APISearch: Can only search for API calls, make sure you have selected a line that starts with 'call'",CRLF
szCouldNotFindAPI       DB "APISearch: Could not find an API function call in the selected line.",CRLF
szSearchingForAPI       DB "APISearch: Searching for API function: ",0
szOpeningGoogle         DB "Opening www.google.com in a web browser.",CRLF
szOpeningMSDN           DB "Opening msdn.microsoft.com in a web browser.",CRLF
szOpeningPinvoke        DB "Opening www.pinvoke.net in a web browser.",CRLF
szLogMsg                DB 1024 DUP (0)

; search strings
szGoogleHomeAddress     DB "http://www.google.com",0
szMSDNHomeAddress       DB "http://msdn.microsoft.com",0
szPinvokeHomeAddress    DB "http://www.pinvoke.net",0
szGoogleSearchUrl       DB "https://www.google.com/search?q=",0
szMSDNSearchUrl         DB "https://social.msdn.microsoft.com/search/en-us/?query=",0
szPinvokeSearchUrl      DB "http://www.pinvoke.net/search.aspx?search=",0
szPinvokeNamespace      DB "&namespace=[All]",0
szGoogleSearchingFor    DB "Google search: ",0
szMSDNSearchingFor      DB "MSDN search: ",0
szPinvokeSearchingFor   DB "Pinvoke search: ",0
szWebSearchKeyword      DB MAX_PATH DUP (0)
szAPISearchKeyword      DB MAX_PATH DUP (0)

; Misc
szDisasmText            DB GUI_MAX_DISASSEMBLY_SIZE DUP (0)
szOpen                  DB "Open",0 
szCRLF                  DB 13,10,0

; registered command strings
szGoogle                DB "Google",0
szMSDN                  DB "MSDN",0
szPinvoke               DB "Pinvoke",0

.DATA?
hInstance               DD ?

