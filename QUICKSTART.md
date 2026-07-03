# Specboot — Guía rápida para desarrolladores

Para quien nunca usó specboot. Resume, en orden, todos los comandos del flujo completo: instalar specboot en un proyecto y trabajar un ticket de punta a punta.

**Qué es specboot:** un set de estándares (`docs/`), agentes y skills (`ai-specs/`) que le da a tu copiloto de IA (Claude/Cursor/Copilot/Gemini) un flujo de trabajo consistente basado en [OpenSpec](https://github.com/Fission-AI/OpenSpec).

**Qué NO hace specboot:** el flujo termina en un Pull Request (`/commit`). Mergear ese PR y deployar dependen 100% del CI/CD propio de tu proyecto, no de specboot (ver Parte 3).

---

## Parte 1 — Instalación (una sola vez por proyecto)

Aplica igual para un **proyecto nuevo** (sin código todavía) y para un **proyecto ya creado**. La única diferencia está marcada en el paso 3.

| # | Comando | Qué genera | Dónde queda la evidencia |
|---|---------|------------|---------------------------|
| 1 | `npm install -g @fission-ai/openspec@latest`<br>`cd tu-proyecto && openspec init` | Crea la carpeta `openspec/` (`config.yaml`, `changes/`, `specs/`) y habilita los comandos `/new`, `/ff`, `/apply`, `/verify`, `/archive`. También crea una carpeta `.claude/` con sus propios comandos base. | `openspec/config.yaml` en tu proyecto |
| 2 | `git clone https://github.com/<tu-org>/<tu-specboot>.git C:\temp\specboot-temp`<br>**Windows:** `robocopy C:\temp\specboot-temp tu-proyecto /E /XD .git`<br>**Mac/Linux:** `cp -rn /tmp/specboot-temp/. tu-proyecto/` | Copia `docs/`, `ai-specs/`, `AGENTS.md`/`CLAUDE.md`/`codex.md`/`GEMINI.md` y **agrega** los comandos de specboot a `.claude/commands/` (sobre los que ya creó openspec). ⚠️ **Debe ejecutarse DESPUÉS de `openspec init`**: si se hace antes, `openspec init` pisa los comandos de specboot. ⚠️ **No uses `cp -rn <carpeta>/*`**: el glob `*` no copia dotfolders como `.claude/`. | Archivos nuevos sin commitear en tu proyecto (`git status`), incluyendo `.claude/commands/setup-docs.md`, `/commit`, etc. |
| 3 | `/setup-docs` | Analiza tu código real (**proyecto existente**: stack/dominio reales · **proyecto nuevo**: infiere lo mínimo y deja supuestos marcados), **pregunta/confirma la ruta de tu repo de GitHub**, y reescribe `docs/base-standards.md`, `backend-standards.md`, `frontend-standards.md`, `documentation-standards.md`, `api-spec.yml`, `data-model.md` y `development_guide.md` | `git diff` sobre `docs/*`, resumen final en el chat (stack detectado + repo de GitHub), ruta de GitHub queda escrita en `docs/development_guide.md` |
| 4 | Prompt manual a tu copiloto: *"Update my openspec config.yml context to reference this repository's docs and ai-specs structure"* (ver README, sección Quick Start paso 4) | Vincula `openspec/config.yml` con `docs/` y `ai-specs/` | `git diff` sobre `openspec/config.yml` |
| 5 | Checklist manual (sin comando) | Confirmar que `CLAUDE.md`/`AGENTS.md`/`codex.md`/`GEMINI.md` cargan `docs/base-standards.md` | No genera archivo — es una verificación visual |

---

## Parte 2 — Ciclo por ticket (se repite para cada feature/bug)

| # | Comando | Qué genera | Dónde queda la evidencia |
|---|---------|------------|---------------------------|
| 1 | `/enrich-us <TICKET-ID>` | Lee el ticket (ClickUp o texto pegado) y devuelve una versión enriquecida (`## Original` / `## Enhanced`). Primera vez que se usa ClickUp: pregunta el Workspace | En el chat, y opcionalmente escrito de vuelta en el propio ticket de ClickUp. `.claude/clickup-workspace.local.md` (local, no versionado) guarda el Workspace elegido |
| 2 | `/new <TICKET-ID>` y luego `/ff <TICKET-ID>` (o `/propose`, equivalente a ambos juntos) | Crea el change de OpenSpec: propuesta, diseño, tareas y specs delta | `openspec/changes/<TICKET-ID>/proposal.md`, `design.md`, `tasks.md`, `specs/<capability>/spec.md` |
| 3 | `/apply <TICKET-ID>` | Implementa las tareas de `tasks.md` una por una: código + tests | Diff de código/tests + `tasks.md` marcado como completado, más el reporte de verificación en `specs/<TICKET-ID>/reports/YYYY-MM-DD-step-N+1-unit-test-and-db-verification.md` (según `docs/openspec-tasks-mandatory-steps.md`) y `coverage/YYYYMMDD-backend-coverage.md` |
| 4 | `/verify <TICKET-ID>` | Valida la implementación contra los artefactos del change (comando propio de OpenSpec) | Solo en el chat |
| 5 | `/adversarial-review <TICKET-ID>` (o con URL de PR) | Revisión red-team independiente: tabla de hallazgos + veredicto PASS/FAIL | Solo en el chat — no genera archivo |
| 6 | `/archive <TICKET-ID>` | Archiva el change y sincroniza los specs principales | `openspec/specs/<capability>/spec.md` actualizado |
| 7 | `/commit` | Crea el commit, pushea el branch y abre (o actualiza) el PR con `gh` | Commit en el branch remoto + PR abierto en GitHub (URL en el chat) |

---

## Parte 3 — Fuera de specboot: merge y deploy

Specboot no mergea ni deploya. Una vez creado el PR:

1. **Merge**: manual, vía GitHub (botón) o `gh pr merge`, según las reglas de branch protection del equipo.
2. **Deploy**: depende del CI/CD propio del proyecto (GitHub Actions, Serverless, etc.), documentado en `docs/development_guide.md` tras correr `/setup-docs`.

---

## Notas / limitaciones conocidas

- `adversarial-review` y `show-spec-working` **nunca** escriben archivos — su output vive solo en el chat.
- `docs/frontend-standards.md` no define un path de reporte de cobertura (a diferencia de backend, que sí tiene `coverage/YYYYMMDD-backend-coverage.md`).
