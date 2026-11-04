# Checklist de la visita (un solo turno)

Orden fijo. No saltes al paso 2 con la app en rojo. Si un síntoma está en `PLAN_B.md`, aplícalo y vuelve al mismo número.

## 1. Crear el proyecto y compilar

Sigue `XCODE_SETUP.md` de arriba a abajo, incluido el permiso de cámara del paso 5, antes de ⌘R. Criterio de salida: la app abre en el inicio de sesión, sin crash.

Si SwiftData muere en el arranque, aplica la fila de SwiftData en `PLAN_B.md` ahora. No lo dejes para la mitad de la demo.

## 2. Dos cuentas, cada una con su nevera

1. Regístrate (nombre, usuario y contraseña de al menos 8 caracteres, con letra y número).
2. En Nevera agrega un producto con un nombre reconocible, por ejemplo «Leche de Ana».
3. Perfil > Cerrar sesión.
4. Registra una segunda cuenta. Su Nevera debe estar vacía: no debe verse «Leche de Ana».
5. Agrega otro producto, por ejemplo «Pan de Luis». Cierra sesión.
6. Entra con la primera cuenta. Solo debe estar «Leche de Ana».

## 3. Cinco contraseñas mal seguidas

En el inicio de sesión, escribe un usuario que exista y una contraseña incorrecta. Repite cinco veces. Debe aparecer «Demasiados intentos. Intenta de nuevo en N s.» y el botón de entrar no debe dejar pasar hasta que el contador llegue a cero. Luego entra con la contraseña buena.

## 4. Código real, ingreso manual

Pestaña Escanear. En el simulador no hay cámara: usa el campo de código. Escribe `3017624010701` y busca.

El producto se agrega solo, con categoría y fecha sugerida. No hace falta pulsar Guardar. Pasa a Nevera: el producto está ahí. Si la categoría es 1 día, la tarjeta del escaneo dice «Vence mañana (sugerido)»; si son más, «Vence en N días (sugerido)».

## 5. Código que no existe

En Escanear, ingreso manual, escribe `00000000`. Debe decir «No encontramos este código». Pulsa «Agregar manualmente» y completa el formulario a mano.

## 6. Editar y deshacer

Escanea o ingresa otro código que sí exista. En la tarjeta del producto:

- Editar: cambia el nombre o la fecha, guarda, y comprueba el cambio en Nevera.
- Deshacer: el producto desaparece de la nevera.

## 7. Recordatorio que se repite

Pestaña Recordatorios. Crea uno con «Se repite» y al menos un día de la semana. Márcalo hecho. Stop en Xcode y ⌘R: sigue guardado.

## 8. Modo oscuro

Perfil > Modo oscuro. Revisa Nevera, Escanear y Perfil: el fondo no queda blanco y el texto se lee. Apaga el interruptor y vuelve el tema claro.

## 9. Cerrar sesión

Perfil > Cerrar sesión. Vuelve el inicio de sesión. Entra de nuevo: los productos de esa cuenta siguen.

## 10. Sin internet

Apaga el Wi‑Fi del Mac (el simulador usa esa red). En Escanear, ingreso manual de `3017624010701`. El texto debe ser español («Sin conexión…», «Se perdió la conexión…» o «La consulta tardó…»), no inglés. Vuelve a encender el Wi‑Fi.

## 11. Capturas (⌘S en el Simulador)

Con datos en pantalla, no con listas vacías:

1. Inicio de sesión, con el wordmark COOKLY.
2. Nevera de una cuenta, con su producto y la pastilla de vencimiento.
3. Escanear, con el producto agregado a partir de `3017624010701`.
4. «No encontramos este código».
5. Recordatorios, con uno que se repite.
6. Perfil en modo oscuro y Acerca de, con los dos nombres.

La cámara solo se prueba en un iPhone físico. En el simulador basta el ingreso manual. Si Escanear dice «Falta NSCameraUsageDescription», falta el paso 5 de `XCODE_SETUP.md`; el ingreso manual igual debe funcionar.
