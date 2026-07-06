---
name: save-verify-report
description: Guardar el output del comando /verify de OpenSpec como archivo en el repo y como comentario en ClickUp. Ejecutar siempre después de /verify.
author: Nukarsoft
version: 1.0.0
---
# Skill save-verify-report

Ejecutá este skill **inmediatamente después de `/verify <TICKET-ID>`** para persistir el resultado de la verificación, que de lo contrario queda solo en el chat.

## Instrucciones

### Paso 1 — Capturar el output de /verify

El output de `/verify` ya está visible en el chat. Tomá el contenido completo de ese output (resultado de la validación contra los artefactos del change: spec, design, tasks).

### Paso 2 — Guardar como archivo en el repo

Guardá el output en:

```
openspec/changes/<TICKET-ID>/reports/YYYY-MM-DD-verify-report.md
```

Ejemplo: `openspec/changes/SCRUM-42/reports/2026-07-07-verify-report.md`

El archivo debe incluir:
- Fecha y hora de ejecución
- TICKET-ID
- Output completo del `/verify` (validaciones pasadas/falladas, gaps detectados)
- Veredicto final

Formato del archivo:

```markdown
# Verify Report — <TICKET-ID>

**Date**: YYYY-MM-DD HH:MM
**Change**: openspec/changes/<TICKET-ID>/

## Result

<output completo de /verify>

## Verdict
PASS | FAIL | PARTIAL
```

### Paso 3 — Comentar en ClickUp (si aplica)

Si en la sesión hay un ticket de ClickUp identificado (`.claude/clickup-workspace.local.md` existe):
- Resolé el Workspace usando el mecanismo de selección de enrich-us.
- Agregá un comentario al ticket con el veredicto y la ruta del archivo generado.

### Paso 4 — Confirmar al usuario

Mostrá al usuario:
- La ruta del archivo guardado
- El veredicto resumido (PASS / FAIL / PARTIAL)

## Notas

- Este skill no reemplaza `/verify` — lo complementa guardando su output.
- Si `/verify` no se ejecutó todavía en esta sesión, ejecutalo primero y luego corré este skill.
- La carpeta `openspec/changes/<TICKET-ID>/reports/` puede ya existir con reportes de `/apply` — agregá el archivo sin pisar los existentes.
