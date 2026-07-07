---
name: security-review
description: Revisión de seguridad y buenas prácticas del código implementado en un ticket. Genera un reporte Word adjunto al ticket de ClickUp. Se ejecuta automáticamente después de /apply y también está disponible bajo demanda.
author: Nukarsoft
version: 1.0.0
---
# Skill security-review

Revisión rápida y focalizada de seguridad y buenas prácticas sobre los cambios implementados en un ticket. A diferencia de `/code-auditing` (que audita todo el proyecto) o `/adversarial-review` (que rompe la spec), este skill corre sobre el **diff puntual del ticket** y genera un documento persistido.

Se invoca de dos maneras:
- **Automáticamente**: al finalizar `/apply <TICKET-ID>` como último paso del proceso de implementación.
- **Bajo demanda**: ejecutando `/security-review <TICKET-ID>` directamente.

## Instrucciones

### Paso 1 — Identificar el alcance

Resolvé el TICKET-ID desde `$ARGUMENTS`. Si no se proporcionó, inferilo del branch activo o del último change de OpenSpec aplicado.

Obtené el diff de los cambios del ticket:
```bash
git diff main...HEAD -- .
```
O si el branch ya fue commiteado, usá el diff del PR. Listá los archivos modificados/agregados como alcance del análisis.

### Paso 2 — Análisis de seguridad (OWASP Top 10 + extras)

Revisá el diff contra cada categoría. Para cada hallazgo anotá: archivo, línea, descripción, severidad y corrección sugerida.

**A1 — Inyección (SQL, NoSQL, comandos)**
- Inputs del usuario concatenados directamente en queries
- Ausencia de parámetros preparados / ORM correctamente usado
- Llamadas a `exec`, `eval`, `shell` con datos externos

**A2 — Autenticación y manejo de sesiones**
- Tokens o passwords hardcodeados o logueados
- JWT sin verificación de firma o con algoritmo `none`
- Sesiones sin expiración o sin invalidación al logout

**A3 — Exposición de datos sensibles**
- PII, contraseñas, API keys, secrets en código o logs
- Datos sensibles en responses que no deberían exponerse
- Ausencia de cifrado en datos en tránsito o en reposo

**A4 — Entidades externas XML (XXE)**
- Parsers XML que aceptan entidades externas

**A5 — Control de acceso roto**
- Endpoints sin validación de rol/permiso
- Acceso a recursos de otros usuarios sin verificación de ownership
- Funciones administrativas sin guards

**A6 — Configuración incorrecta de seguridad**
- CORS abierto (`*`) en producción
- Headers de seguridad faltantes (CSP, HSTS, X-Frame-Options)
- Variables de entorno con valores por defecto inseguros

**A7 — XSS (Cross-Site Scripting)**
- Outputs sin escapar en HTML/templates
- `innerHTML`, `dangerouslySetInnerHTML` con datos del usuario
- Ausencia de sanitización en inputs de texto libre

**A8 — Deserialización insegura**
- Deserialización de datos no confiables sin validación

**A9 — Componentes con vulnerabilidades conocidas**
- Dependencias nuevas agregadas en el diff: verificar si tienen CVEs conocidos

**A10 — Logging y monitoreo insuficiente**
- Ausencia de logs en operaciones críticas (login, cambios de permisos, pagos)
- Errores silenciados (`catch` vacíos o con solo `console.log`)

**Extras Nukarsoft**
- Validación de inputs en todos los endpoints nuevos (tipos, rangos, formatos)
- Manejo de errores: todos los `try/catch` retornan respuestas controladas
- Principios SOLID básicos: funciones con responsabilidad única, sin god objects
- No hay lógica de negocio en controllers (debe estar en services/use cases)
- Tests de seguridad: los nuevos endpoints tienen al menos un test de autorización

### Paso 3 — Clasificar hallazgos

| Severidad | Criterio |
|-----------|----------|
| 🔴 **Crítico** | Vulnerabilidad explotable directamente (SQLi, secretos expuestos, bypass de auth) |
| 🟠 **Alto** | Riesgo significativo que debe corregirse antes de mergear |
| 🟡 **Medio** | Mejora importante, puede quedar como deuda técnica documentada |
| 🟢 **Bajo** | Sugerencia de buenas prácticas, opcional |

### Paso 4 — Generar el reporte Word

Generá un archivo `.docx` con el siguiente contenido usando el skill `docx`:

**Nombre del archivo:** `YYYY-MM-DD-security-review-<TICKET-ID>.docx`  
**Ruta en el repo:** `openspec/changes/<TICKET-ID>/reports/YYYY-MM-DD-security-review-<TICKET-ID>.docx`

**Estructura del documento:**

```
# Security Review — <TICKET-ID>
Fecha: YYYY-MM-DD | Revisado por: Claude (Nukarsoft SpecBoot)

## Alcance
- Branch: <branch>
- Archivos analizados: <lista>
- Commit/PR: <referencia>

## Resumen ejecutivo
<veredicto general: APROBADO / APROBADO CON OBSERVACIONES / REQUIERE CORRECCIONES>
<cantidad de hallazgos por severidad>

## Hallazgos

| # | Severidad | Categoría | Archivo:Línea | Descripción | Corrección sugerida |
|---|-----------|-----------|---------------|-------------|---------------------|
| 1 | 🔴 Crítico | A1-Inyección | auth/login.ts:42 | ... | ... |

## Conclusión y próximos pasos
<qué debe corregirse antes de mergear y qué puede quedar como deuda>
```

### Paso 5 — Persistir el reporte

**5a. Guardar en el repo:**
```
openspec/changes/<TICKET-ID>/reports/YYYY-MM-DD-security-review-<TICKET-ID>.docx
```

**5b. Adjuntar al ticket de ClickUp:**
Si existe `.claude/clickup-workspace.local.md`, usá el MCP de ClickUp:
- Convertí el `.docx` a base64
- Adjuntalo al ticket con `clickup_attach_task_file` usando `file_data` (base64) y `file_name`

**5c. Crear documento en ClickUp:**
Adicionalmente, creá un documento de ClickUp en el espacio del proyecto con `clickup_create_document`:
- Nombre: `Security Review — <TICKET-ID> — YYYY-MM-DD`
- Visibilidad: `PUBLIC`
- Luego actualizá la página con el contenido del reporte usando `clickup_update_document_page`

### Paso 6 — Resumen para el usuario

Mostrá en el chat:
- Veredicto: `APROBADO` / `APROBADO CON OBSERVACIONES` / `REQUIERE CORRECCIONES`
- Cantidad de hallazgos críticos/altos (si los hay, listarlos brevemente)
- Ruta del archivo en el repo
- Link al documento en ClickUp (si aplica)
- Si hay hallazgos críticos o altos: **no continuar con `/verify` hasta resolverlos**

## Notas

- Este skill analiza solo el diff del ticket, no todo el proyecto. Para auditoría completa usá `/code-auditing`.
- Si no hay cambios de código (solo docs o config), indicarlo y omitir el análisis de seguridad.
- Los hallazgos de severidad Bajo y Medio no bloquean el flujo — quedan registrados como deuda técnica en el reporte.
- Los hallazgos Críticos y Altos **bloquean el merge** hasta resolverse.
