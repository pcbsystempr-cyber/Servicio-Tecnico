# Plan de corrección: Calificaciones de los maestros

## Problema identificado
- `calificar.html` guardaba evaluaciones en `localStorage` (clave `evaluaciones`) como respaldo. Esta clave creció tanto que causó `QuotaExceededError` (la base de datos local está llena).
- Como consecuencia, ni `calificar.html` ni `index.html` ni `dashboard.html` podían leer/escribir de `localStorage` sin lanzar errores.

## Acciones tomadas
- [x] `calificar.html`: Eliminar guardado en `localStorage` de evaluaciones.
- [x] `index.html`: Eliminar fallback a `localStorage` de evaluaciones.
- [x] `dashboard.html`: Eliminar lectura de `localStorage` en `loadSuggestions()`.
- [ ] Limpiar la clave `evaluaciones` del `localStorage` manualmente (paso final).

