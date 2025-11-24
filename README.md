📱 Flutter App – Guia Completa de Ejecucion
Este proyecto es una aplicacion movil desarrollada con Flutter que funciona junto con un backend en asp.net Core.

🔗 Repositorios del proyecto

Backend (ASP.NET Core):
Repositorio Backend
Comando para clonar:
'git clone https://github.com/Arnold120/Backend-AppMovil.git'


Aplicación móvil (Flutter):
Repositorio App Flutter
Comando para clonar:
'git clone https://github.com/Arnold120/AppMovilLibreria.git'


🛠 Requisitos previos
Antes de comenzar, asegurate de tener instalado lo siguiente:

1. Chocolatey (Windows)
Chocolatey es un gestor de paquetes para Windows que facilita la instalacion de herramientas.
Instalalo desde PowerShell (como administrador):

'set-executionpolicy bypass -scope process -force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))'

Verifica instalación:

'choco --version'

2. FVM (Flutter Version Manager)
FVM permite manejar multiples versiones de Flutter en tu equipo.
Instalalo con Chocolatey:

'choco install fvm'

Verifica instalación:

'fvm --version'

3. Instalar la versión correcta de Flutter con FVM
Dentro del proyecto, ejecuta:

'fvm install'

4. Usar una versión específica de Flutter
Si ya tienes Flutter instalado en tu PC y quieres usar esa versión con FVM:
Por ejemplo, si tienes Flutter 3.0.0:

'fvm use 3.0.0'
(Puedes ajustar el número según tu version instalada)

Esto instalará la versión indicada en el archivo fvm_config.json o .fvm.
Para usar Flutter con FVM:

'fvm flutter --version'

Flutter SDK
Descarga desde: https://flutter.dev/docs/get-started/install
Verifica la instalación:
Shell'flutter --version'Mostrar más líneas

Git (para clonar repositorios)
Descarga desde: https://git-scm.com/downloads

Android Studio o Visual Studio Code
Necesarios para ejecutar la app y emular dispositivos.


📥 Clonar el repositorio de la app
Shell'git clone https://github.com/Arnold120/AppMovilLibreria.git'Mostrar más líneas

📦 Instalar dependencias
Dentro de la carpeta del proyecto, ejecuta:

'flutter pub get'

🔄 Generar rutas automaticamente
Este paso es importante para que la navegacion funcione correctamente:
'flutter pub run build_runner build --delete-conflicting-outputs'

📱 Verificar dispositivos conectados
Comprueba que tu emulador o teléfono esté listo:
'flutter devices'
Si no aparece ninguno:

Inicia un emulador desde Android Studio.
O conecta tu teléfono con Depuración USB activada.

▶️ Ejecutar la aplicación
Finalmente, corre la app:
'flutter run'

🌍 Correr el proyecto en un ambiente específico
Puedes definir el ambiente (development, testing, production) al ejecutar la app:

'fvm flutter run --dart-define ENVIRONMENT=development'

Valores posibles:

development
testing
production

ℹ️ Información adicional

Si es la primera vez que usas Flutter, puede tardar en descargar dependencias.
Asegúrate de que el backend esté ejecutándose antes de probar funciones que requieran conexión.
Si tienes problemas, revisa la documentación oficial: https://docs.flutter.dev