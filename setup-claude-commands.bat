@echo off
REM =====================================================================
REM  setup-claude-commands.bat
REM  Crea .claude\commands\ con todos los skills de SpecBoot mapeados
REM  como slash commands de Claude Code.
REM  Ejecutar UNA SOLA VEZ desde la raiz del repo.
REM =====================================================================

SET ROOT=%~dp0
SET CMD_ROOT=%ROOT%.claude\commands
SET TPL_CMD=%ROOT%packages\specboot\template\.claude\commands

echo Creando carpetas de commands...
mkdir "%CMD_ROOT%" 2>nul
mkdir "%TPL_CMD%" 2>nul

echo Generando archivos de comando en .claude\commands\ ...

(echo Read the file `ai-specs/skills/setup-docs/SKILL.md` and follow its instructions exactly.) > "%CMD_ROOT%\setup-docs.md"
(echo Read the file `ai-specs/skills/update-docs/SKILL.md` and follow its instructions exactly.) > "%CMD_ROOT%\update-docs.md"
(echo Read the file `ai-specs/skills/commit/SKILL.md` and follow its instructions exactly.) > "%CMD_ROOT%\commit.md"
(echo Read the file `ai-specs/skills/enrich-us/SKILL.md` and follow its instructions exactly.) > "%CMD_ROOT%\enrich-us.md"
(echo Read the file `ai-specs/skills/adversarial-review/SKILL.md` and follow its instructions exactly.) > "%CMD_ROOT%\adversarial-review.md"
(echo Read the file `ai-specs/skills/explain/SKILL.md` and follow its instructions exactly.) > "%CMD_ROOT%\explain.md"
(echo Read the file `ai-specs/skills/show-spec-working/SKILL.md` and follow its instructions exactly.) > "%CMD_ROOT%\show-spec-working.md"
(echo Read the file `ai-specs/skills/code-auditing/SKILL.md` and follow its instructions exactly.) > "%CMD_ROOT%\code-auditing.md"
(echo Read the file `ai-specs/skills/using-git-worktrees/SKILL.md` and follow its instructions exactly.) > "%CMD_ROOT%\using-git-worktrees.md"
(echo Read the file `ai-specs/skills/writing-skills/SKILL.md` and follow its instructions exactly.) > "%CMD_ROOT%\writing-skills.md"
(echo Read the file `ai-specs/skills/meta-prompt/SKILL.md` and follow its instructions exactly.) > "%CMD_ROOT%\meta-prompt.md"
(echo Read the file `ai-specs/skills/sync-agent-symlinks/SKILL.md` and follow its instructions exactly.) > "%CMD_ROOT%\sync-agent-symlinks.md"
(echo Read the file `ai-specs/skills/openspec-sync-specs/SKILL.md` and follow its instructions exactly.) > "%CMD_ROOT%\openspec-sync-specs.md"

echo Generando archivos de comando en packages\specboot\template\.claude\commands\ ...

(echo Read the file `ai-specs/skills/setup-docs/SKILL.md` and follow its instructions exactly.) > "%TPL_CMD%\setup-docs.md"
(echo Read the file `ai-specs/skills/update-docs/SKILL.md` and follow its instructions exactly.) > "%TPL_CMD%\update-docs.md"
(echo Read the file `ai-specs/skills/commit/SKILL.md` and follow its instructions exactly.) > "%TPL_CMD%\commit.md"
(echo Read the file `ai-specs/skills/enrich-us/SKILL.md` and follow its instructions exactly.) > "%TPL_CMD%\enrich-us.md"
(echo Read the file `ai-specs/skills/adversarial-review/SKILL.md` and follow its instructions exactly.) > "%TPL_CMD%\adversarial-review.md"
(echo Read the file `ai-specs/skills/explain/SKILL.md` and follow its instructions exactly.) > "%TPL_CMD%\explain.md"
(echo Read the file `ai-specs/skills/show-spec-working/SKILL.md` and follow its instructions exactly.) > "%TPL_CMD%\show-spec-working.md"
(echo Read the file `ai-specs/skills/code-auditing/SKILL.md` and follow its instructions exactly.) > "%TPL_CMD%\code-auditing.md"
(echo Read the file `ai-specs/skills/using-git-worktrees/SKILL.md` and follow its instructions exactly.) > "%TPL_CMD%\using-git-worktrees.md"
(echo Read the file `ai-specs/skills/writing-skills/SKILL.md` and follow its instructions exactly.) > "%TPL_CMD%\writing-skills.md"
(echo Read the file `ai-specs/skills/meta-prompt/SKILL.md` and follow its instructions exactly.) > "%TPL_CMD%\meta-prompt.md"
(echo Read the file `ai-specs/skills/sync-agent-symlinks/SKILL.md` and follow its instructions exactly.) > "%TPL_CMD%\sync-agent-symlinks.md"

echo.
echo Listo. Comandos creados:
dir "%CMD_ROOT%" /B

echo.
echo Ahora podes commitear y pushear:
echo   git add .claude\commands packages\specboot\template\.claude\commands
echo   git commit -m "feat: add .claude/commands for Claude Code slash commands"
echo   git push origin main
echo.
pause
