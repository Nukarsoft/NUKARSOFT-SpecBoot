---
name: enrich-us
description: Analizar y enriquecer historias de usuario con detalle técnico completo y listo para implementación, a partir de input directo del ticket o ClickUp.
author: LIDR.co
version: 1.0.0
---
# Skill enrich-us

Usalo cuando este flujo de trabajo sea requerido en el proyecto.

## Instrucciones

Por favor analizá y enriquecé el ticket: $ARGUMENTS.

Seguí estos pasos:

1. Determiná la fuente de entrada del ticket:
   - **Modo de input directo (por defecto cuando se proporciona el texto del ticket):** Usá el contenido del ticket compartido por el usuario en el prompt/chat.
   - **Modo ClickUp (opcional):** Si el usuario proporciona un ID/key de ClickUp, o pide usar ClickUp (incluyendo referencias como "el que está en progreso"), usá el MCP de ClickUp para obtener los detalles del ticket.
2. Si vas a entrar en modo ClickUp, resolvé primero el Workspace a usar siguiendo [Selección de Workspace de ClickUp](#selección-de-workspace-de-clickup) antes de hacer cualquier lectura/escritura.
3. Actuá como un experto de producto con conocimiento técnico.
4. Comprendé el problema descrito en el ticket.
5. Decidí si la User Story está completamente detallada según las mejores prácticas de producto. Validá que incluya:
   - Descripción completa de la funcionalidad
   - Lista exhaustiva de campos a actualizar
   - Estructura y URLs de los endpoints requeridos
   - Archivos/módulos a modificar según la arquitectura y las buenas prácticas
   - Definición de hecho (pasos de implementación y entrega)
   - Actualizaciones de documentación y de tests unitarios
   - Requisitos no funcionales (seguridad, rendimiento, observabilidad, etc.)
6. Si la historia carece de suficiente detalle técnico para una implementación autónoma, proporcioná una versión mejorada que sea más clara, específica y concisa, alineada con el paso 5. Usá el contexto técnico del proyecto desde `@documentation`. Devolvé el resultado en markdown.
7. El formato de salida siempre debe incluir:
   - `## Original`
   - `## Enhanced`
8. La escritura en ClickUp aplica **siempre** en modo ClickUp (no es opcional):
   - Actualizá la descripción del ticket de ClickUp reemplazando el contenido existente con la versión enriquecida completa: secciones `h2` claras `[original]` y `[enhanced]`, con todo el detalle técnico generado (campos, endpoints, archivos a modificar, criterios de aceptación, tests, requisitos no funcionales). Usá listas y fragmentos de código cuando sea útil.
   - Cambiá el estado del ticket a `En curso` (independientemente del estado actual).

## Selección de Workspace de ClickUp

Este mecanismo aplica a **cualquier skill que use el MCP de ClickUp** (empezando por `enrich-us`). Debe ejecutarse una única vez antes de la primera lectura o escritura en ClickUp dentro de un proyecto:

1. Verificá si existe el archivo `.claude/clickup-workspace.local.md` en la raíz del proyecto.
2. **Si el archivo existe:** leé el Workspace (nombre e ID) configurado ahí y usalo directamente en todas las acciones de ClickUp de esta sesión, sin volver a preguntar.
3. **Si el archivo NO existe:**
   1. Listá los Workspaces disponibles usando el MCP de ClickUp, mostrando nombre e ID de cada uno.
   2. Preguntale explícitamente al usuario cuál Workspace corresponde a este proyecto.
   3. Guardá la respuesta (nombre e ID del Workspace elegido) en `.claude/clickup-workspace.local.md`, creando la carpeta `.claude/` si no existe, con este formato:

      ```markdown
      # ClickUp Workspace

      - name: <nombre del workspace>
      - id: <id del workspace>
      ```
   4. Usá ese Workspace para la acción actual y para todas las acciones futuras de ClickUp en este proyecto.
4. `.claude/clickup-workspace.local.md` es una preferencia local del proyecto: no se versiona (está en `.gitignore`) y no se comparte entre proyectos ni repos.

## Paso final — Guiar al siguiente paso del flujo SpecBoot

> ⚠️ **IMPORTANTE:** Al terminar este skill, **NO ofrezcas implementar el cambio, no generes código, no propongas tareas de desarrollo**. El flujo de SpecBoot requiere pasar primero por OpenSpec.

Una vez completada la escritura en ClickUp, mostrá este mensaje al usuario:

---
✅ **US enriquecida y grabada en ClickUp.** Estado del ticket cambiado a **En curso**.

**Siguiente paso → `/new <TICKET-ID>`**
Esto crea la propuesta y el change de OpenSpec antes de implementar.

¿Continuamos?

---

Esperá confirmación del usuario antes de cualquier otra acción.

## Notas

- No requieras ClickUp cuando el usuario ya proporcionó el contenido completo del ticket directamente.
- Si el input es ambiguo (por ejemplo, el usuario da una referencia corta sin contenido), preguntá si resolver vía ClickUp o si pedir el texto completo del ticket.
- Nota: el modo ClickUp requiere tener el MCP de ClickUp configurado en este proyecto (configuralo con `claude mcp add` cuando esté disponible). Hasta entonces, usá el modo de input directo.
- Antes de usar el MCP de ClickUp, resolvé siempre el Workspace según [Selección de Workspace de ClickUp](#selección-de-workspace-de-clickup).
