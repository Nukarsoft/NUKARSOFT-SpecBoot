---
name: show-spec-working
description: Usar cuando el usuario pide "show me X", "demo X", "walk me through X", "how X works" o solicita una demostración en vivo de una funcionalidad a partir de un spec, feature o ticket.
author: LIDR.co
version: 1.0.0
---

# Skill show-spec-working

Demostrá un spec de forma ejecutable.

Si el usuario no proporciona contexto explícito, usá el spec/change en el que se está trabajando actualmente en esta sesión.

Siempre finalizá informando la finalización en el chat.

## Frases disparadoras (alta prioridad)

Tratá estas expresiones como comandos de ejecución, no como pedidos de análisis:

- `show me X`
- `demo X`
- `walk me through X`
- `show X working`
- `how X works`
- `prove X works`

Cuando aparezca cualquiera de estas, ejecutá el flujo de demostración directamente.
No te detengas en un resumen de la funcionalidad ni en un reporte rápido.

## Entradas

- Contexto de spec opcional del usuario:
  - Id de ticket directo en el texto (por ejemplo: `SCRUM-10`)
  - Nombre de la feature
  - Endpoint
  - Ruta del frontend
- Si falta, inferilo del contexto de la sesión actual y del trabajo activo en curso.

## Flujo de trabajo

### Paso 1 - Resolver el spec objetivo y el alcance

1. Identificá el spec/change objetivo:
   - Preferí el contexto explícito proporcionado por el usuario.
   - Si el texto del usuario contiene un patrón de id de ticket como `[A-Z]+-[0-9]+`, usalo como contexto principal (ejemplo: `show me SCRUM-10`).
   - En caso contrario, inferí el spec en el que se está trabajando actualmente.
2. Determiná la modalidad:
   - `frontend` cuando el spec incluye comportamiento de UI.
   - `backend-only` cuando solo define comportamiento de API.
   - `mixed` cuando existen ambos.
3. Listá escenarios concretos para demostrar a partir de los criterios de aceptación del spec.

### Paso 1.1 - Regla de seguridad anti-reporte

Antes de continuar, aplicá esta regla:

- Nunca termines después de solo analizar los requirements.
- Nunca devuelvas solo un reporte rápido cuando el usuario pidió "mostrar" o "hacer una demo".
- Si la ejecución está bloqueada, informá explícitamente el bloqueo y pedí exactamente lo que se necesita para continuar la demo en vivo.

### Paso 2 - Ruta de demostración de frontend

Ejecutá esta ruta cuando la modalidad sea `frontend` o `mixed`.

1. Iniciá los servicios locales requeridos si es necesario.
2. Usá automatización de navegador para abrir la app y navegar hasta la funcionalidad objetivo.
3. Demostrá el comportamiento de la funcionalidad a partir del spec, una interacción a la vez.
   - Secuencia de ejemplo para funcionalidades de listado/tabla:
     - Abrir la página de listado
     - Verificar que aparecen los datos de la tabla
     - Usar el cuadro de búsqueda
     - Aplicar filtros
     - Cambiar el ordenamiento
     - Abrir la vista de detalle
4. Después de cada acción significativa:
   - Verificá que el resultado visible coincide con las expectativas del spec.
5. Detenete en un estado final estable y dejá que el usuario continúe la exploración manual o cierre la ventana.
6. Mantené el navegador abierto a menos que el usuario pida cerrarlo.

### Paso 3 - Ruta de demostración de API backend

Ejecutá esta ruta cuando la modalidad sea `backend-only` o `mixed`.

1. Identificá el/los endpoint(s) y el/los payload(s) de ejemplo definidos por el spec.
2. Ejecutá el/los comando(s) curl que muestren el comportamiento real de la respuesta.
3. Si alguna llamada cambia el estado de los datos (CREATE/UPDATE/DELETE):
   - Ejecutá el comando curl de restauración/reset correspondiente (o la acción de restauración equivalente) inmediatamente después de demostrar el comportamiento.
4. Confirmá el estado restaurado para que las demos repetidas sigan siendo deterministas.
5. Incluí el comando y la evidencia clave de la respuesta en el chat (de forma concisa).

## Requisitos del MCP de navegador

Antes de llamar a cualquier herramienta MCP de navegador:

1. Leé primero el JSON descriptor de la herramienta MCP.
2. Seguí las instrucciones del servidor para el flujo de lock/unlock y actualización de snapshots.
3. Evitá reintentos ciegos repetidos; si está bloqueado, informá el bloqueo y la mejor acción siguiente.

## Requisitos de la demo de API

- Usá comandos `curl` explícitos (no pseudocódigo) siempre que haya datos de entorno disponibles.
- Enmascará los valores sensibles en la salida del chat.
- Mantené los comandos idempotentes cuando sea posible.
- Incluí comandos de restauración para cualquier operación que cambie el estado.

## Contrato de finalización

Siempre enviá un mensaje final en el chat que contenga:

1. Spec/change objetivo demostrado.
2. Qué se ejecutó:
   - Flujos de frontend mostrados.
   - Comandos curl de backend ejecutados.
3. Resultado de verificación por cada escenario demostrado (pass/fail con una nota breve).
4. Estado de restauración de datos (si corresponde).
5. Cierre final:
   - "Demo completa. Podés seguir revisando en la ventana del navegador abierta o pedirme que la cierre."

## Formato de salida

Usá esta estructura concisa en la respuesta final del chat:

```markdown
Demo de spec completada para: <spec/change>

Recorrido de frontend:
- <paso/resultado>

Recorrido de API backend:
- <curl + nota clave de la respuesta>

Restauración de datos:
- <restaurada / no necesaria / falló + motivo>

Siguiente:
- Podés seguir revisando en la ventana del navegador abierta, o pedirme que la cierre.
```
