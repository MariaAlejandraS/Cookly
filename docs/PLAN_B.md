# Plan B — síntoma exacto, causa, arreglo en una línea

Haz el arreglo, luego Product > Clean Build Folder y ⌘R. No cambies de almacén después de haber metido productos de la demo: SwiftData y JSON no comparten datos.

| Síntoma exacto | Causa probable | Arreglo en una línea |
|---|---|---|
| `Invalid redeclaration of 'CooklyApp'` o de `ContentView`, o `@main attribute can only apply to one type` | Siguen los dos archivos de la plantilla | Borra el `CooklyApp.swift` y el `ContentView.swift` que dicen Hello World; deja los de `Sources/Cookly`. |
| `Cannot find 'SwiftData' in scope`, o `'@Model' is only available in macOS 14` / iOS 17, o el archivo ni siquiera está en el target | Deployment Target &lt; 17, o el archivo no pertenece al target | Target > General > Minimum Deployments = 17.0; en el archivo, Target Membership = Cookly. |
| `Extra argument 'cloudKitDatabase' in call` en `SwiftDataStore.swift` | Ese SDK no tiene ese parámetro en el init usado | En el `init` de `SwiftDataStore`, deja `ModelConfiguration(isStoredInMemoryOnly: false)` y quita `cloudKitDatabase`. |
| Al pulsar ⌘R la app se cierra y la consola dice `SwiftData no pudo abrir la base` o `loadIssueModelContainer` | Contenedor de SwiftData (CloudKit, esquema o simulador) | En `PersistenceFactory.swift:12` cambia `SwiftDataStore()` por `JSONStore()`. No borres el `if let store`. |
| `Call to main actor-isolated initializer ... in a synchronous nonisolated context` | Default Actor Isolation = MainActor en un proyecto nuevo | Build Settings: Default Actor Isolation = nonisolated. |
| Errores de `Sendable` o de Swift 6 en código que aquí está en modo Swift 5 | Swift Language Version = Swift 6, o Strict Concurrency = Complete | Swift Language Version = Swift 5 y Strict Concurrency Checking = Minimal. |
| La app abre y un icono sale en blanco (no crashea) | El nombre de SF Symbol no existe en iOS 17 | Cambia ese string por `fork.knife`, `leaf.fill` o `basket.fill`. Si es la nevera de la pestaña: `archivebox.fill`. Lista en `AUDITORIA.md`. |
| Agregas un producto en Buscar, vuelves a Nevera y no está, pero al matar la app sí aparece | Dos almacenes distintos: alguien quitó la caché de la factory | Restaura el `if let store { return store }` de `PersistenceFactory.make()`. La línea 12 se ejecuta una sola vez. |
| Nevera vacía y la consola dice `No se sobrescribe` o `JSON dañado` | Solo aplica si ya estás en `JSONStore`. Un decode fallido no debe pisar el archivo | No borres el `.json`. Busca `products.json.bak` en el contenedor de la app. Con SwiftData este camino no se usa. |
| Buscar muestra inglés: `cancelled`, `The request timed out`, `The network connection was lost` | El error no pasó por `APIError` | Debe estar cubierto en `FoodAPIService.swift:90-97`. Si el código es otro, agrégalo junto al `case .notConnectedToInternet` de la línea 92. |
| Borrar el nombre en Perfil vuelve a Bienvenida | El TextField sigue atado a `@AppStorage("userName")` | El campo tiene que ser `$nameDraft` (`ProfileView.swift:25`). Cerrar sesión **sí** debe volver a Bienvenida. |
| `xtool dev` falla en `@Model` / macro de SwiftData | xtool no está obligado a expandir ese macro de Apple | Esta visita no usa xtool. Cambiar la factory a `JSONStore()` no saca `SwiftDataStore.swift` de la compilación. |

Si el fallo no está en la tabla: copia la **primera** línea roja de Xcode, no el párrafo de abajo. Casi siempre es una de estas doce.
