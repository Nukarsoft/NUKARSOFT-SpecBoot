---
name: save-closure-report
description: Generar y guardar el reporte de cierre de un ticket SpecBoot. Documenta el estado de cada etapa del flujo (propose, apply, security review, verify, QA, archive, sync, commit) y lo persiste en el repo y en ClickUp como comentario de cierre oficial.
author: Nukarsoft
version: 1.0.0
---
# Skill save-closure-report

Usalo **al finalizar el flujo completo de un ticket** — después de `/commit` — para dejar evidencia formal de qué se ejecutó, con qué resultado y si el ticket quedó completamente cerrado.

Se invoca:
- **Bajo demanda**: `/save-closure-report <TICKET-ID>`
- **Como parte del flujo**: es el último paso obligatorio después de `/commit`.

## Instrucciones

### Paso 1 — Obtener el TICKET-ID y contexto

Resolvé el TICKET-ID desde `$ARGUMENTS`. Si no se proporcionó, pedíselo al usuario.

Leé el archivo `.claude/clickup-workspace.local.md` si existe para obtener el workspace de ClickUp.

Obtenés el título del ticket desde ClickUp si es posible, o desde el nombre del change en `openspec/changes/<TICKET-ID>/`.

### Paso 2 — Verificar el estado de cada etapa del flujo

Para cada etapa, determiná si se ejecutó y con qué resultado. Usá estas fuentes en orden de prioridad:

1. **Archivos en el repo** (`openspec/changes/<TICKET-ID>/`) — son la fuente de verdad.
2. **Historial de la sesión actual** — si el usuario ejecutó el paso en esta sesión.
3. **Pregunta explícita al usuario** — solo si no podés determinarlo por las fuentes anteriores.

#### Mapa de evidencias por etapa

| Etapa | Evidencia esperada | Comando que la generó |
|---|---|---|
| Propose | `openspec/changes/<TICKET-ID>/proposal.md` + `design.md` + `tasks.md` | `/opsx:propose` |
| Apply | `tasks.md` con todas las tareas completadas + código en el repo | `/opsx:apply` |
| Security review | `openspec/changes/<TICKET-ID>/reports/*-security-review-*.docx` | `/security-review` |
| Verify | `openspec/changes/<TICKET-ID>/reports/*-verify-report.md` | `/opsx:verify` + `/save-verify-report` |
| QA / Adversarial review | `openspec/changes/<TICKET-ID>/reports/*-qa-report.md` o `*-adversarial-review.md` | `/adversarial-review` + `/save-qa-report` |
| Archive | `openspec/changes/archive/<FECHA>-<TICKET-ID>/` | `/opsx:archive` |
| Sync specs | `openspec/specs/<capability>/spec.md` actualizado | Parte del archive |
| Commit / PR | `git log --oneline -5` para encontrar el hash; `gh pr list` para la URL del PR | `/commit` |

Para cada etapa ejecutá los comandos shell necesarios para verificar la existencia de los archivos:

```bash
# Verificar artefactos de propose
ls openspec/changes/<TICKET-ID>/proposal.md 2>/dev/null && echo "EXISTS" || echo "MISSING"
ls openspec/changes/<TICKET-ID>/design.md 2>/dev/null && echo "EXISTS" || echo "MISSING"
ls openspec/changes/<TICKET-ID>/tasks.md 2>/dev/null && echo "EXISTS" || echo "MISSING"

# Verificar reports
ls openspec/changes/<TICKET-ID>/reports/ 2>/dev/null

# Verificar archive
ls openspec/changes/archive/ 2>/dev/null | grep "<TICKET-ID>"

# Verificar commit
git log --oneline -5

# Verificar PR
gh pr list --state all --search "<TICKET-ID>" 2>/dev/null | head -3
```

### Paso 3 — Asignar estado a cada etapa

Para cada etapa asigná uno de estos estados:

| Estado | Ícono | Criterio |
|---|---|---|
| PASS | ✅ | Se ejecutó y la evidencia está completa y sin errores reportados |
| PASS CON OBSERVACIONES | ⚠️ | Se ejecutó pero hubo hallazgos menores o pasos parciales |
| FAIL | ❌ | Se ejecutó pero terminó con errores o hallazgos críticos no resueltos |
| NO EJECUTADO | ⏭️ | No hay evidencia de que se haya corrido en este ticket |
| OMITIDO (justificado) | 🔕 | El usuario confirmó que se saltó con motivo válido |

### Paso 4 — Determinar el veredicto general

| Veredicto | Criterio |
|---|---|
| ✅ CERRADO — APROBADO | Todos los pasos obligatorios en PASS o PASS CON OBSERVACIONES |
| ⚠️ CERRADO CON DEUDA | Algún paso en OMITIDO o CON OBSERVACIONES sin impacto crítico |
| ❌ NO CERRADO | Al menos un paso obligatorio en FAIL o sin evidencia |

**Pasos obligatorios** (no se puede cerrar sin ellos): Propose, Apply, Security review, Archive, Commit.
**Pasos recomendados** (su ausencia genera deuda): Verify, QA / Adversarial review, Sync specs.

### Paso 5 — Guardar el reporte en el repo

Guardá el archivo en:
```
openspec/changes/<TICKET-ID>/reports/YYYY-MM-DD-closure-report.md
```

Si el change ya fue archivado, guardalo en:
```
openspec/changes/archive/<FECHA>-<TICKET-ID>/reports/YYYY-MM-DD-closure-report.md
```

Formato del archivo:

```markdown
# Reporte de Cierre — <TICKET-ID>

**Fecha de cierre**: YYYY-MM-DD HH:MM
**Ticket**: <TICKET-ID> — <Título del ticket>
**Change**: <nombre del change>
**Veredicto**: ✅ CERRADO — APROBADO | ⚠️ CERRADO CON DEUDA | ❌ NO CERRADO

---

## Estado por etapa

| Etapa | Estado | Detalle |
|---|---|---|
| Propose (proposal / design / specs / tasks) | ✅ PASS | Artefactos generados completos |
| Apply (implementación + tests) | ✅ PASS | Todas las tareas completadas (N/N) |
| Security review | ✅ PASS | Sin hallazgos / N hallazgos resueltos |
| Verify | ✅ PASS | Reporte en reports/YYYY-MM-DD-verify-report.md |
| QA / Adversarial review | ✅ PASS | Reporte en reports/YYYY-MM-DD-qa-report.md |
| Archive OpenSpec change | ✅ PASS | openspec/changes/archive/FECHA-TICKET-ID/ |
| Sync specs | ✅ PASS | openspec/specs/<capability>/spec.md actualizado |
| Commit / PR | ✅ PASS | Commit `<hash>` — PR: <url o "pusheado a main"> |

---

## Deuda técnica / observaciones

<Listado de cualquier hallazgo, paso omitido con justificación, o tarea pendiente para futuros tickets>

---

## Artefactos generados en este ticket

- `openspec/changes/<TICKET-ID>/proposal.md`
- `openspec/changes/<TICKET-ID>/design.md`
- `openspec/changes/<TICKET-ID>/tasks.md`
- `openspec/changes/<TICKET-ID>/reports/` — <N archivos>
- `openspec/specs/<capability>/spec.md`
```

### Paso 6 — Persistir en ClickUp

Si existe `.claude/clickup-workspace.local.md`, usá el MCP de ClickUp para:

**Agregar comentario de cierre al ticket** con el siguiente formato Markdown:

```markdown
## ✅ Reporte de Cierre — <TICKET-ID>

**Change:** `<nombre-del-change>`
**Veredicto:** ✅ CERRADO — APROBADO

---

| Etapa | Estado | Detalle |
|---|---|---|
| Propose (proposal / design / specs / tasks) | ✅ PASS | ... |
| Apply (implementación + tests) | ✅ PASS | ... |
| Security review | ✅ PASS | ... |
| Verify | ✅ PASS | ... |
| QA / Adversarial review | ✅ PASS | ... |
| Archive OpenSpec change | ✅ PASS | ... |
| Sync specs | ✅ PASS | ... |
| Commit / PR | ✅ PASS | Commit `<hash>` |

**Veredicto final: PASS — Ticket cerrado sin errores ni pasos omitidos.**
```

**Cambiar el estado del ticket a "Cerrado"** (o el estado equivalente disponible en el workspace).

### Paso 7 — Mostrar resumen al usuario

Mostrá en el chat:

```
✅ Reporte de cierre generado para <TICKET-ID>

Veredicto: <veredicto>
Etapas: N/N completadas

Guardado en: openspec/changes/<TICKET-ID>/reports/YYYY-MM-DD-closure-report.md
ClickUp: comentario agregado al ticket (si aplica)
```

Si el veredicto es ❌ NO CERRADO, indicá claramente qué etapas faltan antes de poder cerrar.

## Notas

- Este skill **no reemplaza** ningún paso del flujo — es un resumen de lo que ya se hizo.
- Si un paso obligatorio no tiene evidencia, el veredicto es ❌ NO CERRADO aunque el usuario diga que lo ejecutó — la evidencia en el repo es la fuente de verdad.
- Este reporte queda como documento histórico del ticket y puede auditarse en el futuro.
- Para proyectos con CI/CD, podés agregar como etapa adicional "Deploy" con el link al pipeline si está disponible.
