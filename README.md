# Cookly — Microproyecto SwiftUI (Taller 2)

Cookly es una nevera digital para iPhone: registra tus alimentos con su fecha de vencimiento, te avisa con colores cuáles vencen primero, lee el código de barras del producto para traer sus datos de internet y guarda recordatorios de comidas.

- **Asignatura:** Electiva Desarrollo de Aplicaciones Móviles — Universidad del Cauca
- **Profesor:** Ph.D. Cristhian Figueroa
- **Integrantes:** María Alejandra Solarte · Ronal Santiago Valdez Jurado

> Este repositorio también guarda la versión Android del taller anterior (carpeta `app/`, Gradle). **La app SwiftUI de este taller está en `Sources/Cookly/`.**

## Tecnologías
SwiftUI · MVVM (`ObservableObject` + `@Published`) · SwiftData (con respaldo en JSON) · URLSession + async/await + Codable · AVFoundation (cámara) · CryptoKit (contraseñas) · iOS 17+

## Pantallas
| # | Pantalla | Archivo | Qué demuestra |
|---|---|---|---|
| 1 | Inicio de sesión | `Views/Auth/LoginView.swift` | TextField, SecureField, validación, bloqueo por intentos |
| 2 | Registro | `Views/Auth/RegisterView.swift` | Formulario con validación en vivo |
| 3 | Nevera | `Views/NeveraView.swift` | Lista por vencimiento, colores, búsqueda, filtro con `@Binding` |
| 4 | Agregar / editar producto | `Views/AddProductView.swift` | TextField, Stepper, Toggle, DatePicker, cuadrícula de categorías |
| 5 | Escanear | `Views/Scan/ScanView.swift` | Cámara + **red** (Open Food Facts) + guardado automático |
| 6 | Detalle del producto | `Views/ProductDetailView.swift` | Datos de la API: Nutri-Score, ingredientes, alérgenos |
| 7 | Recordatorios | `Views/RemindersView.swift` | Formulario, Picker, DatePicker, días de la semana |
| 8 | Perfil | `Views/ProfileView.swift` | Modo oscuro (Toggle), días de aviso (Stepper), `@Environment` |
| 9 | Acerca de (créditos) | `Views/AboutView.swift` | Descripción y nombres del equipo |

## Arquitectura
```
Sources/Cookly/
├── CooklyApp.swift, ContentView.swift   Entrada, sesión y TabView
├── Models/        Product, Reminder, User, FoodCategory
├── ViewModels/    Nevera, AddProduct, Scan, ProductDetail, Reminders, Auth
├── Network/       FoodAPIService (URLSession) y modelos Codable de Open Food Facts
├── Persistence/   LocalStore (protocolo), SwiftDataStore, JSONStore, PersistenceFactory
├── Session/       SessionManager (cuenta activa)
├── Security/      PasswordHasher y PasswordPolicy
└── Views/         Pantallas y componentes reutilizables
```
Vista → ViewModel → `LocalStore` (SwiftData) / `FoodAPIService` (Open Food Facts). Las vistas no tocan la base ni la red directamente.

## API usada
Open Food Facts, pública y sin llave: `GET https://world.openfoodfacts.org/api/v2/product/{codigo}.json`. Se envía un `User-Agent` propio, como pide el servicio. Datos bajo licencia ODbL. Código para probar: `3017624010701`.

## Cómo correrlo
- **Xcode en Mac:** ver `docs/XCODE_SETUP.md`. Proyecto nuevo iOS App (SwiftUI, Storage: None, iOS 17), arrastrar `Sources/Cookly`, Swift 5 y agregar `NSCameraUsageDescription` en Info. Usa **SwiftData**. En el simulador no hay cámara: se usa el ingreso manual del código.
- **xtool desde Windows (WSL) a un iPhone:** `xtool dev` en esta carpeta. `Package.swift` define `NO_SWIFTDATA` porque xtool no procesa los macros de SwiftData, así que en ese caso la app guarda en **JSON** (`JSONStore`). La pantalla Acerca de muestra cuál almacenamiento está activo.

## Ramas
- `main`: versión estable.
- `Maria`: trabajo de María Alejandra.
- `Santiago`: trabajo de Santiago.
Cada integrante trabaja en su rama y se une a `main` con pull request.
