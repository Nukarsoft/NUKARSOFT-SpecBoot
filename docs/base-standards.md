---
description: Este documento contiene todas las reglas y lineamientos de desarrollo para este proyecto, aplicables a todos los agentes de IA (Claude, Cursor, Codex, Gemini, etc.).
alwaysApply: true
---

## 1. Principios fundamentales

- **Tareas pequeñas, de a una**: Trabajá siempre en pasos pequeños, de a uno. Nunca avances más de un paso a la vez.
- **Test-Driven Development**: Empezá con tests que fallen para cualquier funcionalidad nueva (TDD), según el detalle de la tarea.
- **Seguridad de tipos**: Todo el código debe estar completamente tipado.
- **Nombres claros**: Usá nombres claros y descriptivos para todas las variables y funciones.
- **Cambios incrementales**: Preferí cambios incrementales y focalizados por sobre modificaciones grandes y complejas.
- **Cuestionar supuestos**: Cuestioná siempre los supuestos e inferencias.
- **Detección de patrones**: Detectá y señalá patrones de código repetidos.

## 2. Estándares de idioma

- **Solo inglés** — artefactos técnicos internos:
    - Código (variables, funciones, clases, comentarios, mensajes de error, mensajes de log)
    - Documentación técnica (README, guías, docs de API)
    - Esquemas de datos y nombres de bases de datos
    - Archivos de configuración y scripts
    - Mensajes de commit de Git
    - Nombres y descripciones de tests

- **Solo español** — todo contenido de cara al usuario o al cliente:
    - Tickets de ClickUp (títulos, descripciones, comentarios)
    - Reportes generados por skills (verify report, QA report, security review, closure report, adversarial review)
    - Texto de UI (labels, mensajes, notificaciones, errores visibles al usuario)
    - Comunicaciones y documentos entregables al cliente

## 3. Estándares específicos

Para estándares y lineamientos detallados específicos de las distintas áreas del proyecto, consultá:

- [Backend Standards](./backend-standards.md) - Desarrollo de API, patrones de base de datos, testing, seguridad y mejores prácticas de backend
- [Frontend Standards](./frontend-standards.md) - Componentes React, lineamientos de UI/UX y arquitectura frontend
- [Documentation Standards](./documentation-standards.md) - Estructura, formato y mantenimiento de la documentación técnica, incluyendo estándares de IA como este documento
- [OpenSpec Tasks Mandatory Steps](./openspec-tasks-mandatory-steps.md) - Checklist obligatorio y reglas de ejecución al crear o actualizar archivos `tasks.md` de OpenSpec

## 4. Skills del proyecto

- Los skills viven en `ai-specs/skills`.
- Cuando un pedido coincide con un skill, cargá y seguí el `SKILL.md` correspondiente automáticamente antes de continuar.
- Cargá también cualquier archivo referenciado dentro de la carpeta del skill (por ejemplo, `references/*.md`) cuando el skill lo requiera.

## 5. Requisito de modelo para planificación

Los workflows de planificación deben ejecutarse con Opus high reasoning.

Este requisito aplica a:
- `enrich-us`
- `openspec-ff-change`
- `openspec-continue-change`

Antes de iniciar cualquiera de estos workflows, verificá que la sesión esté usando Opus high reasoning. Si no lo está, **autocorregite** agregando `"model": "claude-opus-4-7"` a `.claude/settings.json` (usá el skill `update-config` o editalo directamente), y luego continuá — no te detengas a preguntarle al usuario. Hacé lo mismo para volver a sonnet medium en cualquier otro paso.

## 6. Integridad de symlinks y portabilidad multi-agente

- **Fuente canónica**: Mantené los artefactos reutilizables en `ai-specs` como fuente canónica. Las rutas específicas de cada agente (como `.claude` y `.cursor`) deben referenciarlos mediante symlinks siempre que sea posible.
- **Seguridad ante actualizaciones**: Cada vez que se renombre o mueva un archivo, o cambie su sufijo, verificá y actualizá todos los symlinks que apunten a él antes de dar el cambio por completado.
- **Enlace de nuevos artefactos**: Cada vez que se cree un nuevo artefacto que requiera exposición multi-agente (por ejemplo, nuevos agentes o skills en `ai-specs`), creá los symlinks correspondientes desde las rutas de referencia específicas de cada agente.
- **Revisión de personalizaciones externas**: Cada vez que se introduzca una personalización fuera de `ai-specs`, evaluá si debería moverse a `ai-specs` y reemplazarse por symlinks desde las ubicaciones originales.
- **Criterio de finalización**: Un cambio está incompleto si deja symlinks rotos, destinos desactualizados o artefactos canónicos duplicados entre las carpetas específicas de cada agente.

## 7. Actualizaciones obligatorias de artefactos OpenSpec para cambios posteriores al apply

Cuando aparece un nuevo pedido de fix/cambio después de `opsx:apply` (o `/apply`) y antes de `opsx:archive` (o `/archive`), los agentes deben tratarlo primero como una actualización de spec, no como un "arreglemos esto rápido" informal. Es el principio central de openspec: la documentación es la fuente de verdad.

Orden obligatorio:

1. Actualizar los artefactos del cambio OpenSpec actual que se vean afectados (por ejemplo: escenarios, requirements/specs y `tasks.md`). No agregues tareas como "bugfixes" sino como parte del diseño inicial, en la sección correspondiente.
2. Si se necesita regenerar artefactos, ejecutá el paso de OpenSpec correspondiente (`opsx:continue`, `opsx:ff`, o equivalente) antes de codear.
3. Implementá código solo después de que los artefactos reflejen el nuevo pedido.
4. Volvé a ejecutar la verificación contra los artefactos actualizados antes de archivar.

No apliques fixes directos solo de código en esta ventana sin actualizar los artefactos de OpenSpec.
