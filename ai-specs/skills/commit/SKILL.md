---
name: commit
description: Crear commits y pull requests enfocados siguiendo los estándares del repositorio.
author: LIDR.co
version: 1.0.0
---
# Skill commit

Usalo cuando este flujo de trabajo sea requerido en el proyecto.

## Instrucciones

# Rol

Sos un experto en control de versiones y flujos de release. Creás commits y Pull Requests claros y completos que se alinean con los estándares del proyecto y facilitan la revisión y la trazabilidad.

# Argumentos

**Opcional.** `$ARGUMENTS` puede contener:

- **Nada (vacío)**: Agregar al stage y commitear todos los cambios relevantes en el working tree, y luego abrir un único PR.
- **Identificadores de feature/ticket**: por ejemplo IDs de ticket (ej. `SCRUM-123`), nombres de branch, o etiquetas cortas de feature. Cuando se proporcionen, agregar al stage y hacer PR **solo** de los cambios que pertenezcan a esas features; dejar todos los demás cambios sin stage y sin commitear.
- **Modo solo-descripción / sin git**: Si el usuario dice **explícitamente** algo como "sin PR", "solo commit" (es decir, solo producir el texto del commit), "solo descripción", "no toques git", "solo el mensaje", o "dry run", entonces **no** ejecutes ningún comando de git ni crees un PR. Solo determiná el alcance, listá qué se agregaría al stage, y devolvé el mensaje de commit propuesto (subject + body). El usuario puede copiar y ejecutar los comandos de git por su cuenta.

# Objetivo

1. Producir un **único commit completo** que describa con precisión los cambios relevantes.
2. **Pushear** el branch y **crear (o actualizar) un Pull Request** para revisión.
3. Si se proporcionaron argumentos: **agregar al stage y commitear solo** los cambios vinculados a esas features; no tocar otros archivos modificados.

# Proceso y reglas

## 0. Modo solo-descripción / sin git (verificar primero)

Si el usuario solicitó **explícitamente** no realizar operaciones de git (ej. "sin PR", "solo commit", "solo descripción", "no toques git", "solo el mensaje", "dry run"):

- Realizá **solo** los pasos 1–3: inspeccionar el estado, resolver el alcance (qué archivos/hunks se agregarían al stage), y escribir el mensaje de commit completo (subject + body).
- **No** ejecutes `git add`, `git commit`, `git push`, ni `gh pr create`. No modifiques el repositorio de ninguna manera.
- Salida para el usuario:
  1. Lista de archivos (y hunks, si es parcial) que se agregarían al stage.
  2. El mensaje de commit propuesto en un bloque listo para copiar y pegar.
- Luego detenete; omití los pasos 4, 5 y 6.

## 1. Inspeccionar el estado actual

- Ejecutá `git status` y `git diff` (y `git diff --staged` si hace falta) para listar todos los archivos modificados, agregados y eliminados.
- Identificá el branch actual. Si no estás en un branch de feature, decidí si crear uno a partir del branch base (ej. `main` o `develop`) antes de commitear.

## 2. Resolver el alcance: commit completo vs commit acotado a la feature

- **Si `$ARGUMENTS` está vacío o no se proporciona**
  - Tratá todos los cambios relevantes (excluyendo archivos que no deberían commitearse, ej. `.env`, artefactos de build, configuración local) como el alcance de este commit.
  - Agregá todos esos al stage y continuá con el paso 3.

- **Si se proporciona `$ARGUMENTS` (ej. IDs de ticket o nombres de feature)**
  - Mapeá cada argumento a los cambios que claramente le pertenecen (por ruta, ID de ticket en el nombre del branch, o contexto en los diffs).
  - Agregá al stage **solo** los archivos/hunks que pertenezcan a esas features.
  - Dejá cualquier otro archivo modificado **sin stage** y no lo incluyas en el commit.
  - Si un archivo contiene tanto cambios relacionados con la feature como cambios no relacionados, usá `git add -p` (o equivalente) para agregar al stage solo los hunks que pertenezcan a las features solicitadas.
  - Si ningún cambio coincide claramente con los argumentos dados, reportá esto y no commitees.

## 3. Mensaje de commit

- Escribí el mensaje de commit **en inglés** (según `docs/base-standards.md`).
- Hacelo **descriptivo** (según el Git Workflow en `backend-standards.md` y `frontend-standards.md`).
- Estructuralo de modo que:
  - **Línea de subject**: Resumen corto e imperativo (ej. "Add candidate filters to position list", "Fix validation for application deadline"). Opcionalmente con un prefijo de scope o ID de ticket (ej. `SCRUM-123: Add candidate filters`).
  - **Body** (si hace falta): Bullets o párrafos cortos describiendo qué cambió y por qué (áreas tocadas, nuevo comportamiento, correcciones). Referenciá los IDs de ticket acá si aplican.
- No commitees secretos, `.env`, u otros artefactos sensibles o generados.

## 4. Commit y push

- Creá el commit con el mensaje del paso 3.
- Pusheá el branch actual al remoto (`git push origin <branch>`). Si el branch no existe en el remoto, pusheá con `-u` para configurar el upstream.

## 5. Pull Request

- Usá la **GitHub CLI (`gh`)** para todas las operaciones de GitHub (según los estándares del repositorio).
- Creá o actualizá el PR para el branch actual:
  - **Título**: Claro, alineado con el commit (ej. incluí el ID de ticket si aplica: `[SCRUM-123] Add candidate filters to position list`).
  - **Descripción**: Resumí el conjunto de cambios, enlazá al ticket si es relevante, y anotá cualquier testing o seguimiento pendiente.
- Si el repo usa protección de branch o checks requeridos, mencioná que el PR está listo para revisión una vez que los checks pasen.

## 6. Resumen para el usuario

- Reportá qué se commiteó (archivos y alcance).
- Si se proporcionaron argumentos: confirmá qué features/tickets se incluyeron y que los demás cambios quedaron sin stage.
- Proporcioná la URL del PR (de la salida de `gh`).

# Referencias

- `docs/base-standards.md`: Solo inglés para mensajes de commit y artefactos técnicos.
- `docs/backend-standards.md` y `docs/frontend-standards.md`: Git Workflow (branches de feature, commits descriptivos, branches pequeños y enfocados).
- Convenciones de git workflow del repositorio: Usar `gh` para GitHub y la creación de PRs; vinculación opcional de branch y PR basada en ticket.

# Notas

- **Solo descripción**: Cuando el usuario pida sin PR o solo el texto del commit, devolvé solo el plan de stage y el mensaje; no ejecutes ningún comando de git ni de `gh`.
- No ejecutes comandos de git destructivos (ej. `git push --force` sin solicitud explícita del usuario).
- Si hay conflictos o el push es rechazado, reportá la situación y sugerí próximos pasos (ej. pull/rebase y luego push), pero no hagas force-push a menos que el usuario lo pida.
- Cuando se proporcionan argumentos, **solo** los cambios vinculados a esas features se agregan al stage y se commitean; todo lo demás permanece en el working tree para un commit o PR separado.
