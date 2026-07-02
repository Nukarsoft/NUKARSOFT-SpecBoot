---
name: setup-docs
description: Analyze the project's real code and customize all of docs/ content (stack, architecture, domain, API, data model), replacing the generic reference material shipped with specboot.
author: LIDR.co
version: 1.0.0
---
# setup-docs Skill

Use it when this workflow is required in the project, typically right after importing specboot into a new project (step 3 "Customize `docs/` for Your Project" of `README.md`) or when the project's code has progressed enough that `docs/` is now out of date with the real stack, architecture, or domain.

## Instructions

### Step 1 — Detect whether `docs/` is still generic or already customized

Before touching any file, read `docs/base-standards.md`, `docs/backend-standards.md`, `docs/frontend-standards.md`, `docs/documentation-standards.md`, `docs/data-model.md`, `docs/api-spec.yml`, and `docs/development_guide.md`, and look for signs that they are still the generic reference material shipped with specboot by default:

- Mentions of the reference domain "LTI" under any of its variants (Leadership. Technology. Impact / Learning Tracking Initiative / Learning Technology Initiative) or of the example ATS/recruiting domain (Candidate, Position, Interview, Application).
- An example stack described ("Node.js/TypeScript/Express", generic React frontend, reference DDD) that doesn't match what you'll detect in Step 2.
- Any phrase that identifies itself as example/template material (e.g. what `README.md` describes as "Reference Examples (from LIDR Project)").

**If you find these signs** → `docs/` is still the unmodified generic material. Go straight to Step 2 without asking anything.

**If you don't find them** (the domain, stack, or entities already reflect a project different from the reference one) → `docs/` was already customized in a previous run. Before overwriting anything, explicitly ask the user whether they want you to update the existing content to reflect the current state of the code, or keep it as is:
- **Update**: continue with the rest of the flow, using the current content of `docs/` as the base to refresh (preserve prior customization decisions that the current code doesn't contradict; don't treat them as the generic mold to discard entirely).
- **Keep**: don't modify any file in `docs/`. Report that no changes were made and stop here.

### Step 2 — Analyze the real project

Gather real evidence from the code, without assuming anything based on the generic content:

- Dependency manifests: `package.json` (root and each workspace/package), or the equivalent for whatever ecosystem is in use (`requirements.txt`/`pyproject.toml`, `go.mod`, etc.).
- Real folder structure (monorepo vs. single app, backend/frontend/packages separation, layer-based or domain-based organization).
- Backend and frontend framework(s), ORM/query builder, database engine, testing framework, linter/formatter in use.
- Existing endpoints/routes (controllers, routers, OpenAPI/GraphQL schemas if any already exist) to infer the real API.
- Real data models/entities (entities, schemas, migrations, Prisma/TypeORM/Sequelize/etc. models) to infer the real data model.
- `package.json` scripts, Dockerfiles, `docker-compose`, CI configuration, to infer the real setup/development guide.
- Any existing README or project documentation that explains the business domain.

From this evidence, infer: **tech stack**, **architecture patterns** (DDD, layered architecture, monolith/microservices, etc.), and **real business domain** (what problem the project solves and what its main entities are).

If the project is empty or in a very early state (no application code yet), say so explicitly in the final summary (Step 7) and generate the documents with the best available inference (project name, README, dependencies already declared), leaving clear notes about what was left as an assumption for the team to validate.

### Step 3 — Confirm the GitHub repository (for merge and deploy)

Detect whether the project already has a git remote configured:

```bash
git remote get-url origin 2>/dev/null
```

- **If it returns a URL**: confirm it with the user (e.g. "I detected that the `origin` remote points to `<url>`. Is that the GitHub repository I should use to push, open PRs, and deploy?"). If confirmed, use that URL/path (`owner/repo`) for the rest of the flow.
- **If there's no remote configured, or the user corrects it**: ask explicitly:
  - Will the project live on GitHub? If so, what's the path (`owner/repo` or full clone URL)?
  - Does the repo not exist yet (new project without a remote yet)? Note it as pending instead of inventing it.
  - Will the project not use GitHub (local-only repo, or another provider like GitLab/Bitbucket)? Note that decision too — never assume GitHub by default.
- Never invent or assume a GitHub path: if the user doesn't have it yet, mark it explicitly as "pending definition" in `development_guide.md` instead of silently leaving the example placeholder (`git@github.com:your-org/your-project.git`) unflagged.

This confirmation determines which clone URL and which base branch convention (e.g. `main`, `develop`) go into `development_guide.md`, and it's the information that workflows like the `commit` skill later use to push, open PRs, and, if the project requires it, deploy.

### Step 4 — Rewrite each document in `docs/`

Keep exactly the same set of files and names; don't add or remove files from `docs/`:

- `docs/base-standards.md`
- `docs/backend-standards.md`
- `docs/frontend-standards.md`
- `docs/documentation-standards.md`
- `docs/api-spec.yml`
- `docs/data-model.md`
- `docs/development_guide.md`

For each one, replace the generic reference content (example stack, ATS/LTI domain, Candidate/Position/Interview entities, etc.) with the real context detected in Step 2, preserving the structure and purpose of each document:

- **`base-standards.md`**: keep the general principles (small tasks, TDD, typing, clear names, etc.) and the links to the other documents; update any reference to the example stack/domain and rewrite the language standards section per [Step 5](#step-5--language-rules).
- **`backend-standards.md`** / **`frontend-standards.md`**: update tech stack, architecture patterns, folder structure, testing conventions, and the `globs` frontmatter so they point to the project's real paths.
- **`api-spec.yml`**: replace title, description, paths, and example schemas with the real endpoints and models detected; if the project doesn't yet expose an API, leave a minimal valid skeleton and an explicit note that it's pending completion.
- **`data-model.md`**: replace the example entities with the real detected entities/tables (fields, relationships, entity-relationship diagram if applicable).
- **`development_guide.md`**: replace the example installation/run steps with the project's real ones (package manager, scripts, environment variables, Docker, database, test commands, etc.), including the example `git clone` command (`your-org/your-project`), which must be replaced with the real URL confirmed in [Step 3](#step-3--confirm-the-github-repository-for-merge-and-deploy) (or left marked as pending if the user doesn't have one yet).
- **`documentation-standards.md`**: keep the documentation maintenance process (what to update and when), adjusting only the language rule per [Step 5](#step-5--language-rules).

### Step 5 — Language rules

- Write all `docs/` prose (explanations, descriptions, guides) **in English**.
- Keep technical identifiers and literal artifacts as they are in the codebase: code snippets and examples, field/endpoint/schema names in `api-spec.yml`, identifiers and entity/field names in `data-model.md`, variable/function/terminal command names, and any snippet embedded in the `*-standards.md` files.
- Explicitly update the language standards section in `base-standards.md` and the equivalent rule in `documentation-standards.md` so they consistently state the project's chosen language policy for prose and technical artifacts, rather than leaving stale wording from a different policy.

### Step 6 — Consistency across documents

- Use the same domain terminology (entity names, roles, business processes) across all documents.
- Use the same stack, versions, and tool names in `base-standards.md`, `backend-standards.md`, `frontend-standards.md`, and `development_guide.md`.
- Verify that the entities and fields in `data-model.md` match the schemas used in `api-spec.yml`.
- Verify that relative links between documents (e.g. the ones in `base-standards.md`) still point to the correct files.

### Step 7 — Final summary

When done, show the user a concise summary with:

- **Detected**: tech stack, architecture patterns, and business domain inferred in Step 2 (including what was left as an assumption if the project was empty or incomplete).
- **GitHub repository**: the path confirmed in Step 3, or that it was left marked as pending definition.
- **Modified files**: list of the `docs/` files that were rewritten.
- If the user chose "Keep" in Step 1, state that instead of the detection summary and confirm nothing was modified.

## Notes

- Never add or remove files from `docs/`: the set of documents and their names is fixed.
- Don't invent stack, endpoints, or entities that aren't backed by real evidence from the code; if something can't be inferred with confidence, leave it marked as pending completion by the team instead of inventing it.
- This skill doesn't touch `ai-specs/agents` or `ai-specs/skills`; if agents or skills also need to be adapted to the real domain, treat that as a separate step (see the "Adapting to Your Project" section of `README.md`).
