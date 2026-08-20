# AGENTS.md

Notes for agents working **on this repo**.

The *runbook* entry point — what an agent reads when it lands on a fresh machine and starts setting it up — is a separate and still-open question. Don't assume it's this file: see [How does an agent discover and enter the runbook?](https://github.com/pvinis/setup/issues/7).

## Agent skills

### Issue tracker

GitHub Issues on `pvinis/setup`, via the `gh` CLI. The `/wayfinder` map and its tickets live there too. See `docs/agents/issue-tracker.md`.

### Triage labels

The five canonical triage roles, default label names unchanged. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` and `docs/adr/` at the repo root. Neither exists yet; `/domain-modeling` creates them lazily. See `docs/agents/domain.md`.
