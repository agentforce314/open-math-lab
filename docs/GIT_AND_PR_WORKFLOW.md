# Git + GitHub PR workflow (Open Math Lab)

**Remote SoT:** `https://github.com/agentforce314/open-math-lab` (fork of `Paul3435/open-math-lab`; PRs #1–#182 referenced in the ledger/catalog live upstream)  
**Local SoT:** `/Users/ericlee2/workspace/open-math-lab`  
**Default branch:** `main` (local and remote). Always open PRs against **this fork** — pass `--repo agentforce314/open-math-lab --base main`; never target the upstream repo.  
**Board merge authority:** the board (`agentforce314`) only (agents open PRs; agents do **not** merge to `main` unless a ticket explicitly says so).

## Why PRs

Paperclip agents produce multi-file sprints. PRs give the board a review surface, CI signal, and a clean history — without agents force-pushing `main`.

## When to open a PR (agents)

Open a PR when **any** of these hold:

1. **Sprint / issue close** — acceptance criteria met (or honest dead-end logged) and you would mark the Paperclip issue `done` or `in_review`.
2. **Coherent work package** — e.g. one attack directory + STATUS/LOG/RESULTS, or Lean install + BUILD_LOG, or catalog hygiene batch.
3. **Board asked for a PR** on the ticket.

Do **not** open a PR for:

- Empty or WIP thrash mid-attack (use the issue comment log instead).
- Secrets, credentials, `.env`, API keys.
- “We solved Millennium problem X” claim packets (use `mathforge claim prepare` + board only).
- Force-push or history rewrite on `main`.

## Branch naming

```text
ope/<id>-<short-slug>          # preferred — ties to Paperclip issue
sprint/<yyyy-mm-dd>-<slug>     # multi-issue sprint bundle
fix/<slug>
chore/<slug>
```

Examples: `ope/13-graceful-caterpillars`, `ope/17-lean-install`, `sprint/2026-07-31-hygiene`.

## Agent procedure (macOS / Linux shell)

Work only in the git SoT cwd (not Paperclip managed `_default` alone).

```bash
cd /Users/ericlee2/workspace/open-math-lab
git fetch origin
git checkout main
git pull origin main

git checkout -b ope/<id>-<slug>

# ... implement ...

# Verify before commit
python test_mathforge.py -v
python bin/mathforge status

git status
git add -A
# Never add: .env, secrets, .lake/, huge binaries

# Uses the repo's configured git identity (agentforce314) — do not override it.
git commit -m "$(cat <<'EOF'
type(scope): summary for OPE-N

- bullet outcomes
- how to verify
EOF
)"

git push -u origin HEAD

gh pr create --repo agentforce314/open-math-lab --base main --title "OPE-N: short title" --body "$(cat <<'EOF'
## Summary
- What changed (process / code / math artifacts)

## Paperclip
- Issue: OPE-N
- Agent role: Attack Lead | Scout | Formalist | Reviewer | Director

## Math honesty
- Claim status: none | informal | heuristic | Lean-checked (link build log)
- Residual risks: ...

## Test plan
- [ ] `python test_mathforge.py -v`
- [ ] `python bin/mathforge status`
- [ ] (if Lean) `lake build` in `proofs/lean-project` — paste exit code / point at BUILD_LOG

## Board
- [ ] Please review + merge if OK
- [ ] Do **not** treat this PR as external publication of a proof
EOF
)"
```

Then comment the **PR URL** on the Paperclip issue and set issue status appropriately (`in_review` if waiting on board/Reviewer).

## Director responsibilities

At sprint boundaries:

1. Ensure child issues either have a PR or an explicit “no code change” comment.
2. Prefer **one PR per issue** when possible; bundle only when files heavily overlap.
3. Never merge PRs as Director unless board ticket says merge is allowed.
4. Kill crackpot PRs: comment + close recommendation for board.

## Board

- Review at https://github.com/agentforce314/open-math-lab/pulls  
- Merge via GitHub UI or `gh pr merge --squash` when satisfied  
- External communication still gated by claim policy

## Auth for agents

Agents use the host `gh` login (`agentforce314`, scopes `repo` + `workflow`). `gh repo set-default agentforce314/open-math-lab` is set locally so `gh pr …` resolves to this fork, not upstream. If `gh auth status` fails, stop and comment on the issue — do not embed PATs in the repo.

## CI

Lightweight Python tests are defined in `docs/ci/github-actions-test.yml`. Copy to `.github/workflows/test.yml` when the board wants CI on the fork (the host `gh` token already has the **`workflow`** scope), then commit that path. Full Mathlib `lake build` stays local (OPE-17), not free GitHub runners.
