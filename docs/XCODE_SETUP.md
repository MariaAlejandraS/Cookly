# Xcode en el laboratorio — una sola pasada

Esta carpeta es un Swift Package para xtool. **No abras el `Package.swift` como si fuera la app.** Xcode no va a producir el binario de iPhone que necesitas. Crea un proyecto de app y mete estos fuentes ahí.

No hay icono 1024×1024 en el repo. Si lo traes, al final se arrastra a AppIcon. Si no lo traes, la app igual corre con el icono blanco de la plantilla.

El `TODO` del correo está en `Sources/Cookly/Network/FoodAPIService.swift` (línea 35). Pon el correo institucional **antes** de sentarte, desde Windows.

## 1. Proyecto nuevo

1. File > New > Project > iOS > App.
2. Interface: **SwiftUI**. Language: **Swift**. Storage: **None**.
   Storage None es obligatorio. Si eliges SwiftData en el asistente, la plantilla crea otro contenedor y choca con el nuestro.
3. Product Name: `Cookly`. Bundle Identifier: `co.edu.unicauca.cookly` (si el Mac dice que está tomado, agrega tus iniciales al final).
4. Guárdalo **fuera de OneDrive y fuera de iCloud** (Escritorio local o `/Users/…/Developer`).

## 2. Borrar la plantilla antes de copiar

En el navegador del proyecto, borra estos dos archivos de la plantilla (Move to Trash):

- `CooklyApp.swift`
- `ContentView.swift`

Hazlo **antes** de agregar los nuestros. Si no, hay dos `@main` y dos `ContentView`, y no compila.

## 3. Meter el código

1. En el Finder, entra a esta copia y abre `Sources/Cookly` (la carpeta que contiene `CooklyApp.swift`, `Models`, `Views`, etc.).
2. Arrástrala al proyecto de Xcode, sobre el grupo amarillo de la app.
3. En el diálogo: **Create groups** (no «Create folder references»). Marca el target de la app. Copia los ítems si te lo pregunta (Copy items if needed).
4. Comprueba que `CooklyApp.swift` aparece una sola vez y que el grupo es amarillo, no una carpeta azul.

No agregues el paquete como dependencia de SwiftPM y además arrastres los archivos. Serían símbolos duplicados.

## 4. Destino y lenguaje

Target Cookly > General > Minimum Deployments: **iOS 17.0**.

Target > Build Settings, busca y deja exactamente:

| Ajuste | Valor |
|---|---|
| Swift Language Version | Swift 5 |
| Default Actor Isolation | nonisolated (si el ajuste no aparece, este Xcode no lo tiene: sigue) |
| Strict Concurrency Checking | Minimal |

Eso alinea el proyecto con `Package.swift` (`.swiftLanguageMode(.v5)`). Un proyecto nuevo de Xcode reciente puede traer Default Actor Isolation = MainActor; con eso salen errores de `shared` y de inits que aquí no se pueden comprobar.

## 5. Correr

1. Arriba a la izquierda, elige un simulador iPhone con iOS 17 o superior.
2. Si pide Team, elige el Apple ID del laboratorio (Personal Team). El simulador no necesita cuenta de pago.
3. ⌘R.

La primera pantalla es la bienvenida. Si se cierra al instante con el texto «SwiftData no pudo abrir la base», ve a `PLAN_B.md` fila de SwiftData **antes** de cargar datos de la demo.

Consola: View > Debug Area > Activate Console. Los `print` de guardado salen ahí.

## 6. Icono y capturas

- Icono: abre `Assets.xcassets` > `AppIcon` y suelta el PNG de 1024×1024 en el único hueco. Un solo tamaño, sin alfa, si el catálogo lo exige.
- Capturas: con el Simulador al frente, ⌘S. El archivo cae en el Escritorio.

## Qué no hace falta tocar

- No hace falta excepción de App Transport Security: Open Food Facts es `https`.
- No hace falta permiso de cámara ni de ubicación.
- `xtool.yml` no lo lee este proyecto de Xcode.
