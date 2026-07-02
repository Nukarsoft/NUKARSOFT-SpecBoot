---
name: sync-agent-symlinks
description: Analiza y sincroniza la exposición de skills de agentes después de cambios en los skills de ai-specs (adiciones, eliminaciones, renombres). Usar cuando se agregan/eliminan skills en ai-specs y .claude/skills y .cursor/skills deben mantenerse alineados mediante symlinks.
author: LIDR.co
version: 1.0.0
---

# Skill sync-agent-symlinks

Mantiene las estructuras de skills expuestas a los agentes sincronizadas con `ai-specs/skills` como fuente canónica.

Usá este skill después de cualquier cambio en `ai-specs/skills` (skill nuevo, skill eliminado, skill renombrado, skill movido), especialmente cuando necesitás evitar symlinks obsoletos o rotos.

## Alcance y reglas de seguridad

- La fuente canónica es `ai-specs/skills`.
- Los destinos espejo (mirror) son:
  - `.claude/skills`
  - `.cursor/skills`
- Gestioná únicamente las entradas que sean symlinks hacia `../../ai-specs/skills/<skill-name>`.
- No elimines directorios que no sean symlinks en los destinos espejo a menos que el usuario lo pida explícitamente.
- Nunca sobrescribas automáticamente un directorio real; reportalo como un conflicto.

## Flujo de trabajo

### Paso 1 - Construir inventarios

Reuní tres inventarios:

1. Skills canónicos desde `ai-specs/skills/*/SKILL.md`
2. Entradas espejo en `.claude/skills`
3. Entradas espejo en `.cursor/skills`

A partir de las entradas espejo, clasificá:
- `linked`: symlink válido que apunta a un skill canónico existente
- `broken`: falta el destino del symlink
- `orphan`: el symlink apunta al namespace canónico pero el skill ya no existe
- `conflict`: entrada que no es symlink con el mismo nombre que un skill canónico
- `external`: entrada no gestionada por la política de symlinks canónica (dejar sin cambios)

### Paso 2 - Calcular el plan de sincronización

Para cada destino espejo:

- `to_add`: skills canónicos que faltan en el destino espejo
- `to_fix`: symlinks canónicos rotos que deben recrearse
- `to_remove`: symlinks canónicos huérfanos sin fuente canónica
- `to_skip`: conflictos y entradas externas (solo reportar)

### Paso 3 - Aplicar la sincronización de forma segura

Aplicá los cambios en este orden:

1. Agregar symlinks faltantes:
   - `<mirror>/<skill-name> -> ../../ai-specs/skills/<skill-name>`
2. Corregir symlinks canónicos rotos:
   - Eliminar el enlace roto y recrear el mismo enlace canónico
3. Eliminar symlinks canónicos huérfanos:
   - Eliminar el symlink solo si apunta al namespace canónico y el skill ya no existe

Nunca elimines:
- directorios que no sean symlinks
- archivos que no estén bajo la política de symlinks canónica

### Paso 4 - Verificar integridad

Después de los cambios:

- Confirmá que cada skill canónico exista en ambos destinos espejo como un symlink válido, o esté explícitamente listado como conflicto.
- Confirmá que no queden symlinks canónicos rotos.
- Confirmá que las entradas externas permanezcan intactas.

### Paso 5 - Reportar resultados

Devolvé un reporte de sincronización conciso:

- Cantidad de skills canónicos
- Por destino espejo:
  - agregados
  - corregidos
  - eliminados
  - conflictos
  - entradas externas omitidas
- Bloqueos pendientes (si los hay)

## Escenarios de agregado/eliminación

### Escenario A - Nuevo skill agregado en ai-specs

Comportamiento esperado:
- Agregar el symlink faltante en `.claude/skills`
- Agregar el symlink faltante en `.cursor/skills`
- Verificar que ambos enlaces resuelvan a la carpeta canónica

### Escenario B - Skill eliminado de ai-specs

Comportamiento esperado:
- Eliminar el symlink canónico huérfano de `.claude/skills`
- Eliminar el symlink canónico huérfano de `.cursor/skills`
- Mantener intactos los directorios no canónicos y reportarlos

## Patrones de comandos (referencia)

Usá comandos equivalentes para tu entorno:

```bash
# list canonical skill directories (names with SKILL.md)
ls ai-specs/skills

# inspect mirror entries with link metadata
ls -la .claude/skills
ls -la .cursor/skills

# add canonical link
ln -s ../../ai-specs/skills/<skill-name> .claude/skills/<skill-name>
ln -s ../../ai-specs/skills/<skill-name> .cursor/skills/<skill-name>

# remove orphan canonical link
rm .claude/skills/<skill-name>
rm .cursor/skills/<skill-name>
```

## Señales de alerta

Nunca:
- trates `ai-specs` como no canónico
- elimines automáticamente directorios reales en los destinos espejo
- dejes symlinks canónicos rotos después de sincronizar
- omitas conflictos silenciosamente sin reportarlos

Siempre:
- analizá antes de cambiar
- aplicá cambios mínimos y seguros
- preservá las entradas no canónicas
- proporcioná un reporte final de sincronización con los bloqueos pendientes
