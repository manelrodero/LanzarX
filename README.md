# LanzarX

`LanzarX.bat` es un _script_ para ejecutar un programa de manera "portable" a nivel de ficheros de configuración.

Se suele utilizar con aquellos programas que no son estrictamente portables porque guardan la configuración en los directorios **Roaming** (`%APPDATA%`) y **Local** (`%LOCALAPPDATA%`) bajo el perfil de usuario.

La idea es crear estos directorios en una ubicación compartida con el programa y después usar `mklink.exe` para enlazarlos:

* `Local`: Contenido de %LocalAppData%
* `Roaming`: Contenido de %AppData%
* `Run`: El programa "portable"

> *Nota*: En el directorio `Run` puede haber una o varias versiones del programa (organizadas por directorios: v1, v4, etc.)
