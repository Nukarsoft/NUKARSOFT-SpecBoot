# Specboot — Guía rápida para desarrolladores

Para quien nunca usó specboot. Resume, en orden, todos los comandos del flujo completo: instalar specboot en un proyecto y trabajar un ticket de punta a punta.

**Qué es specboot:** un set de estándares (`docs/`), agentes y skills (`ai-specs/`) que le da a tu copiloto de IA (Claude/Cursor/Copilot/Gemini) un flujo de trabajo consistente basado en [OpenSpec](https://github.com/Fission-AI/OpenSpec).

**Qué NO hace specboot:** el flujo termina en un Pull Request (`/commit`). Mergear ese PR y deployar dependen 100% del CI/CD propio de tu proyecto, no de specboot (ver Parte 3).

---

## Parte 1 — Instalación (una sola vez por proyecto)

Aplica igual para un **proyecto nuevo** (sin código todavía) y para un **proyecto ya creado**. La única diferencia está marcada en el paso 3.

| # | Comando | Qué genera | Dónde queda la evidencia |
|---|---------|------------|---------------------------|
| 1 | Instalar openspec globalmente:<br>`npm install -g @fission-ai/openspec@latest`<br><br>Navegar al proyecto e inicializar:<br>`cd C:\ruta\a\tu-proyecto`<br>`openspec init` | Crea la carpeta `openspec/` (`config.yaml`, `changes/`, `specs/`) y habilita los comandos `/new`, `/ff`, `/apply`, `/verify`, `/archive`. También crea `.claude/` con sus propios comandos base. | 📁 **Repo:** `openspec/config.yaml`, `openspec/changes/`, `openspec/specs/` |
| 2a | Clonar el repo de SpecBoot en carpeta temporal:<br>`git clone https://github.com/Nukarsoft/NUKARSOFT-SpecBoot C:\temp\nukarsoft-specboot` | Descarga el repo con todos los archivos de estándares (`docs/`, `ai-specs/`, `CLAUDE.md`, `AGENTS.md`, etc.) en la carpeta temporal. | 📁 **Temp:** `C:\temp\nukarsoft-specboot\` — verificar con `dir C:\temp\nukarsoft-specboot` |
| 2b | Copiar al proyecto — **Windows CMD (3 comandos en orden)**:<br>`robocopy C:\temp\nukarsoft-specboot C:\ruta\a\tu-proyecto /E /XD .git`<br>`robocopy C:\temp\nukarsoft-specboot\.claude C:\ruta\a\tu-proyecto\.claude /E`<br>`robocopy C:\temp\nukarsoft-specboot\.cursor C:\ruta\a\tu-proyecto\.cursor /E`<br><br>**Mac/Linux:**<br>`cp -rn /tmp/nukarsoft-specboot/. /ruta/tu-proyecto/`<br><br>Reemplazá `C:\ruta\a\tu-proyecto` con la ruta real. Los 3 comandos son necesarios: el primero copia `docs/`, `ai-specs/` y archivos raíz; los otros dos copian `.claude/` y `.cursor/` que robocopy omite en el primer paso.<br><br>Verificar que los comandos de specboot quedaron (debe listar `setup-docs.md`, `commit.md`, etc.):<br>`dir C:\ruta\a\tu-proyecto\.claude\commands\` | 📁 **Repo:** `docs/`, `ai-specs/`, `CLAUDE.md`, `AGENTS.md`, `codex.md`, `GEMINI.md`, `.claude/commands/setup-docs.md`, `.claude/commands/commit.md` (y demás slash commands) — verificar con `git status` |
| 2c | Borrar la carpeta temporal:<br>`rmdir /S /Q C:\temp\nukarsoft-specboot` | Limpia la carpeta temporal que ya no se necesita. | `C:\temp\nukarsoft-specboot\` eliminada |
| 3 | `/setup-docs` | Analiza el código real del proyecto y reescribe `docs/base-standards.md`, `backend-standards.md`, `frontend-standards.md`, `documentation-standards.md`, `api-spec.yml`, `data-model.md` y `development_guide.md` con el stack, arquitectura y dominio reales. | 📁 **Repo:** `docs/base-standards.md`, `docs/backend-standards.md`, `docs/frontend-standards.md`, `docs/documentation-standards.md`, `docs/api-spec.yml`, `docs/data-model.md`, `docs/development_guide.md` — verificar con `git diff docs/` |
| 4 | Prompt manual: *"Update my openspec config.yml context to reference this repository's docs and ai-specs structure"* | Vincula `openspec/config.yaml` con `docs/` y `ai-specs/` | 📁 **Repo:** `openspec/config.yaml` — verificar con `git diff openspec/config.yaml` |
| 5 | Checklist manual (sin comando) | Confirmar que `CLAUDE.md`/`AGENTS.md`/`codex.md`/`GEMINI.md` apuntan a `docs/base-standards.md` | Verificación visual — no genera archivo |

---

## Parte 2 — Ciclo por ticket (se repite para cada feature/bug)

| # | Comando | Qué genera | Dónde queda la evidencia |
|---|---------|------------|---------------------------|
| 1 | `/enrich-us <TICKET-ID>` | Lee el ticket de ClickUp (o texto pegado), genera la US enriquecida con detalle técnico completo (`## Original` / `## Enhanced`) y la graba de vuelta en ClickUp. Primera vez: pregunta el Workspace y lo guarda en `.claude/clickup-workspace.local.md`. | 🔗 **ClickUp:** descripción del ticket actualizada con `[original]` y `[enhanced]` + estado cambiado a **En curso**<br>📁 **Local (no versionado):** `.claude/clickup-workspace.local.md` |
| 2 | `/new <TICKET-ID>` y luego `/ff <TICKET-ID>` (o `/propose`, equivalente a ambos juntos) | Crea el change de OpenSpec: propuesta, diseño, tareas y specs delta. | 📁 **Repo:**<br>`openspec/changes/<TICKET-ID>/proposal.md`<br>`openspec/changes/<TICKET-ID>/design.md`<br>`openspec/changes/<TICKET-ID>/tasks.md`<br>`openspec/changes/<TICKET-ID>/specs/<capability>/spec.md` |
| 3 | `/apply <TICKET-ID>` | Implementa las tareas de `tasks.md` una por una: código + tests. | 📁 **Repo:**<br>Código y tests en las rutas del proyecto<br>`openspec/changes/<TICKET-ID>/tasks.md` (marcado como completado)<br>`openspec/changes/<TICKET-ID>/reports/YYYY-MM-DD-step-N-unit-test-and-db-verification.md`<br>`coverage/YYYYMMDD-backend-coverage.md` |
| 4 | `/verify <TICKET-ID>`<br>+ `/save-verify-report <TICKET-ID>` | Valida la implementación contra los artefactos del change. `save-verify-report` persiste el resultado. | 📁 **Repo:** `openspec/changes/<TICKET-ID>/reports/YYYY-MM-DD-verify-report.md`<br>🔗 **ClickUp:** comentario con el veredicto (PASS / FAIL / PARTIAL) |
| 5 | `/adversarial-review <TICKET-ID>` (o URL de PR) | Revisión red-team: tabla de hallazgos + veredicto PASS/FAIL. Para testing manual: grabá con **Loom** (loom.com, gratis) y pegá el link en ClickUp. | 📁 **Repo:** `openspec/changes/<TICKET-ID>/reports/YYYY-MM-DD-adversarial-review.md`<br>🔗 **ClickUp:** comentario con veredicto + link de grabación Loom (si aplica) |
| 6 | `/archive <TICKET-ID>` | Archiva el change y sincroniza los specs principales. | 📁 **Repo:** `openspec/specs/<capability>/spec.md` actualizado |
| 7 | `/commit` | Crea el commit, pushea el branch y abre (o actualiza) el PR con `gh`. Si hay ticket de ClickUp: actualiza el estado. | 📁 **Repo:** commit en el branch remoto<br>🔗 **GitHub:** PR abierto (URL en el chat)<br>🔗 **ClickUp:** estado cambiado a **En progreso** + comentario con URL del PR |

---

## Parte 2b — Actualizar specboot en un proyecto existente

Si ya instalaste specboot en tu proyecto y el repo de NUKARSOFT-SpecBoot recibió mejoras (nuevos skills, comandos corregidos, agentes actualizados), podés traer solo esos cambios **sin pisar lo que ya personalizaste** (`docs/`, `openspec/`, tu código).

| # | Comando | Qué actualiza | Qué protege |
|---|---------|--------------|-------------|
| 1 | Clonar la versión nueva en temp:<br>`git clone https://github.com/Nukarsoft/NUKARSOFT-SpecBoot C:\temp\nukarsoft-specboot` | Descarga la última versión de specboot. | — |
| 2 | `/sync-specboot` | Muestra qué archivos de infraestructura cambiaron, pide confirmación y aplica solo esos cambios. | 🔒 `docs/` (tus estándares personalizados)<br>🔒 `openspec/` (tus changes y specs)<br>🔒 `.claude/settings.local.json`<br>🔒 Código del proyecto |
| 3 | Borrar temp:<br>`rmdir /S /Q C:\temp\nukarsoft-specboot` | Limpia la carpeta temporal. | — |

**¿Qué se actualiza?** `ai-specs/skills/`, `ai-specs/agents/`, `.claude/commands/`, `.claude/agents/`, `.cursor/`, `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `codex.md`.

**¿Solo un archivo específico?** Si solo cambió un skill, podés copiarlo puntualmente sin correr todo el sync:
```
copy C:\temp\nukarsoft-specboot\ai-specs\skills\commit\SKILL.md C:\ruta\tu-proyecto\ai-specs\skills\commit\SKILL.md
```

---

## Parte 3 — Fuera de specboot: merge y deploy

Specboot no mergea ni deploya. Una vez creado el PR:

1. **Merge**: manual, vía GitHub (botón) o `gh pr merge`, según las reglas de branch protection del equipo.
2. **Deploy**: depende del CI/CD propio del proyecto (GitHub Actions, Serverless, etc.), documentado en `docs/development_guide.md` tras correr `/setup-docs`.

---

## Notas / limitaciones conocidas

- `/verify` es un comando propio de OpenSpec — su output solo aparece en el chat. Ejecutá `/save-verify-report` inmediatamente después para guardarlo.
- `show-spec-working` nunca escribe archivos — su output vive solo en el chat.
- `docs/frontend-standards.md` no define un path de reporte de cobertura (a diferencia de backend, que sí tiene `coverage/YYYYMMDD-backend-coverage.md`).
- **Grabaciones de pantalla**: usá Loom (loom.com, gratis) para testing manual. Pegá el link en el ticket de ClickUp como comentario.
