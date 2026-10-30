# Checklist de la visita (un solo turno)

Orden fijo. No saltes al paso 2 con la app en rojo. Si un síntoma está en `PLAN_B.md`, aplícalo y vuelve al mismo número.

Antes de salir de casa: en `Sources/Cookly/Network/FoodAPIService.swift` línea 36, cambia `tu.correo@unicauca.edu.co` por tu correo institucional. Xcode marca el `TODO` de la línea 35.

## 1. Crear el proyecto y compilar

Sigue `XCODE_SETUP.md` de arriba a abajo. Criterio de salida: ⌘R muestra «COOKLY» y el campo del nombre, sin crash.

Si SwiftData muere en el arranque, cambia `PersistenceFactory.swift:12` a `JSONStore()` **ahora**, limpia y vuelve a correr. No lo dejes para la mitad de la demo.

## 2. Probar cada requisito en vivo

1. **Bienvenida.** Escribe un nombre y pulsa Empezar. Deben aparecer cuatro pestañas.
2. **Formulario.** Nevera > +. Categoría «Carne molida». El pie debe decir: «Recomendado: 1 a 2 días en refrigeración. La fecha sugerida usa el mínimo; ajústala según el empaque.» La fecha sugerida es mañana (hoy + 1). Cuenta las categorías del Picker: tienen que ser 11. Usa el Stepper y los dos Toggle. Guarda.
3. **Persistencia.** Stop en Xcode (no solo Home). ⌘R. El producto sigue ahí. Entra, edita el nombre, guarda. Desliza y confirma eliminar; desaparece. Vuelve a crear uno para la captura.
4. **Red.** Pestaña Buscar. Código `3017624010701` y Buscar: es Nutella (u otro producto de ese código) y al tocarlo el detalle hace una segunda consulta. Vuelve, busca `leche`: lista de resultados. Abre uno, «Agregar a mi nevera», guarda. Cambia a Nevera **sin** cerrar la app: el producto nuevo tiene que estar (lo empuja el publisher, no `.onAppear`).
5. **Sin internet.** Apaga el Wi‑Fi del Mac (el simulador usa esa red). Busca `leche`. El texto debe ser español («Sin conexión…», «Se perdió la conexión…» o «La consulta tardó…»), no inglés. Prueba también una sola letra: el aviso «Escribe al menos 2 letras.» no debe usar la pantalla de «Algo salió mal». Vuelve a encender el Wi‑Fi.
6. **Recordatorios.** Crea uno, márcalo, Stop, ⌘R: sigue guardado.
7. **Perfil.** Borra el nombre y sal del campo: **no** debe volver a Bienvenida; el nombre regresa y avisa que no puede quedar vacío. Escribe otro nombre, vuelve a Nevera y el título debe decir «Hola, …». Activa Modo oscuro y mira el wordmark y los iconos (el acento `#2FBDA8` en oscuro). Mueve el Stepper de días. Entra a Acerca de y confirma los dos nombres. Cerrar sesión **sí** vuelve a Bienvenida; los productos no se borran. Vuelve a entrar con tu nombre para las capturas.

Si en el paso 4 la otra pestaña no se entera, no sigas: es la fila del publisher en `PLAN_B.md`.

## 3. Capturas (⌘S en el Simulador)

Con datos en pantalla, no con listas vacías:

1. Bienvenida (wordmark COOKLY).
2. Nevera con al menos un producto y su etiqueta de color.
3. Agregar, con el pie de «Recomendado: X a Y días…» visible.
4. Buscar con resultados de «leche» o del código.
5. Detalle de un producto.
6. Recordatorios con uno creado.
7. Acerca de, con los dos nombres.

Si queda un minuto: Perfil en modo oscuro (Toggle, Stepper y contraste).

## 4. Commit de lo que se corrigió en el lab

Esta copia **no tiene `.git`**. No hay ramas `maria` ni `santiago` aquí, aunque el README las nombre.

- Si el trabajo oficial está en GitHub, lleva estos archivos a ese repo y haz el commit en **tu** rama.
- Si el profesor espera el repo y todavía no existe, créalo con el equipo; no lo inicialicé yo.
- No hagas `push --force`. No subas un `.bak` ni carpetas `.build`.
- El commit de la visita es solo lo que hayas tenido que tocar en el Mac (la línea de `JSONStore()`, un símbolo, el correo). El resto ya está en estos archivos.

Mensaje corto, por ejemplo: `Ajusta el almacén y lo verificado en el simulador del laboratorio.`
