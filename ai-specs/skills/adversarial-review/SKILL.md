---
name: adversarial-review
description: Usar cuando el usuario solicite una revisión adversarial, revisión red-team, verificación tipo "abogado del diablo", o una pasada de verificación independiente antes de archivar un cambio de OpenSpec.
author: LIDR.co
version: 1.0.0
---

# Skill adversarial-review

Actuá como un **revisor adversarial independiente**: asumí que pueden existir vacíos, fallas o comportamiento inseguro hasta que hayas argumentado en contra de ellos con evidencia.

Este skill está pensado para la **ventana de verificación** del desarrollo guiado por especificaciones (después de la implementación, **antes** de archivar), cuando el humano ejecuta un **agente o sesión distinta** de la que implementó el cambio.

**No** prescribas qué agente, modelo o IDE usar. Esa es decisión del humano.

## Entradas

- Contexto opcional del usuario (mismo estilo que `show-spec-working`):
  - ID de ticket directo en el texto (por ejemplo: `SCRUM-10`)
  - Nombre de la funcionalidad o cambio
  - Endpoint(s)
  - Ruta(s) del frontend
  - **Pull request**: URL, o host owner/repo y número (por ejemplo: `https://github.com/org/repo/pull/42` o `owner/repo#42`)
- Si falta, inferilo de la sesión actual (cambio activo, branch, o carpeta de OpenSpec).

Resolvé el alcance en este orden: ticket o nombre de cambio explícito → PR si se indica → trabajo activo actual.

## Mentalidad (revisión adversarial)

Tomado de la práctica común de red-team / adversarial:

- **Intentá romper el sistema**, no solo confirmar los casos felices.
- **Buscá suposiciones incorrectas** sobre forma de los datos, timing, orden, autorización, idempotencia y manejo de errores.
- **Rastreá riesgos de composición y cruce de límites**: piezas que se ven bien de forma aislada pero fallan juntas (multi-archivo, API más UI, reintentos más efectos secundarios).
- **Tratá el diff como contexto incompleto**: tests faltantes, casos negativos faltantes, o desalineación de la especificación pueden ocultar problemas.
- **Calibrá la profundidad** según el riesgo: autenticación, pagos, PII, límites de privilegios y mutación de datos merecen un escrutinio más estricto.

## Flujo de trabajo

### Paso 1 — Cargar primero el lado de la especificación

1. Identificá el directorio del cambio de OpenSpec y leé los artefactos relevantes (proposal, design, specs, scenarios, `tasks.md`).
2. Extraé los **criterios de aceptación y los no-objetivos explícitos**. Listá qué debe ser cierto para considerarlo "hecho".
3. Anotá cualquier cosa **subespecificada** (aceptación ambigua, casos de error faltantes, restricciones de seguridad faltantes).

### Paso 2 — Cargar el lado de la implementación

1. Si se proporcionó un **PR**, tratalo como la superficie principal de implementación:
   - Leé la descripción del PR y revisá el alcance completo del diff (no solo el orden de archivos por defecto).
   - Mapeá **archivos y cambios** a las secciones de la spec y a las tareas.
2. Si no hay PR: usá `git diff` contra el merge base o el branch asociado al cambio, según la convención del proyecto.

### Paso 3 — Pasada adversarial (refutar, no aprobar automáticamente)

Para cada criterio de aceptación o escenario:

1. Indicá cómo la implementación **todavía podría fallar** aunque el autor creyera que pasaba (entrada incorrecta, fallo parcial, doble envío, caché desactualizada, rol incorrecto, condición de carrera, estado vacío, payload de tamaño excesivo).
2. Revisá **casos negativos y de abuso** cuando corresponda (strings de bypass de validación, patrones de acceso tipo IDOR, replay, manejo de conflictos).
3. Revisá **tests y artefactos de verificación**: ¿realmente **prueban** el criterio, o solo el camino feliz?
4. Registrá las **discrepancias entre spec y código** (la spec dice X, el código hace Y) como hallazgos de primer nivel.

### Paso 4 — Severidad y recomendaciones

Clasificá cada hallazgo:

- **Bloqueante**: comportamiento incorrecto, problema de seguridad/privacidad, o violación de la spec que debería detener el archivado.
- **Mayor**: bug probable o vacío significativo; se requiere corrección o actualización de la spec antes de archivar.
- **Menor**: claridad, mantenibilidad, o vacío de bajo riesgo; puede quedar como seguimiento.
- **Pregunta / suposición**: necesita confirmación del humano o del autor.

Para cada hallazgo, indicá si la corrección corresponde a **código**, **tests**, **artefactos de OpenSpec** (scenarios, specs, tasks), o **documentación**.

### Paso 5 — Veredicto

Terminá con un veredicto claro:

- **APROBADO**: sin bloqueantes ni mayores; menores listados opcionalmente.
- **APROBADO CON VACÍOS**: solo menores, pero registrados.
- **RECHAZADO**: al menos un bloqueante o mayor sin resolver.

## Formato de salida

Usá esta estructura en el chat:

```markdown
## Revisión adversarial

**Alcance**: <ticket / change / PR>
**Fuentes**: <rutas de spec + referencia al PR o diff>

### Alineación con spec y tareas
- ...

### Hallazgos

| Severidad | Área | Hallazgo | Evidencia | Corrección sugerida (código / spec / tests) |
|-----------|------|----------|-----------|---------------------------------------------|
| Bloqueante / Mayor / Menor | | | | |

### Veredicto
APROBADO | APROBADO CON VACÍOS | RECHAZADO

### Próximos pasos recomendados (antes de archivar)
- ...
```

## Persistencia del reporte (obligatorio)

Una vez generado el reporte, **siempre** persistilo en dos lugares:

### 1. Archivo en el repo

Guardá el reporte completo como archivo Markdown en:

```
openspec/changes/<TICKET-ID>/reports/YYYY-MM-DD-adversarial-review.md
```

Ejemplo: `openspec/changes/SCRUM-42/reports/2026-07-07-adversarial-review.md`

El archivo debe contener el reporte completo tal como se generó (scope, sources, findings, verdict, next steps).

### 2. Comentario en ClickUp (si aplica modo ClickUp)

Si en la sesión hay un ticket de ClickUp identificado (`.claude/clickup-workspace.local.md` existe), agregá un comentario al ticket en **español** con:
- El veredicto (`APROBADO` / `APROBADO CON VACÍOS` / `RECHAZADO`)
- Un resumen de los hallazgos (bloqueantes y mayores, si los hay)
- La ruta del archivo de reporte generado en el repo

### 3. Grabaciones de pantalla (testing manual)

Si el ticket incluye testing manual o demos:
- Grabá con **Loom** (gratis en [loom.com](https://loom.com)) o con Windows Game Bar (`Win+G`)
- Pegá el link de Loom como comentario en el ticket de ClickUp
- Opcionalmente, guardá el archivo de video en `openspec/changes/<TICKET-ID>/recordings/`

## Barreras de protección (guardrails)

- **No** elogies la implementación para "balancear" la crítica, a menos que una fortaleza **mitigue directamente un riesgo documentado**.
- **No** te saltees la lectura de los artefactos de OpenSpec cuando existan en el repo.
- Si no podés acceder al PR o al diff, decilo y listá exactamente qué se necesita para continuar.

## Finalización

Terminá siempre con el veredicto y si archivar es **recomendable** en el estado actual.
