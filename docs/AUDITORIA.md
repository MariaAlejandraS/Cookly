# Auditoría Cookly — Taller 2 SwiftUI

Lectura del fuente el 29 oct 2026. No hay compilador de Swift en esta máquina: no se ejecutó `swift build` ni Xcode. Un ✅ de abajo significa que el fuente cubre el requisito, no que la app ya haya corrido.

Leyenda: ✅ el código lo cumple · ⚠️ está a medias o solo se cierra ejecutando · ❌ no está.

## Contradicciones (no las forcé)

1. El README dice que la persistencia es JSON porque xtool no expande el macro `@Model`, y que el proyecto se compila con xtool. El pedido de esta pasada es SwiftData para la visita a Xcode. Quedó SwiftData como almacén activo y JSON como plan B. **Cambiar la línea de `PersistenceFactory` no hace que xtool compile**: el compilador igual type-chequea `SwiftDataStore.swift`. Esta visita es Xcode, no `xtool dev`. El README quedó desactualizado a propósito; la guía de la visita es `docs/XCODE_SETUP.md`.
2. El README afirma ramas `main`, `maria` y `santiago`. En esta carpeta **no existe `.git`** (`git` no es un repositorio aquí). No inicialicé nada ni hice push.
3. `PersistenceFactory.make()` no es una función de un solo renglón. Si cada llamada hiciera `SwiftDataStore()` nuevo, habría dos `ModelContainer` y el publisher no cruzaría pestañas. La **línea que se cambia** sí es una: `PersistenceFactory.swift:12`.

## Requisitos del enunciado

| Requisito | Evidencia | Estado | Acción |
|---|---|---|---|
| Mínimo 5 pantallas distintas | `WelcomeView.swift:5`, `NeveraView.swift:4`, `AddProductView.swift:4`, `SearchView.swift:5`, `ProductDetailView.swift:5`, `RemindersView.swift:4`, `ProfileView.swift:4` | ✅ | En el lab, recorrerlas. Agregar es un sheet; igual es otra vista. |
| Pantalla de descripción/créditos con nombres | `AboutView.swift:4`, nombres en `AboutView.swift:24-25` (María Alejandra Solarte, Ronal Santiago Valdez Jurado) | ✅ | Abrirla desde Perfil y capturarla. |
| Navegación | `ContentView.swift:15` TabView; `SearchView.swift:38` NavigationLink(value:); `SearchView.swift:49` navigationDestination; `ProfileView.swift:48` NavigationLink a Acerca de; sheets en `NeveraView.swift` | ✅ | Demostrar pestañas, push al detalle y hoja de alta. |
| TextField, Toggle, Stepper | TextField `WelcomeView.swift:27`, `AddProductView.swift:16`, `RemindersView.swift:11`, `ProfileView.swift:25`. Toggle `AddProductView.swift:29` y `:41`, `RemindersView.swift:22`, `ProfileView.swift:42`. Stepper `AddProductView.swift:25`, `ProfileView.swift:43` | ✅ | Mostrar los tres en la demo. También hay Picker y DatePicker. |
| Estado: @State, @Binding, @ObservedObject o @Environment | `@State` en Welcome y Profile; `@Binding` en `Theme.swift:114` (FilterBar, usado en `NeveraView.swift:25`); `@Environment` dismiss `AddProductView.swift:5` y colorScheme `ProfileView.swift:8`; `@StateObject` en las pantallas; `@Published` en los ViewModel | ✅ | `@ObservedObject` no aparece. El dueño del ViewModel es `@StateObject`, que es el API correcto. Si preguntan, la diferencia es quién crea el objeto. |
| Base de datos local | SwiftData: `SwiftDataStore.swift:8` y `:46` (`@Model`), un contenedor en el `init` (`SwiftDataStore.swift:74-88`). Los structs `Product` y `Reminder` no se tocaron. | ⚠️ | Es base de datos en el fuente. No se pudo abrir el contenedor aquí. Si falla en el Mac, `PersistenceFactory.swift:12` → `JSONStore()`. JSON es persistencia local, pero ya no es el motor principal. |
| Red con API en línea | `FoodAPIService.swift:50` búsqueda y el GET por código; `URLSession` en `:85`. API: Open Food Facts, HTTPS, sin llave. | ⚠️ | El código está. Falta la prueba viva: `3017624010701`, «leche» y sin internet. |
| ViewModel, servicios web y persistencia en módulos | `ViewModels/`, `Network/`, `Persistence/LocalStore.swift:8`. Los ViewModel de nevera, recordatorios y alta dependen de `any LocalStore`, no de la clase concreta. | ✅ | — |
| Repo público y una rama por integrante | No hay `.git` en esta carpeta. El README lo afirma; el directorio no lo respalda. | ❌ | Resolver con el equipo fuera de esta copia. No creé el repo. |

## Rúbrica (qué puede mostrar el código y qué no)

| Criterio | Peso | Lectura |
|---|---|---|
| Diseño | 15% | ⚠️ Colores de marca en `Theme.swift:77-81` y wordmark `WelcomeView.swift:19`. El contraste está calculado, no visto en el simulador. |
| Navegación + 5 pantallas | 10% | ✅ Hay más de cinco vistas más Acerca de. |
| Networking | 15% | ⚠️ Cliente completo, incluida el 429 y los mensajes en español. Falta la llamada real. |
| Persistencia | 20% | ⚠️ SwiftData + red de seguridad JSON. Es el ítem de más riesgo en el Mac. |
| ViewModel | 10% | ✅ MVVM con `ObservableObject` y protocolo de persistencia. |
| Informe | 10% | ❌ No hay informe en el repo (el README es manual de xtool, no el informe del taller). |
| Preguntas individuales | 20% | ❌ No viven en el código. Hay que prepararlas. |

## Revisión tipo compilador

Severidad: alta = puede tumbar la demo o borrar datos; media = falla visible; baja = raro o solo visual.

| Hallazgo | Dónde estaba | Sev. | Qué se hizo |
|---|---|---|---|
| Si el JSON no decodifica, la lista queda `[]` y el siguiente guardado pisa el archivo | `LocalRepository` (ya no existe): el `read` devolvía nil y el init usaba `?? []` | Alta | `JSONStore.swift:6-7`, `:110-113`, `:127`. Archivo dañado se mueve a `.bak`. Si no se puede mover, no se escribe. Categorías viejas se mapean en `FoodCategory.swift` (`init(from:)`) para que el cambio de nombres no dispare ese camino. |
| Borrar el nombre en Perfil vaciaba `@AppStorage("userName")` y `ContentView` volvía a Bienvenida | `ProfileView` enlazaba el TextField a `userName` | Alta | `ProfileView.swift:25` usa `nameDraft`. `commitName()` (`:78-84`) solo escribe si hay texto. Cerrar sesión sí vacía el nombre (`:68`) y es intencional. |
| Una búsqueda cancelada apagaba `isLoading` de la siguiente y podía pintar error | `SearchViewModel`: `defer { isLoading = false }` y solo `CancellationError` | Alta | Token `latestSearchID` (`SearchViewModel.swift:34-57`). Se ignoran `CancellationError` y `URLError.cancelled`. El `isLoading` final solo lo pone la tarea vigente. |
| «Mínimo 2 letras» salía en la pantalla de error de red | El mismo `errorMessage` | Media | `validationMessage` (`SearchViewModel.swift:27`) y el aviso aparte en `SearchView.swift:11-15`. La pantalla con `wifi.exclamationmark` queda solo para `errorMessage`. |
| HTTP 429, timeout y conexión perdida | `FoodAPIService` solo traducía «sin internet» | Media | `FoodAPIService.swift:22` (429), `:94-97` (timeout y connection lost). Otros cortes de red van al mensaje de sin conexión (`:92`). |
| User-Agent sin el formato pedido | Texto fijo «proyecto academico» | Media | `FoodAPIService.swift:35-40`: `Cookly-iOS/1.0 (correo)`. El correo es un placeholder con `TODO`. |
| `static let shared = ClaseMainActor()` y argumentos por defecto `.shared` | Inits de repositorio y de la API | Media, según el Xcode | Los ViewModel usan `nil` por defecto y resuelven `.shared` / `PersistenceFactory.make()` dentro del init, que es `@MainActor`. Queda `FoodAPIService.shared` y `URLSession.shared`. Si el proyecto nuevo trae Default Actor Isolation = MainActor, el arreglo de laboratorio está en `XCODE_SETUP.md` (ponerlo en nonisolated). |
| Refresco solo con `.onAppear` | Nevera y Recordatorios | Media | Publisher `changes` en `LocalStore.swift` y suscripción en `NeveraViewModel.swift:28-31` y `RemindersViewModel.swift:20`. Se quitó el `.onAppear` de recarga. El `onDismiss` del sheet se dejó. |
| Categorías distintas a las 11 de FDA/USDA, un solo `suggestedDays` | `FoodCategory` anterior | Alta (requisito) | `FoodCategory.swift:7-17`. Fecha = hoy + `minDays` (`AddProductViewModel.swift:59-60`). Pie exacto en `AddProductView.swift:37`. |
| SF Symbols dudosos (`scalemass`, `applelogo`, `waterbottle.fill`, `carrot.fill`, etc.) | Varias vistas y el enum viejo | Baja (no compila: icono en blanco) | Sustituidos. Lista para la app SF Symbols, más abajo. |
| `OFFProduct` sin `code` genera un `UUID()` nuevo en cada decode | `FoodAPIModels.swift:56` | Baja | No se tocó. En la práctica Open Food Facts manda `code`. |
| APIs posteriores a iOS 17 | Revisión de los 21 archivos | — | No aparecieron `#Predicate`, `@Query`, `symbolEffect`, `MeshGradient` ni el `Tab` de iOS 18. `NavigationStack`, `searchable` y `foregroundStyle` son de iOS 15–16. Lo nuevo (`@Model`, `onChange` de dos parámetros, `ModelConfiguration`) es de iOS 17. |

Archivos originales sin error de compilación evidente por lectura: `CooklyApp.swift`, `ContentView.swift`, `Product.swift`, `Reminder.swift`, `FoodAPIModels.swift` (salvo el UUID), `WelcomeView.swift`, `NeveraView.swift`, `AddProductView.swift`, `ProductDetailView.swift`, `RemindersView.swift`, `AboutView.swift`. Los problemas de esos archivos eran de ejecución o de requisito, no de sintaxis, y quedaron en la tabla.

`Package.swift:7` pide iOS 17 y `Package.swift:22` fija Swift 5. El proyecto de Xcode **no usa** ese `Package.swift`: hay que repetir esas dos decisiones en Build Settings. El paquete también declara macOS 14; la app del lab es solo iOS.

## Contraste (calculado, no visto)

| Par | Ratio | Uso |
|---|---|---|
| `#188489` sobre blanco | 4.47:1 | Botón y tint. Pasa componente y texto grande; queda 0.03 bajo 4.5:1 de texto normal. |
| `#188489` sobre `#1C1C1E` | 3.81:1 | Insuficiente para texto pequeño. Por eso el icono en oscuro no usa el primario. |
| `#2FBDA8` sobre `#1C1C1E` | 7.26:1 | `brandForeground` en oscuro (`Theme.swift:81`). |
| `#2FBDA8` sobre blanco, o blanco sobre `#2FBDA8` | 2.34:1 | No se usa el acento como texto ni como botón con letra blanca. |
| `#111111` sobre `#2FBDA8` | ~8.1:1 | Icono de bienvenida (`WelcomeView.swift:15`) sobre el recuadro acento. |
| `#111111` sobre blanco | 18.88:1 | Tinta en modo claro. |
| `#111111` sobre `#1C1C1E` | 1.11:1 | Ilegible. En oscuro la tinta es `#F4F7F7` (15.79:1). |

Hay que mirar el botón «Empezar» y la pestaña seleccionada en claro y en oscuro. El tint sigue siendo `#188489` para no aclarar el botón y empeorar el blanco encima.

## `from(offTags:)` — cómo desempata

Etiqueta concreta gana a la genérica: `en:apples` + `en:fruits` → Frutas firmes, no blandas. Si hay varias concretas, gana la de menor `minDays`. Solo si no hay concreta: `fruit` → blandas (1), `meat` → carne molida (1), el resto → otros. Consecuencia a defender: pollo cocido puede quedar como «Pollo o pavo crudo» (1 día, no 3) porque el mínimo manda. Atún enlatado puede quedar como pescado crudo por la misma regla. Leche → Lácteos abiertos. Nutella, sin etiqueta de esas, → Otros/enlatados abiertos.

## SF Symbols para verificar en el Mac

Buscar cada nombre en la app SF Symbols con disponibilidad iOS 17. Si uno no está, la app no se cae: el icono sale vacío. Reemplazo seguro: `fork.knife`, `leaf.fill` o `basket.fill`.

Verificar: `refrigerator.fill`, `fork.knife`, `fish.fill`, `cup.and.saucer.fill`, `leaf.fill`, `basket.fill`, `bag.fill`, `wifi.exclamationmark`, `person.crop.circle`.

De uso amplio desde iOS 13–14 (menos riesgo): `magnifyingglass`, `bell.fill`, `bell.slash`, `photo`, `plus`, `plus.circle.fill`, `trash`, `circle`, `checkmark.circle.fill`, `info.circle`, `exclamationmark.circle`, `exclamationmark.triangle.fill`, `xmark.octagon.fill`, `person.fill`, `leaf`, `tray`.

Si `refrigerator.fill` sale vacío, cambiarlo por `archivebox.fill` en `ContentView.swift:17`, `WelcomeView.swift:13` y `AboutView.swift:9`.
