---
name: show-spec-working
description: Use when the user asks "show me X", "demo X", "walk me through X", "how X works", or requests a live demonstration of a feature based on a spec, feature, or ticket.
author: LIDR.co
version: 1.0.0
---

# show-spec-working Skill

Demonstrate a spec in an executable way.

If the user doesn't provide explicit context, use the spec/change currently being worked on in this session.

Always finish by reporting completion in the chat.

## Trigger phrases (high priority)

Treat these expressions as execution commands, not analysis requests:

- `show me X`
- `demo X`
- `walk me through X`
- `show X working`
- `how X works`
- `prove X works`

When any of these appear, run the demonstration flow directly.
Don't stop at a feature summary or a quick report.

## Inputs

- Optional spec context from the user:
  - Direct ticket id in the text (e.g. `SCRUM-10`)
  - Feature name
  - Endpoint
  - Frontend route
- If missing, infer it from the current session context and the active work in progress.

## Workflow

### Step 1 - Resolve the target spec and scope

1. Identify the target spec/change:
   - Prefer explicit context provided by the user.
   - If the user's text contains a ticket id pattern like `[A-Z]+-[0-9]+`, use it as the primary context (example: `show me SCRUM-10`).
   - Otherwise, infer the spec currently being worked on.
2. Determine the modality:
   - `frontend` when the spec includes UI behavior.
   - `backend-only` when it only defines API behavior.
   - `mixed` when both exist.
3. List concrete scenarios to demonstrate based on the spec's acceptance criteria.

### Step 1.1 - Anti-report safety rule

Before continuing, apply this rule:

- Never finish after only analyzing the requirements.
- Never return only a quick report when the user asked to "show" or "demo" something.
- If execution is blocked, explicitly report the blocker and ask for exactly what's needed to continue the live demo.

### Step 2 - Frontend demonstration path

Run this path when the modality is `frontend` or `mixed`.

1. Start the required local services if needed.
2. Use browser automation to open the app and navigate to the target feature.
3. Demonstrate the feature's behavior based on the spec, one interaction at a time.
   - Example sequence for list/table features:
     - Open the list page
     - Verify the table data appears
     - Use the search box
     - Apply filters
     - Change the sort order
     - Open the detail view
4. After each significant action:
   - Verify the visible result matches the spec's expectations.
5. Stop at a stable final state and let the user continue manual exploration or close the window.
6. Keep the browser open unless the user asks to close it.

### Step 3 - Backend API demonstration path

Run this path when the modality is `backend-only` or `mixed`.

1. Identify the endpoint(s) and example payload(s) defined by the spec.
2. Run the curl command(s) that show the actual response behavior.
3. If any call changes data state (CREATE/UPDATE/DELETE):
   - Run the corresponding restore/reset curl command (or equivalent restore action) immediately after demonstrating the behavior.
4. Confirm the restored state so repeated demos stay deterministic.
5. Include the command and the key response evidence in the chat (concisely).

## Browser MCP requirements

Before calling any browser MCP tool:

1. Read the MCP tool's JSON descriptor first.
2. Follow the server's instructions for the lock/unlock flow and snapshot updates.
3. Avoid blind repeated retries; if blocked, report the blocker and the best next action.

## API demo requirements

- Use explicit `curl` commands (not pseudocode) whenever environment data is available.
- Mask sensitive values in the chat output.
- Keep commands idempotent when possible.
- Include restore commands for any state-changing operation.

## Completion contract

Always send a final chat message containing:

1. Target spec/change demonstrated.
2. What was executed:
   - Frontend flows shown.
   - Backend curl commands run.
3. Verification result for each demonstrated scenario (pass/fail with a brief note).
4. Data restoration status (if applicable).
5. Final closing line:
   - "Demo complete. You can keep exploring in the open browser window or ask me to close it."

## Output format

Use this concise structure in the final chat response:

```markdown
Spec demo completed for: <spec/change>

Frontend walkthrough:
- <step/result>

Backend API walkthrough:
- <curl + key response note>

Data restoration:
- <restored / not needed / failed + reason>

Next:
- You can keep exploring in the open browser window, or ask me to close it.
```
