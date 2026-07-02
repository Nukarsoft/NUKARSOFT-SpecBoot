---
name: openspec-sync-specs
description: Sincronizar los delta specs de un change con los specs principales. Usar cuando el usuario quiera actualizar los specs principales con los cambios de un delta spec, sin archivar el change.
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: openspec
  version: "1.0"
  generatedBy: "1.3.1"
---

Sincroniza los delta specs de un change con los specs principales.

Esta es una operación **impulsada por el agente**: vas a leer los delta specs y editar directamente los specs principales para aplicar los cambios. Esto permite una fusión inteligente (por ejemplo, agregar un escenario sin copiar todo el requirement).

**Entrada**: Opcionalmente especificá un nombre de change. Si se omite, verificá si se puede inferir del contexto de la conversación. Si es vago o ambiguo, DEBÉS preguntar por los changes disponibles.

**Pasos**

1. **Si no se proporciona un nombre de change, preguntar para que se seleccione uno**

   Ejecutá `openspec list --json` para obtener los changes disponibles. Usá la **herramienta AskUserQuestion** para que el usuario seleccione.

   Mostrá los changes que tienen delta specs (bajo el directorio `specs/`).

   **IMPORTANTE**: NO adivines ni selecciones automáticamente un change. Dejá que el usuario elija siempre.

2. **Encontrar los delta specs**

   Buscá los archivos de delta spec en `openspec/changes/<name>/specs/*/spec.md`.

   Cada archivo de delta spec contiene secciones como:
   - `## ADDED Requirements` - Nuevos requirements para agregar
   - `## MODIFIED Requirements` - Cambios a requirements existentes
   - `## REMOVED Requirements` - Requirements para eliminar
   - `## RENAMED Requirements` - Requirements para renombrar (formato FROM:/TO:)

   Si no se encuentran delta specs, informá al usuario y detenete.

3. **Para cada delta spec, aplicar los cambios a los specs principales**

   Para cada capability con un delta spec en `openspec/changes/<name>/specs/<capability>/spec.md`:

   a. **Leé el delta spec** para entender los cambios previstos

   b. **Leé el spec principal** en `openspec/specs/<capability>/spec.md` (puede que todavía no exista)

   c. **Aplicá los cambios de forma inteligente**:

      **ADDED Requirements:**
      - Si el requirement no existe en el spec principal → agregalo
      - Si el requirement ya existe → actualizalo para que coincida (tratalo como un MODIFIED implícito)

      **MODIFIED Requirements:**
      - Buscá el requirement en el spec principal
      - Aplicá los cambios - esto puede ser:
        - Agregar nuevos escenarios (no hace falta copiar los existentes)
        - Modificar escenarios existentes
        - Cambiar la descripción del requirement
      - Preservá los escenarios/contenido no mencionados en el delta

      **REMOVED Requirements:**
      - Eliminá todo el bloque del requirement del spec principal

      **RENAMED Requirements:**
      - Buscá el requirement FROM, renombralo a TO

   d. **Creá un nuevo spec principal** si la capability todavía no existe:
      - Creá `openspec/specs/<capability>/spec.md`
      - Agregá la sección Purpose (puede ser breve, marcala como TBD)
      - Agregá la sección Requirements con los requirements de ADDED

4. **Mostrar un resumen**

   Después de aplicar todos los cambios, resumí:
   - Qué capabilities fueron actualizadas
   - Qué cambios se hicieron (requirements agregados/modificados/eliminados/renombrados)

**Referencia de formato de Delta Spec**

```markdown
## ADDED Requirements

### Requirement: New Feature
The system SHALL do something new.

#### Scenario: Basic case
- **WHEN** user does X
- **THEN** system does Y

## MODIFIED Requirements

### Requirement: Existing Feature
#### Scenario: New scenario to add
- **WHEN** user does A
- **THEN** system does B

## REMOVED Requirements

### Requirement: Deprecated Feature

## RENAMED Requirements

- FROM: `### Requirement: Old Name`
- TO: `### Requirement: New Name`
```

**Principio clave: fusión inteligente**

A diferencia de una fusión programática, podés aplicar **actualizaciones parciales**:
- Para agregar un escenario, simplemente incluí ese escenario bajo MODIFIED - no hace falta copiar los escenarios existentes
- El delta representa una *intención*, no un reemplazo total
- Usá tu criterio para fusionar los cambios de forma sensata

**Salida en caso de éxito**

```
## Specs Sincronizados: <change-name>

Specs principales actualizados:

**<capability-1>**:
- Requirement agregado: "New Feature"
- Requirement modificado: "Existing Feature" (se agregó 1 escenario)

**<capability-2>**:
- Se creó un nuevo archivo de spec
- Requirement agregado: "Another Feature"

Los specs principales ya están actualizados. El change permanece activo - archivalo cuando la implementación esté completa.
```

**Reglas de seguridad**
- Leé tanto el delta spec como el spec principal antes de hacer cambios
- Preservá el contenido existente no mencionado en el delta
- Si algo no está claro, pedí una aclaración
- Mostrá lo que vas cambiando a medida que avanzás
- La operación debería ser idempotente - ejecutarla dos veces debería dar el mismo resultado
