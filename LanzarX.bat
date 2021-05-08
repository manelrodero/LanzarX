@echo off

setlocal enabledelayedexpansion
pushd "%~pd0"

::
:: LanzarX.bat - Script para ejecutar un programa de manera "portable" a nivel de ficheros en %LocalAppData% y %AppData%
:: |
:: +---Local	-> Contenido de %LocalAppData%
:: +---Roaming	-> Contenido de %AppData%
:: +---Run	-> El programa o diferentes versiones del programa organizadas por directorios (v1, v4, etc.)
::

set scriptversion=2.1
set scriptdate=23 Febrero 2013
set scriptauthor=Manel Rodero
set nversiones=0

::
:: MODIFICAR estos valores según el programa que se quiera ejecutar
::
:: Titulo     = Nombre del programa a título descriptivo
:: Versiones  = Array con las versiones disponibles del programa
:: Programa   = Nombre del ejecutable del programa
:: LocalDir   = (Opcional) Nombre del directorio creado en %LocalAppData%
:: RoamingDir = (Opcional) Nombre del directorio creado en %AppData%

set titulo=ProgramaX
set versiones=(1.0.0)
set programa=programax.exe
set roamingdir=programax.com

::
:: NO MODIFICAR desde aquí, es un código común a todos los scripts
::

for %%v in %versiones% do (
	set /a numversiones=!numversiones!+1
)

if /i "%1"=="0" goto deslinkar

for %%v in %versiones% do (
	if "%1"=="%%v" goto ejecutar
)
goto instrucciones

:ejecutar
call :linkar
echo Ejecutando '%titulo% %1' ...
pushd ".\Run"
start "" "%programa%"
popd
goto final

:deslinkar
if not "%localdir%"=="" if exist "%localappdata%\%localdir%" rmdir "%localappdata%\%localdir%" /s /q
if not "%roamingdir%"=="" if exist "%appdata%\%roamingdir%" rmdir "%appdata%\%roamingdir%" /s /q
goto final

:linkar
if not "%localdir%"=="" (
	if exist "%localappdata%\%localdir%" rmdir "%localappdata%\%localdir%"
	if not exist .\Local mkdir .\Local
	mklink /j "%localappdata%\%localdir%" .\Local
)

if not "%roamingdir%"=="" (
	if exist "%appdata%\%roamingdir%" rmdir "%appdata%\%roamingdir%"
	if not exist .\Roaming mkdir .\Roaming
	mklink /j "%appdata%\%roamingdir%" .\Roaming
)
goto :eof

:instrucciones
echo %~n0 %scriptversion%, %scriptdate%, %scriptauthor%
echo.
echo Usage: %~n0 [Option]
echo.
echo Option:
echo   0		Delete 'links' in %%apdata%% and %%localappdata%%
for %%v in %versiones% do (
	echo   %%v		%titulo% %%v
)
echo.
echo Examples:
echo   %~n0 1.0.0 =^> Run %titulo% version 1.0.0

:final
popd
endlocal
