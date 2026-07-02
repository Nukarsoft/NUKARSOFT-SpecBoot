---
name: using-git-worktrees
description: Usar al comenzar trabajo de una feature que necesita aislamiento del workspace actual o antes de ejecutar planes de implementación - asegura que exista un workspace aislado mediante herramientas nativas o, como alternativa, git worktree
author: LIDR.co
version: 1.0.0
---

# Usando Git Worktrees

## Descripción general

Asegurate de que el trabajo ocurra en un workspace aislado. Preferí las herramientas nativas de worktree de tu plataforma. Recurrí a git worktrees manuales solo cuando no haya ninguna herramienta nativa disponible.

**Principio central:** Detectá primero el aislamiento existente. Luego usá herramientas nativas. Luego recurrí a git como alternativa. Nunca vayas en contra del harness.

**Anunciá al comenzar:** "Estoy usando el skill using-git-worktrees para configurar un workspace aislado."

## Paso 0: Detectar aislamiento existente

**Antes de crear nada, verificá si ya estás en un workspace aislado.**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**Resguardo para submódulos:** `GIT_DIR != GIT_COMMON` también es verdadero dentro de submódulos de git. Antes de concluir "ya estoy en un worktree", verificá que no estés en un submódulo:

```bash
# If this returns a path, you're in a submodule, not a worktree — treat as normal repo
git rev-parse --show-superproject-working-tree 2>/dev/null
```

**Si `GIT_DIR != GIT_COMMON` (y no es un submódulo):** Ya estás en un worktree vinculado. Saltá al Paso 3 (Configuración del proyecto). NO crees otro worktree.

Reportá con el estado de la rama:
- En una rama: "Ya estoy en un workspace aislado en `<path>` en la rama `<name>`."
- HEAD separado (detached): "Ya estoy en un workspace aislado en `<path>` (HEAD separado, gestionado externamente). Se necesitará crear una rama al finalizar."

**Si `GIT_DIR == GIT_COMMON` (o estás en un submódulo):** Estás en un checkout de repositorio normal.

¿El usuario ya indicó su preferencia sobre worktrees en tus instrucciones? Si no, pedí consentimiento antes de crear un worktree:

> "¿Querés que configure un worktree aislado? Protege tu rama actual de los cambios."

Respetá cualquier preferencia ya declarada sin preguntar. Si el usuario rechaza el consentimiento, trabajá en el lugar y saltá al Paso 3.

## Paso 1: Crear un workspace aislado

**Tenés dos mecanismos. Probalos en este orden.**

### 1a. Herramientas nativas de worktree (preferido)

El usuario pidió un workspace aislado (consentimiento del Paso 0). ¿Ya tenés una forma de crear un worktree? Podría ser una herramienta con un nombre como `EnterWorktree`, `WorktreeCreate`, un comando `/worktree`, o un flag `--worktree`. Si la tenés, usala y saltá al Paso 3.

Las herramientas nativas gestionan automáticamente la ubicación del directorio, la creación de la rama y la limpieza. Usar `git worktree add` cuando tenés una herramienta nativa crea un estado fantasma que tu harness no puede ver ni gestionar.

Si el flujo nativo no propaga la configuración de Claude/Cursor y el usuario espera paridad con el checkout principal, copiá `.claude/settings.json` y `.claude/settings.local.json` desde el workspace principal usando el mismo bucle que el Paso 1b **después** de que la herramienta nativa termine, solo cuando los archivos existan en disco.

Solo avanzá al Paso 1b si no tenés ninguna herramienta nativa de worktree disponible.

### 1b. Alternativa: Git Worktree

**Usá esto solo si el Paso 1a no aplica** — no tenés ninguna herramienta nativa de worktree disponible. Creá un worktree manualmente usando git.

#### Selección de directorio

Usá una única ubicación: `.worktrees/` dentro de la raíz del repositorio.

1. Definí la raíz del repositorio y el directorio base de worktrees:
   ```bash
   SOURCE_ROOT=$(git rev-parse --show-toplevel)
   LOCATION="$SOURCE_ROOT/.worktrees"
   ```

2. Asegurate de que el directorio exista:
   ```bash
   mkdir -p "$LOCATION"
   ```

3. Creá siempre el worktree en:
   ```bash
   path="$LOCATION/$BRANCH_NAME"
   ```

No deben usarse alternativas globales o hermanas (sibling) a menos que el usuario anule explícitamente esta regla para una tarea puntual.

#### Verificación de seguridad

**DEBE verificarse que `.worktrees/` esté ignorado antes de crear el worktree:**

```bash
git check-ignore -q .worktrees 2>/dev/null
```

**Si NO está ignorado:** Agregá `.worktrees/` a `.gitignore`, commiteá el cambio y luego continuá.

**Por qué es crítico:** Evita commitear accidentalmente el contenido del worktree al repositorio.

#### Crear el worktree

**Capturá la raíz del checkout principal antes de `git worktree add`.** Después de hacer `cd` al nuevo worktree, `git rev-parse --show-toplevel` apunta al directorio del worktree, no al checkout donde normalmente vive `.claude/settings*.json`.

```bash
project=$(basename "$(git rev-parse --show-toplevel)")
SOURCE_ROOT=$(git rev-parse --show-toplevel)

# Path is always inside repo-local .worktrees/
path="$LOCATION/$BRANCH_NAME"

git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

**Alternativa por sandbox:** Si `git worktree add` falla con un error de permisos (denegación del sandbox), avisale al usuario que el sandbox bloqueó la creación del worktree y que vas a trabajar en el directorio actual en su lugar. Luego ejecutá la configuración y los tests base en el lugar.

#### Copiar la configuración de Claude (solo Paso 1b)

Después de crear el worktree con git (Paso 1b), copiá la configuración local de Claude desde el **checkout principal** para que el comportamiento de Cursor/Claude CLI coincida con el del workspace principal. Estos archivos suelen no estar versionados (untracked).

**No** copies si el usuario lo rechaza o si una herramienta nativa (Paso 1a) ya propaga la configuración — respetá el harness.

Ejecutá esto **después** de `cd "$path"` (usando todavía el `SOURCE_ROOT` capturado antes):

```bash
copied_claude_settings=false
for claude_settings in ".claude/settings.json" ".claude/settings.local.json"; do
    if [ -f "$SOURCE_ROOT/$claude_settings" ]; then
        mkdir -p ".claude"
        cp -p "$SOURCE_ROOT/$claude_settings" "./$claude_settings"
        echo "Copied $claude_settings to worktree"
        copied_claude_settings=true
    fi
done

if [ "$copied_claude_settings" = false ]; then
    echo "No local Claude settings found (.claude/settings.json or .claude/settings.local.json)"
fi
```

**Symlinks:** Si el árbol de origen usa symlinks para `.claude` (ej: `.claude/skills` → `../../ai-specs/skills`), copiar solo estos archivos JSON no recrea los destinos de los symlinks. Recreá el mismo esquema de symlinks en el worktree o basate en rutas relativas al proyecto dentro de `settings.json`.

## Paso 3: Configuración del proyecto

Detectá automáticamente y ejecutá la configuración correspondiente:

```bash
# Node.js
if [ -f package.json ]; then npm install; fi

# Rust
if [ -f Cargo.toml ]; then cargo build; fi

# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi

# Go
if [ -f go.mod ]; then go mod download; fi
```

## Paso 4: Verificar una línea base limpia

Ejecutá los tests para asegurarte de que el workspace arranque limpio:

```bash
# Use project-appropriate command
npm test / cargo test / pytest / go test ./...
```

**Si los tests fallan:** Reportá las fallas, preguntá si continuar o investigar.

**Si los tests pasan:** Reportá que está listo.

### Reporte

```
Worktree ready at <full-path>
Claude settings copied (or none found / skipped per harness)
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```

## Paso 5: Limpieza — Eliminar el worktree cuando termines

**Ejecutá la limpieza una vez que el trabajo esté completo.** "Completo" significa: la rama fue mergeada, el PR está cerrado, el experimento fue descartado, o el usuario confirmó explícitamente que ya no necesita el workspace aislado. Nunca elimines un worktree que aún contenga cambios sin commitear, sin pushear o sin mergear que el usuario pueda necesitar.

### 5.0 Detectar el modo de limpieza

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
```

- **Si `GIT_DIR == GIT_COMMON`:** Nunca estuviste en un worktree vinculado (el Paso 0 te llevó directo al Paso 3). No hay nada que limpiar — omití el Paso 5 por completo.
- **Si `GIT_DIR != GIT_COMMON`:** Estás dentro de un worktree vinculado. Continuá con la limpieza.

### 5.1 Verificar que el trabajo esté guardado

Antes de eliminar nada, confirmá que no haya trabajo que perder:

```bash
git status --porcelain                 # Must be empty (no uncommitted changes)
git log @{u}.. 2>/dev/null             # Must be empty (no unpushed commits)
```

**Si alguno de los comandos devuelve resultado:** Deteneté. Reportá el trabajo sin guardar al usuario y preguntá cómo proceder (commit/push, stash, o descarte forzado). Nunca elimines un worktree con trabajo sin guardar sin confirmación explícita del usuario.

Capturá la ruta del worktree y el nombre de la rama antes de salir del directorio:

```bash
WORKTREE_PATH=$(git rev-parse --show-toplevel)
BRANCH_NAME=$(git branch --show-current)
```

### 5.2 Herramientas nativas de worktree (preferido)

Si usaste una herramienta nativa de worktree en el Paso 1a (`EnterWorktree`, `WorktreeCreate`, `/worktree`, etc.), usá el comando nativo correspondiente para eliminar el worktree (por ejemplo, `LeaveWorktree`, `WorktreeRemove`, `/worktree remove`). Las herramientas nativas limpian directorios, ramas y el estado del harness de forma consistente.

Solo avanzá al 5.3 si no hay ninguna herramienta nativa de limpieza disponible.

### 5.3 Alternativa: limpieza con Git Worktree

**Usá esto solo si el Paso 5.2 no aplica** — creaste el worktree manualmente en el Paso 1b.

```bash
# 1. Move out of the worktree before deleting it
cd "$GIT_COMMON/.."   # or any path inside the main checkout

# 2. Remove the worktree
git worktree remove "$WORKTREE_PATH"

# 3. If files are still present (e.g. ignored artifacts blocking removal),
#    confirm with the user, then force-remove
git worktree remove --force "$WORKTREE_PATH"

# 4. Delete the local branch only if it was created for this worktree
#    AND has been merged or is no longer needed
git branch -d "$BRANCH_NAME"            # safe delete (refuses if unmerged)
git branch -D "$BRANCH_NAME"            # force delete (only with user confirmation)

# 5. Prune stale worktree metadata if the directory was deleted manually
git worktree prune
```

**Alternativa por sandbox:** Si la eliminación falla por permisos, reportá la falla y la ruta que necesita limpieza manual. No reintentes de forma destructiva.

### 5.4 Verificar la limpieza

```bash
git worktree list                      # WORKTREE_PATH must no longer appear
ls -d "$WORKTREE_PATH" 2>/dev/null     # Must return nothing
```

### Reporte

```
Worktree removed: <full-path>
Branch <name> deleted (or kept, if still needed)
Main checkout left untouched
```

## Referencia rápida

| Situación | Acción |
|-----------|--------|
| Ya está en un worktree vinculado | Omitir creación (Paso 0) |
| Está en un submódulo | Tratar como repo normal (resguardo del Paso 0) |
| Herramienta nativa de worktree disponible | Usarla (Paso 1a) |
| Sin herramienta nativa | Alternativa git worktree (Paso 1b) |
| Se necesita una ubicación de worktree | Usar `<repo>/.worktrees/<branch>` |
| Directorio no ignorado | Agregar a .gitignore + commit |
| Error de permisos al crear | Alternativa por sandbox, trabajar en el lugar |
| Los tests fallan durante la línea base | Reportar fallas + preguntar |
| Sin package.json/Cargo.toml | Omitir instalación de dependencias |
| Trabajo completo, en worktree vinculado | Ejecutar limpieza del Paso 5 |
| Nunca se creó un worktree | Omitir Paso 5 |
| Cambios sin commitear/pushear al limpiar | Detenerse y preguntar al usuario |
| Herramienta nativa de limpieza disponible | Usarla (Paso 5.2) |
| Sin herramienta nativa de limpieza | `git worktree remove` (Paso 5.3) |
| Directorio de worktree eliminado manualmente | `git worktree prune` |
| Alternativa git: replicar comportamiento de Claude en el worktree | Copiar `.claude/settings*.json` desde `SOURCE_ROOT` (Paso 1b) |
| El repo usa symlinks `.claude` | Copiar solo el JSON no alcanza — recrear symlinks o rutas |

## Errores comunes

### Ir en contra del harness

- **Problema:** Usar `git worktree add` cuando la plataforma ya provee aislamiento
- **Solución:** El Paso 0 detecta el aislamiento existente. El Paso 1a prioriza las herramientas nativas.

### Omitir la detección

- **Problema:** Crear un worktree anidado dentro de uno existente
- **Solución:** Ejecutar siempre el Paso 0 antes de crear nada

### Omitir la verificación de ignorado

- **Problema:** El contenido del worktree queda versionado, contamina el git status
- **Solución:** Usar siempre `git check-ignore` antes de crear un worktree local al proyecto

### Asumir la ubicación del directorio

- **Problema:** Genera inconsistencia, viola las convenciones del proyecto
- **Solución:** Usar siempre `<repo>/.worktrees/<branch>` a menos que el usuario lo anule explícitamente para una tarea puntual

### Continuar con tests fallando

- **Problema:** No se puede distinguir entre bugs nuevos y problemas preexistentes
- **Solución:** Reportar las fallas, obtener permiso explícito para continuar

### Eliminar un worktree con trabajo sin guardar

- **Problema:** `git worktree remove --force` descarta silenciosamente los cambios sin commitear/pushear
- **Solución:** Ejecutar siempre `git status --porcelain` y `git log @{u}..` antes de eliminar; detenerse y preguntar si alguno no está vacío

### Eliminar la rama antes de que esté mergeada

- **Problema:** `git branch -D` destruye commits que nunca fueron mergeados ni pusheados
- **Solución:** Preferir `git branch -d` (eliminación segura); solo forzar la eliminación tras confirmación explícita del usuario

### Mezclar limpieza nativa y manual

- **Problema:** Ejecutar `git worktree remove` en un worktree creado por una herramienta nativa deja estado fantasma en el harness
- **Solución:** Lo que creó el worktree debe eliminarlo (herramienta nativa ↔ herramienta nativa, git ↔ git)

### Copiar la configuración de Claude desde el directorio equivocado

- **Problema:** Usar `git rev-parse --show-toplevel` después de hacer `cd` al nuevo worktree resuelve a la ruta del worktree, por lo que las copias no encuentran configuración o copian desde el lugar equivocado
- **Solución:** Definir `SOURCE_ROOT=$(git rev-parse --show-toplevel)` en el checkout principal **antes** de `git worktree add`, y luego usar `$SOURCE_ROOT` en el bucle de copia

## Señales de alerta

**Nunca:**
- Crear un worktree cuando el Paso 0 detecta aislamiento existente
- Usar `git worktree add` cuando tenés una herramienta nativa de worktree (ej: `EnterWorktree`). Este es el error #1 — si la tenés, usala.
- Saltearse el Paso 1a yendo directo a los comandos git del Paso 1b
- Crear un worktree sin verificar que esté ignorado (local al proyecto)
- Omitir la verificación de la línea base de tests
- Continuar con tests fallando sin preguntar
- Eliminar un worktree que aún tenga trabajo sin commitear, sin pushear o sin mergear sin confirmación explícita del usuario
- Forzar la eliminación de una rama (`git branch -D`) sin confirmar que esté mergeada o que ya no se necesite
- Ejecutar `git worktree remove` en un worktree creado por una herramienta nativa

**Siempre:**
- Ejecutar primero la detección del Paso 0
- Preferir herramientas nativas sobre la alternativa git
- Usar `<repo>/.worktrees/<branch>` como ubicación estándar
- Verificar que el directorio esté ignorado para lo local al proyecto
- Detectar automáticamente y ejecutar la configuración del proyecto
- Verificar una línea base de tests limpia
- Ejecutar la limpieza del Paso 5 una vez completado el trabajo, usando el mismo mecanismo que creó el worktree
- Verificar que no haya nada que perder antes de eliminar un worktree (`git status --porcelain`, `git log @{u}..`)
- Confirmar con `git worktree list` y una verificación de directorio que la limpieza realmente se completó
- Después del Paso 1b (alternativa git), copiar `.claude/settings.json` y `.claude/settings.local.json` desde `SOURCE_ROOT` capturado antes de `git worktree add`
