# Cookly iOS (SwiftUI) — versión para xtool

Versión SwiftUI de Cookly, la nevera digital. Taller 2 – Microproyecto SwiftUI, Desarrollo de Aplicaciones Móviles, Universidad del Cauca.

**Equipo:** María Alejandra Solarte · Ronal Santiago Valdez Jurado

Este proyecto está hecho para compilarse con **xtool** desde Windows (WSL) o Linux, sin Mac, e instalarse en un **iPhone físico**.

## Estructura
```
Cookly-xtool/
├── Package.swift              Swift Package (lo que xtool compila como app)
├── xtool.yml                  Configuración de xtool (bundleID)
└── Sources/Cookly/
    ├── CooklyApp.swift        Punto de entrada (@main)
    ├── ContentView.swift      TabView con 4 pestañas
    ├── Models/                Product, Reminder, FoodCategory (Codable)
    ├── Network/               FoodAPIService (URLSession, async/await), modelos Codable
    ├── Persistence/           LocalRepository (guarda JSON en el dispositivo)
    ├── ViewModels/            Nevera, AddProduct, Search + ProductDetail, Reminders
    └── Views/                 Welcome, Nevera, AddProduct, Search, ProductDetail,
                               Reminders, Profile, About + Components/
```

## Diferencias frente a la versión para Xcode
- **Persistencia con archivos JSON** (`Codable` + `FileManager`) en vez de SwiftData, porque los macros de SwiftData (`@Model`) son de Apple y xtool aún no los soporta. Sigue siendo persistencia local: los datos quedan guardados en el iPhone aunque se cierre la app.
- **Sin `#Preview`**: también es un macro de Apple. Para ver cambios hay que compilar e instalar.

## Requisitos (según el Manual xtool del semillero)
- Windows 11 con **WSL2 + Ubuntu**
- **Swift 6.4.1** instalado con **Swiftly** (no con `apt install swift…`)
- **Xcode 27.1 (.xip)** descargado de https://developer.apple.com/download/ con un Apple ID gratuito
- **Apple ID** (modo *Password* en `xtool setup`; se recomienda una cuenta secundaria)
- **iPhone** desbloqueado, con *Confiar en esta computadora* aceptado y *Modo desarrollador* activado
- **Apple Mobile Device Service** corriendo en Windows (viene con la app *Dispositivos Apple* o iTunes de la Microsoft Store)

## 1. Instalar las herramientas (una sola vez)
Seguir las secciones III a VII del manual. Resumen, en **Ubuntu/WSL**:
```bash
# Swift con Swiftly
curl -O https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz && \
tar zxf swiftly-$(uname -m).tar.gz && \
./swiftly init --quiet-shell-followup && \
. "${SWIFTLY_HOME_DIR:-$HOME/.local/share/swiftly}/env.sh" && hash -r
# (instalar las dependencias que Swiftly indique al terminar)
swift --version

# Utilidades iOS
sudo apt update && sudo apt install -y usbmuxd libimobiledevice-utils

# xtool
curl -fL "https://github.com/xtool-org/xtool/releases/latest/download/xtool-$(uname -m).AppImage" -o xtool
chmod +x xtool && sudo mv xtool /usr/local/bin/
xtool setup        # opción 1: Password; luego la ruta del Xcode_27.1.xip (ej. /mnt/c/Users/.../Xcode_27.1.xip)
swift sdk list     # debe responder: darwin
```

## 2. Crear el proyecto Cookly con la plantilla oficial y copiar el código
Se usa `xtool new` para que genere el `Package.swift`, el `xtool.yml` y la carpeta `.bsp` (la que conecta VS Code con xtool). Luego se reemplaza el código de ejemplo por el de Cookly.
```bash
mkdir -p ~/Developer && cd ~/Developer
xtool new Cookly
cd Cookly
rm -rf Sources/Cookly/*
# Copiar el código de este repo (ajusten la ruta a donde descomprimieron el zip):
cp -r /mnt/c/Users/<usuario>/Downloads/Cookly-xtool/Sources/Cookly/* Sources/Cookly/
```
Abrir `xtool.yml` y poner un bundleID propio, por ejemplo:
```yaml
version: 1
bundleID: com.santiagovaldez.cookly
```
> Trabajen siempre en `~/Developer/Cookly` (dentro de WSL), no en `/mnt/c` ni en OneDrive.
> El `Package.swift` y `xtool.yml` incluidos en este zip son solo de referencia; usen los que genera `xtool new`.

Abrir en VS Code (con la extensión **WSL** y la extensión **Swift** instalada dentro de WSL):
```bash
code .
```

## 3. Compilar (sin iPhone todavía)
```bash
xtool dev
```
Si compila bien, se queda en *Waiting for device to be connected*. Eso significa que el código está bien y solo falta el teléfono.

## 4. Conectar el iPhone (solución del manual, sección XI)
**No usen usbipd**: en el laboratorio del semillero falló (*Device busy* y error *libusb -62*). El iPhone se queda conectado a **Windows** y WSL se comunica con el servicio de Apple.

En **Windows**, editar `%USERPROFILE%\.wslconfig` (con el Bloc de notas, no desde Ubuntu) y poner:
```ini
[wsl2]
networkingMode=mirrored
```
Luego, en **PowerShell**:
```powershell
wsl --shutdown
Get-Service "Apple Mobile Device Service"      # debe estar Running
```
En **Ubuntu/WSL**:
```bash
echo 'export USBMUXD_SOCKET_ADDRESS=127.0.0.1:27015' >> ~/.bashrc
source ~/.bashrc
timeout 3 bash -c 'echo > /dev/tcp/127.0.0.1/27015' && echo "Puerto 27015 accesible"
idevice_id -l               # debe mostrar el iPhone
idevicepair validate        # debe decir SUCCESS
```

## 5. Instalar en el iPhone
```bash
cd ~/Developer/Cookly
xtool dev
```
Debe completar *Provisioning, Signing, Installing, Verifying* al 100 %. La primera vez, en el iPhone: Ajustes → General → VPN y gestión de dispositivos → confiar en el Apple ID.

Ciclo diario: editar en VS Code → guardar → `xtool dev`.

> Con Apple ID gratuito la app deja de abrir a los 7 días: reinstálenla con `xtool dev` antes de la sustentación.
> Si aparecen errores de concurrencia de Swift 6 al compilar, agreguen al target en `Package.swift`: `swiftSettings: [.swiftLanguageMode(.v5)]`.

## Pantallas
| # | Pantalla | Qué demuestra |
|---|----------|---------------|
| 0 | Bienvenida | TextField, @AppStorage |
| 1 | Nevera | Lista por vencimiento, colores, búsqueda, filtro con @Binding, borrar con confirmación |
| 2 | Agregar / Editar | Formulario: TextField, Picker, Stepper, Toggle, DatePicker; validación |
| 3 | Buscar alimentos | **Red**: búsqueda por nombre o código de barras en Open Food Facts |
| 4 | Detalle del producto | **Red** (2ª petición) + agregar a la nevera (**persistencia**) |
| 5 | Recordatorios | Crear, marcar, borrar; guardado local |
| 6 | Perfil | Toggle modo oscuro, Stepper días de aviso, @Environment(\.colorScheme) |
| 7 | Acerca de | Créditos con los nombres del equipo |

## Cómo se cumple cada requisito
- **Navegación:** `TabView` + `NavigationStack`, `NavigationLink(value:)` + `navigationDestination`, `.sheet`.
- **Entradas de usuario:** TextField, Picker, Stepper, Toggle, DatePicker, `.searchable`.
- **Gestión del estado:** `@State`, `@Binding` (FilterBar), `@StateObject`/`ObservableObject` + `@Published`, `@Environment` (dismiss, colorScheme), `@AppStorage`, `@FocusState`.
- **Persistencia local:** `LocalRepository` guarda `products.json` y `reminders.json` en Documents con `Codable`.
- **Red:** `FoodAPIService` con `URLSession.data(for:)`, `async/await`, `Codable`, manejo de errores y estado de carga.
- **MVVM:** Vista → ViewModel (ObservableObject) → LocalRepository / FoodAPIService → archivos JSON / Open Food Facts.

## API usada
- Búsqueda: `GET https://world.openfoodfacts.org/cgi/search.pl?search_terms={texto}&search_simple=1&action=process&json=1&page_size=20`
- Producto: `GET https://world.openfoodfacts.org/api/v2/product/{codigo}.json`
- Se envía un `User-Agent` propio, como pide Open Food Facts. Datos bajo licencia ODbL.

Códigos de barras para probar: `3017624010701` (Nutella), `5449000000996` (Coca-Cola).

## Ramas (requisito: cada integrante en su rama)
- `main`: versión estable.
- `maria`: Modelos, Persistencia, Nevera, AddProduct, Acerca de.
- `santiago`: Red (FoodAPIService), Buscar, Detalle, Recordatorios, Perfil.
- Cada uno hace sus commits en su rama y se unen a `main` con pull request.
