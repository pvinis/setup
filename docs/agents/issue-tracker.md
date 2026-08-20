# Issue tracker: GitHub

Issues and specs for this repo live as GitHub issues. Use the `gh` CLI for all operations.

## Conventions

- **Create an issue**: `gh issue create --title "..." --body "..."`. Use a heredoc for multi-line bodies.
- **Read an issue**: `gh issue view <number> --comments`, filtering comments by `jq` and also fetching labels.
- **List issues**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'` with appropriate `--label` and `--state` filters.
- **Comment on an issue**: `gh issue comment <number> --body "..."`
- **Apply / remove labels**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Close**: `gh issue close <number> --comment "..."`

Infer the repo from `git remote -v`; `gh` does this automatically when run inside a clone.

## Pull requests as a triage surface

**PRs as a request surface: no.** _(Set to `yes` if this repo treats external PRs as feature requests; `/triage` reads this flag.)_

When set to `yes`, PRs run through the same labels and states as issues, using the `gh pr` equivalents:

- **Read a PR**: `gh pr view <number> --comments` and `gh pr diff <number>` for the diff.
- **List external PRs for triage**: `gh pr list --state open --json number,title,body,labels,author,authorAssociation,comments` then keep only `authorAssociation` of `CONTRIBUTOR`, `FIRST_TIME_CONTRIBUTOR`, or `NONE` (drop `OWNER`/`MEMBER`/`COLLABORATOR`).
- **Comment / label / close**: `gh pr comment`, `gh pr edit --add-label`/`--remove-label`, `gh pr close`.

GitHub shares one number space across issues and PRs, so a bare `#42` may be either: resolve with `gh pr view 42` and fall back to `gh issue view 42`.

## When a skill says "publish to the issue tracker"

Create a GitHub issue.

## When a skill says "fetch the relevant ticket"

Run `gh issue view <number> --comments`.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a single issue with **child** issues as tickets.

- **Map**: a single issue labelled `wayfinder:map`, holding the Notes / Decisions-so-far / Fog body. `gh issue create --label wayfinder:map`.
- **Child ticket**: an issue linked to the map as a GitHub sub-issue. Preferred (verified on `gh` 2.97): `gh issue edit <child> --parent <map>`, or `gh issue edit <map> --add-sub-issue <child>`. Older `gh`: `gh api` on the sub-issues endpoint. Where sub-issues aren't enabled, add the child to a task list in the map body and put `Part of #<map>` at the top of the child body. Labels: `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Once claimed, the ticket is assigned to the driving dev.
- **Blocking**: GitHub's **native issue dependencies**, the canonical, UI-visible representation. Preferred (verified on `gh` 2.97): `gh issue edit <child> --add-blocked-by <blocker>` — plain issue numbers, no database ids. Also `--add-blocking`, `--remove-blocked-by`, `--remove-blocking`. Older `gh`: `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`, where `<blocker-db-id>` is the blocker's numeric **database id** (`gh api repos/<owner>/<repo>/issues/<n> --jq .id`, _not_ the `#number` or `node_id`). Where dependencies aren't available at all, fall back to a `Blocked by: #<n>, #<n>` line at the top of the child body. A ticket is unblocked when every blocker is closed.
- **Frontier query**: list the map's open children (`gh issue view <map> --json subIssues`, or `gh issue list --state open` scoped to the map's task list), drop any with an open blocker or an assignee; first in map order wins. Preferred per-ticket check (verified on `gh` 2.97):

  ```bash
  gh issue view <n> --json number,title,state,assignees,blockedBy
  ```

  A ticket is on the frontier when `assignees` is empty and no node in `blockedBy` has `state: "OPEN"`. Both `subIssues` and `blockedBy` come back as `{nodes, totalCount}`, so index through `.nodes`. Whole frontier in one go:

  ```bash
  for n in $(gh issue view <map> --json subIssues \
      -q '.subIssues.nodes[] | select(.state=="OPEN") | .number'); do
    gh issue view $n --json number,title,assignees,blockedBy \
      -q 'select((.assignees|length)==0)
          | select([.blockedBy.nodes[] | select(.state=="OPEN")] | length == 0)
          | "\(.number)\t\(.title)"'
  done
  ```

  Older `gh`: `issue_dependencies_summary.blocked_by > 0` from the REST payload, or an open issue in the `Blocked by` body line.
- **Claim**: `gh issue edit <n> --add-assignee @me`, the session's first write.
- **Resolve**: `gh issue comment <n> --body "<answer>"`, then `gh issue close <n>`, then append a context pointer (gist + link) to the map's Decisions-so-far.
