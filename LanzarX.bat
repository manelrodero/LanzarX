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

set scriptversion=2.5
set scriptdate=2 Junio 2016
set scriptauthor=Manel Rodero
set nversiones=0
set run.1=0

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
set versiones=(1.0.0 2.0.0)
set programa=programax.exe
set localdir=programax.com
set roamingdir=programax.com

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: NO MODIFICAR desde aquí, es un código común a todos los scripts
::

:: Si no hay versiones
if not defined versiones goto instrucciones

:: Obtenemos el número de versiones y se inicializa una variable indexada "run.X"
for %%v in %versiones% do (
	set /a numversiones=!numversiones!+1
	set run.!numversiones!=%%v
)

if /i "%1"=="" goto instrucciones
if /i "%1"=="0" goto deslinkar
if %1 leq %numversiones% (set vrun=!run.%1!&&goto ejecutar)
goto instrucciones

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ejecutar
set programa=%programa:"=%
if %numversiones% gtr 1 (call :linkar %vrun%) else (call :linkar)
if %numversiones% gtr 1 (call :precheck %vrun%) else (call :precheck)
echo Ejecutando '%titulo% %vrun%' ...
if %numversiones% gtr 1 (pushd ".\Run\%vrun%") else (pushd ".\Run")
start "" "%programa%"
popd
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
		echo Creando link en %%AppData%% -^> .\Roaming ...
		mklink /j "%appdata%\%roamingdir%" .\Roaming > nul
	) else (
		if not exist .\Roaming\%1 mkdir .\Roaming\%1
		echo Creando link en %%AppData%% -^> .\Roaming\%1 ...
		mklink /j "%appdata%\%roamingdir%" .\Roaming\%1 > nul
	)
)
goto :eof

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: MODIFICAR esta rutina según el programa que se quiera ejecutar (podría estar vacía si no es necesario hacer nada)
::
:precheck
goto :eof

::
:: Ejemplo 1 (MPC-HC):
:: - Crear un fichero 'programax.ini' vacío para que el programa escriba la configuración y no use el registro
:: - Borrar la rama del registro donde guarda la configuración si no es portable
::
if /i "%1"=="" (
        if not exist ".\Run\mpc-hc.ini" (
                echo Creando fichero mpc-hc.ini ...
                > ".\Run\mpc-hc.ini" echo [Settings]
                >> ".\Run\mpc-hc.ini" echo UpdaterAutoCheck=0
                reg delete HKEY_CURRENT_USER\Software\Gabest /f >nul 2>&1
        )
) else (
        if not exist ".\Run\%1\mpc-hc.ini" (
                echo Creando fichero mpc-hc.ini ...
                > ".\Run\%1\mpc-hc.ini" echo [Settings]
                >> ".\Run\%1\mpc-hc.ini" echo UpdaterAutoCheck=0
                reg delete HKEY_CURRENT_USER\Software\Gabest /f >nul 2>&1
        )
)
goto :eof

::
:: Ejemplo 2 (Spotify):
:: - Spotify tiene los ejecutables (Run) directamente en Roaming, por tanto se enlazan
:: - Borrar las actualizaciones que se hayan descargado
::
if not exist .\Run (
	echo Creando link en .\Run -^> .\Roaming ...
	mklink /j .\Run .\Roaming > nul
)
if exist .\Local\Update (
	echo Borrando .\Local\Update ...
	rmdir /s /q .\Local\Update
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
echo   %~n0 1 =^> Run %titulo% version %run.1%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:final
popd
endlocal
