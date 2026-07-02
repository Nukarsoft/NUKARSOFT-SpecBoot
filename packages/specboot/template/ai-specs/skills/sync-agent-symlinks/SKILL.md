---
name: sync-agent-symlinks
description: Analyzes and syncs agent skill exposure after changes to ai-specs skills (additions, removals, renames). Use when skills are added/removed under ai-specs and .claude/skills and .cursor/skills need to stay aligned via symlinks.
author: LIDR.co
version: 1.0.0
---

# sync-agent-symlinks Skill

Keeps the agent-facing skill structures in sync with `ai-specs/skills` as the canonical source.

Use this skill after any change under `ai-specs/skills` (new skill, removed skill, renamed or moved skill), especially when you need to avoid stale or broken symlinks.

## Scope and safety rules

- The canonical source is `ai-specs/skills`.
- The mirror destinations are:
  - `.claude/skills`
  - `.cursor/skills`
- Only manage entries that are symlinks pointing to `../../ai-specs/skills/<skill-name>`.
- Don't remove non-symlink directories in the mirror destinations unless the user explicitly asks for it.
- Never silently overwrite a real directory; report it as a conflict.

## Workflow

### Step 1 - Build inventories

Gather three inventories:

1. Canonical skills from `ai-specs/skills/*/SKILL.md`
2. Mirror entries in `.claude/skills`
3. Mirror entries in `.cursor/skills`

From the mirror entries, classify each as:
- `linked`: valid symlink pointing to an existing canonical skill
- `broken`: the symlink target is missing
- `orphan`: the symlink points into the canonical namespace but the skill no longer exists
- `conflict`: a non-symlink entry with the same name as a canonical skill
- `external`: an entry not managed by the canonical symlink policy (leave unchanged)

### Step 2 - Compute the sync plan

For each mirror destination:

- `to_add`: canonical skills missing from the mirror destination
- `to_fix`: broken canonical symlinks that need to be recreated
- `to_remove`: orphaned canonical symlinks with no canonical source
- `to_skip`: conflicts and external entries (report only)

### Step 3 - Apply the sync safely

Apply changes in this order:

1. Add missing symlinks:
   - `<mirror>/<skill-name> -> ../../ai-specs/skills/<skill-name>`
2. Fix broken canonical symlinks:
   - Remove the broken link and recreate the same canonical link
3. Remove orphaned canonical symlinks:
   - Remove the symlink only if it points into the canonical namespace and the skill no longer exists

Never remove:
- non-symlink directories
- files not covered by the canonical symlink policy

### Step 4 - Verify integrity

After the changes:

- Confirm every canonical skill exists in both mirror destinations as a valid symlink, or is explicitly listed as a conflict.
- Confirm no canonical symlinks remain broken.
- Confirm external entries remain untouched.

### Step 5 - Report results

Return a concise sync report:

- Number of canonical skills
- Per mirror destination:
  - added
  - fixed
  - removed
  - conflicts
  - external entries skipped
- Any pending blockers

## Add/remove scenarios

### Scenario A - New skill added to ai-specs

Expected behavior:
- Add the missing symlink in `.claude/skills`
- Add the missing symlink in `.cursor/skills`
- Verify both links resolve to the canonical folder

### Scenario B - Skill removed from ai-specs

Expected behavior:
- Remove the orphaned canonical symlink from `.claude/skills`
- Remove the orphaned canonical symlink from `.cursor/skills`
- Leave non-canonical directories untouched and report them

## Command patterns (reference)

Use equivalent commands for your environment:

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

## Red flags

Never:
- treat `ai-specs` as non-canonical
- automatically remove real directories in the mirror destinations
- leave broken canonical symlinks after syncing
- silently skip conflicts without reporting them

Always:
- analyze before changing
- apply minimal, safe changes
- preserve non-canonical entries
- provide a final sync report with any pending blockers
