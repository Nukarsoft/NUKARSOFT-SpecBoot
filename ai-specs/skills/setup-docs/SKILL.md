---
name: setup-docs
description: Analizar el código real del proyecto y personalizar todo el contenido de docs/ (stack, arquitectura, dominio, API, data model), reemplazando el material de referencia genérico que trae specboot.
author: LIDR.co
version: 1.0.0
---
# Skill setup-docs

Usalo cuando este flujo de trabajo sea requerido en el proyecto, típicamente después de importar specboot a un proyecto nuevo (paso 3 "Customize `docs/` for Your Project" de `README.md`) o cuando el código del proyecto avanzó lo suficiente como para que `docs/` haya quedado desactualizado respecto al stack, arquitectura o dominio reales.

## Instrucciones

### Paso 1 — Detectar si `docs/` está en estado genérico o ya personalizado

Antes de tocar cualquier archivo, leé `docs/base-standards.md`, `docs/backend-standards.md`, `docs/frontend-standards.md`, `docs/documentation-standards.md`, `docs/data-model.md`, `docs/api-spec.yml` y `docs/development_guide.md`, y buscá señales de que siguen siendo el material de referencia genérico que trae specboot por defecto:

- Menciones del dominio de referencia "LTI" bajo cualquiera de sus variantes (Leadership. Technology. Impact / Learning Tracking Initiative / Learning Technology Initiative) o del dominio de ejemplo ATS/reclutamiento (Candidate, Position, Interview, Application).
- Stack de ejemplo descrito ("Node.js/TypeScript/Express", frontend React genérico, DDD de referencia) que no coincide con lo que vas a detectar en el Paso 2.
- Cualquier frase que se identifique a sí misma como ejemplo/plantilla (ej. lo descripto en `README.md` como "Reference Examples (from LIDR Project)").

**Si encontrás estas señales** → `docs/` sigue siendo el material genérico sin personalizar. Continuá directo al Paso 2 sin preguntar nada.

**Si NO las encontrás** (el dominio, el stack o las entidades ya reflejan un proyecto distinto al de referencia) → `docs/` ya fue personalizado en una ejecución anterior. Antes de sobreescribir nada, preguntale explícitamente al usuario si querés que actualice el contenido existente para reflejar el estado actual del código, o si preferís mantenerlo tal cual está:
- **Actualizar**: continuá con el resto del flujo, usando el contenido actual de `docs/` como base a refrescar (conservá decisiones de personalización previas que el código actual no contradiga; no las trates como si fueran el molde genérico a descartar por completo).
- **Mantener**: no modifiques ningún archivo de `docs/`. Informá que no se realizó ningún cambio y terminá acá.

### Paso 2 — Analizar el proyecto real

Recolectá evidencia real del código, sin asumir nada a partir del contenido genérico:

- Manifiestos de dependencias: `package.json` (raíz y de cada workspace/paquete), o el equivalente del ecosistema que corresponda (`requirements.txt`/`pyproject.toml`, `go.mod`, etc.) según lo que exista en el proyecto.
- Estructura real de carpetas (monorepo vs. app única, separación backend/frontend/packages, organización por capas o por dominio).
- Framework(s) de backend y frontend, ORM/query builder, motor de base de datos, framework de testing, linter/formatter en uso.
- Endpoints/rutas existentes (controllers, routers, schemas OpenAPI/GraphQL si ya hay alguno) para inferir la API real.
- Modelos/entidades de datos reales (entities, schemas, migrations, modelos de Prisma/TypeORM/Sequelize/etc.) para inferir el data model real.
- Scripts de `package.json`, Dockerfiles, `docker-compose`, configuración de CI, para inferir la guía de instalación y desarrollo real.
- Cualquier README o documentación ya existente del proyecto que explique el dominio de negocio.

A partir de esta evidencia, inferí: **stack tecnológico**, **patrones de arquitectura** (DDD, arquitectura en capas, monolito/microservicios, etc.) y **dominio de negocio real** (qué problema resuelve el proyecto y cuáles son sus entidades principales).

Si el proyecto está vacío o en un estado muy inicial (sin código de aplicación todavía), decilo explícitamente en el resumen final (Paso 7) y generá los documentos con la mejor inferencia disponible (nombre del proyecto, README, dependencias ya declaradas), dejando notas claras sobre qué quedó como supuesto a validar por el equipo.

### Paso 3 — Confirmar el repositorio de GitHub (para merge y deploy)

Detectá si el proyecto ya tiene un remoto de git configurado:

```bash
git remote get-url origin 2>/dev/null
```

- **Si devuelve una URL**: confirmala con el usuario (ej. "Detecté que el remoto `origin` apunta a `<url>`. ¿Es ese el repositorio de GitHub que debo usar para hacer push, abrir PRs y deployar?"). Si confirma, usá esa URL/ruta (`owner/repo`) en el resto del flujo.
- **Si no hay remoto configurado, o el usuario lo corrige**: preguntale explícitamente:
  - ¿El proyecto va a vivir en GitHub? Si sí, ¿cuál es la ruta (`owner/repo` o URL completa de clone)?
  - ¿Todavía no existe el repo (proyecto nuevo sin remoto aún)? Dejalo anotado como pendiente en vez de inventarlo.
  - ¿El proyecto no va a usar GitHub (repo solo local, u otro proveedor como GitLab/Bitbucket)? Anotá esa decisión también — nunca asumas GitHub por defecto.
- Nunca inventes ni asumas una ruta de GitHub: si el usuario todavía no la tiene, dejala explícitamente marcada como "pendiente de definir" en `development_guide.md` en vez de dejar sin avisar el placeholder de ejemplo (`git@github.com:your-org/your-project.git`).

Esta confirmación determina qué URL de clone y qué convención de rama base (ej. `main`, `develop`) van en `development_guide.md`, y es la información que después usan flujos como el skill `commit` para hacer push, abrir PRs y, si el proyecto lo requiere, deployar.

### Paso 4 — Reescribir cada documento de `docs/`

Mantené exactamente el mismo conjunto de archivos y nombres; no agregues ni quites archivos de `docs/`:

- `docs/base-standards.md`
- `docs/backend-standards.md`
- `docs/frontend-standards.md`
- `docs/documentation-standards.md`
- `docs/api-spec.yml`
- `docs/data-model.md`
- `docs/development_guide.md`

Para cada uno, reemplazá el contenido de referencia genérico (stack de ejemplo, dominio ATS/LTI, entidades Candidate/Position/Interview, etc.) por el contexto real detectado en el Paso 2, preservando la estructura y el propósito de cada documento:

- **`base-standards.md`**: mantené los principios generales (tareas pequeñas, TDD, tipado, nombres claros, etc.) y los links a los demás documentos; actualizá cualquier referencia a stack/dominio de ejemplo y reescribí la sección de estándares de idioma según el [Paso 5](#paso-5--reglas-de-idioma).
- **`backend-standards.md`** / **`frontend-standards.md`**: actualizá stack tecnológico, patrones de arquitectura, estructura de carpetas, convenciones de testing y el frontmatter `globs` para que apunten a las rutas reales del proyecto.
- **`api-spec.yml`**: reemplazá título, descripción, paths y schemas de ejemplo por los endpoints y modelos reales detectados; si el proyecto todavía no expone una API, dejá un esqueleto mínimo válido y una nota explícita de que está pendiente de completar.
- **`data-model.md`**: reemplazá las entidades de ejemplo por las entidades/tablas reales detectadas (campos, relaciones, diagrama entidad-relación si corresponde).
- **`development_guide.md`**: reemplazá los pasos de instalación/ejecución de ejemplo por los reales del proyecto (gestor de paquetes, scripts, variables de entorno, Docker, base de datos, comandos de test, etc.), incluyendo el comando `git clone` de ejemplo (`your-org/your-project`), que debe reemplazarse por la URL real confirmada en el [Paso 3](#paso-3--confirmar-el-repositorio-de-github-para-merge-y-deploy) (o dejarse marcada como pendiente si el usuario todavía no la tiene).
- **`documentation-standards.md`**: mantené el proceso de mantenimiento de documentación (qué actualizar y cuándo), ajustando solo la regla de idioma según el [Paso 5](#paso-5--reglas-de-idioma).

### Paso 5 — Reglas de idioma

- Escribí toda la prosa de `docs/` (explicaciones, descripciones, guías) **en español**.
- Mantené **en inglés** todo lo que sea identificador o artefacto técnico literal: fragmentos de código y ejemplos, nombres de campos/endpoints/schemas en `api-spec.yml`, identificadores y nombres de entidades/campos en `data-model.md`, nombres de variables/funciones/comandos de terminal, y cualquier snippet embebido en los `*-standards.md`.
- Actualizá explícitamente la sección de estándares de idioma en `base-standards.md` (sección "Estándares de idioma"/"Solo inglés") y la regla equivalente en `documentation-standards.md` ("ALWAYS WRITE IN ENGLISH") para que reflejen esta misma política (prosa en español, identificadores/código en inglés) en vez de "solo inglés" para todo. Esto es necesario para que el propio documento sea consistente con lo que él mismo prescribe.

### Paso 6 — Consistencia entre documentos

- Usá la misma terminología de dominio (nombres de entidades, roles, procesos de negocio) en todos los documentos.
- Usá el mismo stack, versiones y nombres de herramientas en `base-standards.md`, `backend-standards.md`, `frontend-standards.md` y `development_guide.md`.
- Verificá que las entidades y campos de `data-model.md` coincidan con los schemas usados en `api-spec.yml`.
- Verificá que los links relativos entre documentos (por ejemplo los que salen de `base-standards.md`) sigan apuntando a los archivos correctos.

### Paso 7 — Resumen final

Al terminar, mostrale al usuario un resumen conciso con:

- **Detectado**: stack tecnológico, patrones de arquitectura y dominio de negocio inferidos en el Paso 2 (incluyendo qué quedó como supuesto si el proyecto estaba vacío o incompleto).
- **Repositorio de GitHub**: la ruta confirmada en el Paso 3, o que quedó marcada como pendiente de definir.
- **Archivos modificados**: lista de los archivos de `docs/` que se reescribieron.
- Si en el Paso 1 el usuario eligió "Mantener", indicá eso en lugar del resumen de detección y confirmá que no se modificó nada.

## Notas

- Nunca agregues ni quites archivos de `docs/`: el conjunto de documentos y sus nombres es fijo.
- No inventes stack, endpoints o entidades que no estén respaldados por evidencia real del código; si algo no se puede inferir con confianza, dejalo marcado como pendiente de completar por el equipo en vez de inventarlo.
- Este skill no toca `ai-specs/agents` ni `ai-specs/skills`; si además hace falta adaptar agentes o skills al dominio real, tratalo como un paso separado (ver sección "Adapting to Your Project" de `README.md`).
