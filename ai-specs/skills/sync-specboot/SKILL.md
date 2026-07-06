---
name: sync-specboot
description: Actualizar la infraestructura de specboot en un proyecto existente (ai-specs/, .claude/commands/, agentes) sin pisar las customizaciones del proyecto (docs/, openspec/, código).
author: Nukarsoft
version: 1.0.0
---
# Skill sync-specboot

Usalo cuando el repo de NUKARSOFT-SpecBoot recibió mejoras (nuevos skills, comandos corregidos, cambios en agentes) y querés traer esos cambios a un proyecto que ya tiene specboot instalado, sin perder lo que ya personalizaste (tu `docs/`, tus changes de OpenSpec, tu código).

## Qué actualiza y qué protege

| Archivos | Acción |
|----------|--------|
| `ai-specs/skills/` | ✅ **Actualiza** — skills nuevos y correcciones |
| `ai-specs/agents/` | ✅ **Actualiza** — definiciones de agentes |
| `.claude/commands/` | ✅ **Actualiza** — slash commands |
| `.claude/agents/` | ✅ **Actualiza** — agentes de Claude Code |
| `.cursor/` | ✅ **Actualiza** — integración con Cursor |
| `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `codex.md` | ✅ **Actualiza** — archivos raíz de configuración de IA |
| `docs/` | 🔒 **Protege** — ya fue personalizado por `/setup-docs` |
| `openspec/` | 🔒 **Protege** — changes y specs de tu proyecto |
| `.claude/settings.local.json` | 🔒 **Protege** — configuración local |
| `.claude/clickup-workspace.local.md` | 🔒 **Protege** — workspace local de ClickUp |
| Código del proyecto | 🔒 **Protege** — nunca tocado por este skill |

## Instrucciones

### Paso 1 — Mostrar qué cambió en specboot

Antes de actualizar, mostrá al usuario qué archivos de infraestructura de specboot cambiaron desde que lo instaló. Para eso:

1. Verificá si existe `C:\temp\nukarsoft-specboot` (temp de una instalación anterior). Si no, indicá al usuario que ejecute primero:
   ```
   git clone https://github.com/Nukarsoft/NUKARSOFT-SpecBoot C:\temp\nukarsoft-specboot
   ```
   O si ya tiene el repo clonado en otro lado, pedile la ruta.

2. Listá los archivos de infraestructura que difieren entre el temp (fuente) y el proyecto (destino). Podés usar:
   ```
   robocopy C:\temp\nukarsoft-specboot\ai-specs C:\ruta\proyecto\ai-specs /E /L /NJH /NJS /NDL
   robocopy C:\temp\nukarsoft-specboot\.claude\commands C:\ruta\proyecto\.claude\commands /E /L /NJH /NJS /NDL
   ```
   El flag `/L` hace un "dry run" — lista qué copiaría sin copiar nada.

3. Mostrá el listado al usuario: archivos nuevos, archivos modificados.

### Paso 2 — Confirmar con el usuario

Preguntale:
- ¿Querés aplicar estas actualizaciones?
- ¿Hay algún archivo específico que NO querés tocar aunque esté en la lista?

### Paso 3 — Aplicar la actualización (Windows CMD)

Una vez confirmado, ejecutá en orden:

```
rem 1. Actualizar ai-specs/, CLAUDE.md, AGENTS.md, GEMINI.md, codex.md, setup-claude-commands.bat
rem    EXCLUYE: docs/, openspec/, .git
robocopy C:\temp\nukarsoft-specboot C:\ruta\a\tu-proyecto /E /XD .git docs openspec

rem 2. Actualizar .claude/commands/ y .claude/agents/
rem    EXCLUYE: settings.local.json y cualquier *.local.md
robocopy C:\temp\nukarsoft-specboot\.claude C:\ruta\a\tu-proyecto\.claude /E /XF settings.local.json *.local.md

rem 3. Actualizar .cursor/
robocopy C:\temp\nukarsoft-specboot\.cursor C:\ruta\a\tu-proyecto\.cursor /E
```

**Mac/Linux:**
```bash
# Excluir docs/, openspec/, .git
rsync -av --exclude='.git' --exclude='docs/' --exclude='openspec/' \
  /tmp/nukarsoft-specboot/ /ruta/tu-proyecto/

# Actualizar .claude/ excluyendo archivos locales
rsync -av --exclude='settings.local.json' --exclude='*.local.md' \
  /tmp/nukarsoft-specboot/.claude/ /ruta/tu-proyecto/.claude/

# Actualizar .cursor/
rsync -av /tmp/nukarsoft-specboot/.cursor/ /ruta/tu-proyecto/.cursor/
```

### Paso 4 — Borrar la carpeta temporal (opcional)

```
rmdir /S /Q C:\temp\nukarsoft-specboot
```

### Paso 5 — Confirmar y mostrar resumen

Mostrá al usuario:
- Lista de archivos actualizados
- Recordatorio de que `docs/` y `openspec/` no fueron tocados
- Sugerencia: `git diff` para revisar los cambios antes de commitear

## Notas

- Este skill no toca ni reescribe `docs/` bajo ninguna circunstancia. Si querés actualizar `docs/` con cambios en el stack del proyecto, usá `/update-docs`.
- Si el usuario modificó manualmente algún archivo de `ai-specs/` o `.claude/commands/` en su proyecto, esos cambios serán pisados. Recomendá hacer `git diff` antes y después para revisarlos.
- Si solo querés actualizar un skill específico (por ejemplo, solo `ai-specs/skills/commit/SKILL.md`), podés copiar ese archivo puntualmente en vez de correr todo el sync.
