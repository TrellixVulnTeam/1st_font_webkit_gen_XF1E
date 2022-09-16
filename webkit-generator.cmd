@echo off
:: - - - - - - - - - - - - - - - - - - - - - - - -
:: 1st_font_webkit_gen
::    An automatic mass font-webkit generation
::    for Windows users.
:: - - - - - - - - - - - - - - - - - - - - - - - -
:: Usage example:
:: drag&drop "NotoEmoji-Regular.ttf",
:: get eot+ttf+otf+svg+woff+woff2,
:: and @fontface css with an accurate font-family
:: and other best practices.
:: - - - - - - - - - - - - - - - - - - - - - - - -
:: *********
:: see if you need to change the result's
:: font-weight:400; font-style:normal;
:: *********
:: - - - - - - - - - - - - - - - - - - - - - - - -
::                       Elad Karako. October 2017
::                          update: September 2022
:: - - - - - - - - - - - - - - - - - - - - - - - -
chcp 65001 1>nul 2>nul

pushd "%~sdp0"

set "FF=%~sdp0\fontforge"
set "PYTHONHOME=%FF%"
set "PYTHONPATH=%FF%lib\python3.10"
set "PATH=%FF%;%FF%\bin;%PATH%"
set "FF_PATH_ADDED=TRUE"

:LOOP
::has argument ?
if ["%~1"] EQU [""] ( goto END  ) 
if not exist %~s1   ( goto NEXT ) 
if exist %~s1\NUL   ( goto NEXT ) 

title %~nx1

set FILE_INPUT="%~1"
set FILE_BACKUP="%~1_backup"
set FILE_TTF="%~dpn1.ttf"

echo.
echo [INFO] backup of original font-file...
call copy /b /y %FILE_INPUT% %FILE_BACKUP%  1>nul 2>nul

echo.
echo [INFO] converting to eot, svg, otf, ttf, woff (FontForge)...
call "fontforge\fontforge.bat" -lang "ff" -c "Open($1); Generate($1:r + \".eot\"); Generate($1:r + \".svg\"); Generate($1:r + \".otf\"); Generate($1:r + \".ttf\"); Generate($1:r + \".woff\");" %FILE_INPUT%

echo.
echo [INFO] converting to woff2 (woff2_compress)...
call "woff2\woff2_compress.exe" %FILE_TTF%

echo.
echo [INFO] restoring original font-file...
call copy /b /y %FILE_BACKUP% %FILE_INPUT%  1>nul 2>nul
del /f /q %FILE_BACKUP%                     1>nul 2>nul

echo.
echo [INFO] querying for font-family (OTFInfo)...
for /f "tokens=*" %%a in ('call otfinfo\otfinfo.exe --quiet --family %FILE_TTF% 2^>^&1') do ( set "FONT_FAMILY=%%a" )

echo.
echo [INFO] generating CSS with actual data and best practices...
echo. 1>%~n1.css
echo @font-face{                                                                           >>%~n1.css
echo  font-weight:400; font-style:normal; font-display:swap; font-family:'%FONT_FAMILY%';  >>%~n1.css
echo  src: url('%~n1.eot');                                                                >>%~n1.css
echo  src: local('%FONT_FAMILY%')                                                          >>%~n1.css
echo      ,local('%~n1.ttf')                                                               >>%~n1.css
echo      ,url('%~n1.eot?#iefix')  format('embedded-opentype')                             >>%~n1.css
echo      ,url('%~n1.ttf')         format('truetype')                                      >>%~n1.css
echo      ,url('%~n1.otf')         format('opentype')                                      >>%~n1.css
echo      ,url('%~n1.woff2')       format('woff2')                                         >>%~n1.css
echo      ,url('%~n1.woff')        format('woff')                                          >>%~n1.css
echo      ,url('%~n1.svg#svg')     format('svg')                                           >>%~n1.css
echo      ;                                                                                >>%~n1.css
echo }                                                                                     >>%~n1.css
echo /*★ 1st_font_webkit_gen - github.com/eladkarako ★*/                                   >>%~n1.css
echo.                                                                                      >>%~n1.css
echo html, input, textarea{  /*for example...*/                                            >>%~n1.css
echo   font-family: '%FONT_FAMILY%', sans-serif;                                           >>%~n1.css
echo }                                                                                     >>%~n1.css
echo.                                                                                      >>%~n1.css


echo.
echo Done [%FONT_FAMILY%].
echo.

goto NEXT
::--------------------------------------------------------------------------------

:NEXT
shift
goto LOOP

:END
pause
popd


::call fontforge.bat -lang "ff" -c 'Open($1); Generate($1:r + "_.eot"); Generate($1:r + "_.ttf"); Generate($1:r + "_.otf"); Generate($1:r + "_.svg"); Generate($1:r + "_.woff"); Generate($1:r + "_.woff2");' %FILE_INPUT%
::call fontforge.bat -lang "ff" -c "Open($1); Generate($1:r + \"_.eot\"); Generate($1:r + \".svg\"); Generate($1:r + \".otf\"); Generate($1:r + \".woff\"); Generate($1:r + \".woff2\");" %FILE_INPUT%