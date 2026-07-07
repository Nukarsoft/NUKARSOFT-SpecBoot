---
name: save-qa-report
description: Generar y guardar el reporte de QA / testing funcional de un ticket. Documenta los casos de prueba ejecutados, resultado por criterio de aceptación, links a grabaciones y capturas. Guarda en el repo y en ClickUp.
author: Nukarsoft
version: 1.0.0
---
# Skill save-qa-report

Usalo **después de completar el testing funcional/manual** de un ticket para dejar evidencia formal de lo que se probó, con qué resultado y dónde están las grabaciones.

Se invoca de dos maneras:
- **Bajo demanda**: `/save-qa-report <TICKET-ID>` al terminar el testing manual.
- **Como parte del flujo**: después de `/adversarial-review` y antes de `/archive`.

## Instrucciones

### Paso 1 — Obtener el TICKET-ID y contexto del ticket

Resolvé el TICKET-ID desde `$ARGUMENTS`. Si no se proporcionó, pedíselo al usuario.

Si existe `.claude/clickup-workspace.local.md`, leé el workspace configurado y obtené el ticket de ClickUp para extraer:
- Título del ticket
- Criterios de aceptación (de la US enriquecida por `/enrich-us`)
- Archivos cambiados (`git diff main...HEAD --name-only`)

### Paso 2 — Recopilar evidencia de testing

Preguntale al usuario (o inferí del contexto si ya fue mencionado en la sesión):

1. **¿Qué casos de prueba se ejecutaron?**
   - Podés inferirlos de los criterios de aceptación del ticket y del diff
   - Si el usuario los especificó en el chat, usalos directamente

2. **¿Hay grabaciones de pantalla (Loom)?**
   - Si el usuario pegó links de Loom en el chat, capturarlos
   - Si no hay, indicar "Sin grabación — testing documentado por escrito"

3. **¿Hay capturas de pantalla o logs adjuntos?**
   - Listar cualquier archivo de evidencia mencionado

4. **¿Ambiente de testing?**
   - Local / Staging / QA — inferí del contexto o preguntá

### Paso 3 — Construir la tabla de casos de prueba

Para cada criterio de aceptación del ticket, generá una fila:

| # | Criterio de aceptación | Caso de prueba | Ambiente | Resultado | Evidencia |
|---|------------------------|----------------|----------|-----------|-----------|
| 1 | El usuario puede... | Ingresar como usuario X y ejecutar acción Y | Local | ✅ PASS | [Loom](url) |
| 2 | El sistema valida... | Intentar acción con datos inválidos | Local | ✅ PASS | — |
| 3 | Se registra log de... | Verificar logs tras ejecutar acción | Local | ⚠️ PARCIAL | Captura adjunta |

Resultados posibles: `✅ PASS` / `❌ FAIL` / `⚠️ PARCIAL` / `⏭️ NO EJECUTADO`

### Paso 4 — Determinar el veredicto general

| Veredicto | Criterio |
|-----------|----------|
| ✅ **APROBADO** | Todos los criterios principales en PASS |
| ⚠️ **APROBADO CON OBSERVACIONES** | Algún PARCIAL sin impacto en funcionalidad core |
| ❌ **REQUIERE CORRECCIONES** | Al menos un FAIL en criterio principal |

### Paso 5 — Guardar el reporte en el repo

Guardá el archivo en:
```
openspec/changes/<TICKET-ID>/reports/YYYY-MM-DD-qa-report.md
```

Formato del archivo:

```markdown
# QA Report — <TICKET-ID>

**Fecha**: YYYY-MM-DD HH:MM
**Ticket**: <TICKET-ID> — <Título del ticket>
**Testeado por**: <nombre del usuario o "Nukarsoft Dev">
**Ambiente**: Local / Staging / QA

## Veredicto

✅ APROBADO | ⚠️ APROBADO CON OBSERVACIONES | ❌ REQUIERE CORRECCIONES

## Casos de prueba

| # | Criterio de aceptación | Caso de prueba | Ambiente | Resultado | Evidencia |
|---|------------------------|----------------|----------|-----------|-----------|
| 1 | ... | ... | Local | ✅ PASS | [Loom](url) |

## Grabaciones y evidencia

- **Loom**: <url o "No disponible">
- **Capturas**: <lista o "No disponible">
- **Logs**: <referencia o "No disponible">

## Observaciones

<cualquier nota adicional sobre el testing, deuda conocida, limitaciones del ambiente>
```

### Paso 6 — Persistir en ClickUp

**6a. Comentar en el ticket:**
Si existe `.claude/clickup-workspace.local.md`:
- Agregá un comentario al ticket con el veredicto, cantidad de casos ejecutados y link/ruta del reporte.

**6b. Crear documento en ClickUp:**
Usá `clickup_create_document` para crear un documento en el espacio del proyecto:
- Nombre: `QA Report — <TICKET-ID> — YYYY-MM-DD`
- Visibilidad: `PUBLIC`
- Luego actualizá la página con el contenido del reporte usando `clickup_update_document_page`

### Paso 7 — Mostrar resumen al usuario

Mostrá en el chat:
- Veredicto general
- Cantidad de casos: X PASS / Y FAIL / Z PARCIAL
- Ruta del archivo en el repo: `openspec/changes/<TICKET-ID>/reports/YYYY-MM-DD-qa-report.md`
- Link al documento en ClickUp (si aplica)
- Si el veredicto es REQUIERE CORRECCIONES: **no continuar con `/archive` hasta resolver los FAILs**

## Notas

- Si el usuario no tiene grabaciones de Loom, el reporte es igualmente válido con la tabla de casos documentada por escrito.
- Para proyectos con testing automatizado de e2e (Cypress, Playwright, etc.), los resultados del runner pueden pegarse directamente como evidencia en lugar de la tabla manual.
- Los casos NO EJECUTADO deben justificarse (ambiente no disponible, fuera de alcance del ticket, etc.).
- Este skill complementa `/adversarial-review` (que hace red-team desde el punto de vista del atacante) — este skill documenta el testing funcional desde el punto de vista del usuario.
