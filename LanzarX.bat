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

set scriptversion=2.2
set scriptdate=23 Febrero 2013
set scriptauthor=Manel Rodero
set nversiones=0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
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

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: NO MODIFICAR desde aquí, es un código común a todos los scripts
::

:: Obtenemos el n�mero de versiones y se inicializa una variable indexada "Run.X"
for %%v in %versiones% do (
	set /a numversiones=!numversiones!+1
	set run.!numversiones!=%%v
)

if /i "%1"=="" goto instrucciones
if /i "%1"=="0" goto deslinkar
if /i "%1" leq "%numversiones%" (set vrun=!run.%1!&&goto ejecutar)
goto instrucciones

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ejecutar
if /i "%numversiones%"=="1" (
	call :linkar
	echo Ejecutando '%titulo% %vrun%' ...
	pushd ".\Run"
	start "" "%programa%"
	popd
) else (
	call :linkar %vrun%
	echo Ejecutando '%titulo% %vrun%' ...
	pushd ".\Run\%vrun%"
	start "" "%programa%"
	popd
)
goto final

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:deslinkar
if not "%localdir%"=="" if exist "%localappdata%\%localdir%" (echo Borrando link %%LocalAppData%%\%localdir%...&&rmdir "%localappdata%\%localdir%")
if not "%roamingdir%"=="" if exist "%appdata%\%roamingdir%" (echo Borrando link %%AppData%%\%roamingdir%...&&rmdir "%appdata%\%roamingdir%")
goto final

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:linkar
if not "%localdir%"=="" (
	if exist "%localappdata%\%localdir%" rmdir "%localappdata%\%localdir%"
	if /i "%1"=="" (
		if not exist .\Local mkdir .\Local
		echo Creando link en %%LocalAppData%% -^> .\Local ...
		mklink /j "%localappdata%\%localdir%" .\Local > nul
	) else (
		if not exist .\Local\%1 mkdir .\Local\%1
		echo Creando link en %%LocalAppData%% -^> .\Local\%1 ...
		mklink /j "%localappdata%\%localdir%" .\Local\%1 > nul
	)
)

if not "%roamingdir%"=="" (
	if exist "%appdata%\%roamingdir%" rmdir "%appdata%\%roamingdir%"
	if /i "%1"=="" (
		if not exist .\Roaming mkdir .\Roaming
		echo Creando link en %%AppData%% -^> .\Local ...
		mklink /j "%appdata%\%roamingdir%" .\Roaming > nul
	) else (
		if not exist .\Roaming\%1 mkdir .\Roaming\%1
		echo Creando link en %%AppData%% -^> .\Local\%1 ...
		mklink /j "%appdata%\%roamingdir%" .\Roaming\%1 > nul
	)
)
goto :eof

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:instrucciones
echo %~n0 %scriptversion%, %scriptdate%, %scriptauthor%
echo.
echo Usage: %~n0 [Option]
echo.
echo Option:
echo   0	Delete 'links' in %%apdata%% and %%localappdata%%
for /l %%i in (1,1,%numversiones%) do (
	echo   %%i	%titulo% !run.%%i!
)
echo.
echo Examples:
echo   %~n0 1 =^> Run program number 1

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:final
popd
endlocal
