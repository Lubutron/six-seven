# NOVA · Catálogo de productos

Aplicación Flutter de demostración para iniciar sesión y administrar un catálogo
con Fake Store API (`https://fakestoreapi.com/products`).

## Ejecutar

```bash
flutter pub get
flutter run
```

Credenciales de demostración: **admin / admin123**. Son estáticas y solo sirven
para esta práctica; no sustituyen autenticación real.

## Estructura de `lib/`

- `models/`: modelo y conversión JSON del producto.
- `services/`: cliente HTTP y operaciones REST.
- `screens/`: inicio de sesión, catálogo, detalle y formulario.
- `widgets/`: tarjeta reutilizable de producto.

## API y conexión

El catálogo se obtiene con GET; crear, editar y eliminar utilizan POST, PUT y
DELETE. Fake Store API simula las mutaciones y no conserva los cambios de forma
permanente; la app actualiza el catálogo local durante la sesión. En caso de
falta de red, error HTTP o timeout, muestra el error y permite reintentar la
carga.

## Conceptos async

Los métodos de red devuelven `Future`: un resultado que estará disponible más
tarde. `async` permite escribir una función que retorna un `Future`, y `await`
espera su resultado sin bloquear la interfaz.

Modelo creado: `Product`.
