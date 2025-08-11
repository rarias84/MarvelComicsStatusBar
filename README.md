# MarvelComicsStatusBar

## 1. Descripción
MarvelComicsStatusBar es una aplicación macOS que muestra una barra de estado personalizada con información actualizada de cómics de Marvel. Utiliza la API oficial de Marvel para obtener datos y presenta una interfaz visual atractiva y funcional.

## 2. Requisitos y configuración inicial
Para ejecutar la aplicación, necesitas:

- macOS 12 o superior.
- Claves públicas y privadas de la API de Marvel.

### Configuración de las claves de la API
Debes agregar tus claves públicas y privadas de Marvel como variables de entorno en tu entorno de desarrollo:

- `MARVEL_API_PUBLIC_KEY`: Tu clave pública.
- `MARVEL_API_PRIVATE_KEY`: Tu clave privada.

Puedes hacerlo agregando estas variables en tu archivo `.xcconfig` o exportándolas en tu terminal antes de ejecutar la app.

- Xcode 14 o superior.

## 3. Generar PKG e instalación
Para generar el paquete de instalación y desplegar la aplicación, sigue estos pasos:

1. Compila la app en modo Release desde Xcode o usando la línea de comandos.
2. Ejecuta el script `scripts/build_pkg.sh` para empaquetar la app y el LaunchAgent en un `.pkg`.
3. **No necesitas mover archivos manualmente**: el instalador copia automáticamente la app a `/Applications` y el LaunchAgent a `/Library/LaunchAgents` usando los scripts de `pre/postinstall`.
4. Tras instalar el `.pkg`, la app se registra para iniciar sesión automáticamente y se arranca inmediatamente.

**Qué hace el instalador automáticamente**

- Quita el quarantine de la app y del LaunchAgent.
- Instala el `.plist` en `/Library/LaunchAgents` y la app en `/Applications`.
- Registra y arranca el LaunchAgent para el usuario activo.
