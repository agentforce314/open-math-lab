# Open Math Lab — mathforge

**GitHub:** https://github.com/agentforce314/open-math-lab (fork of [Paul3435/open-math-lab](https://github.com/Paul3435/open-math-lab); default branch `main`)  
**PR workflow for agents:** [`docs/GIT_AND_PR_WORKFLOW.md`](docs/GIT_AND_PR_WORKFLOW.md)

Personal multi-agent research lab (Paperclip company) that **builds and runs** `mathforge`: a local toolkit for selecting *tractable* open mathematical problems, attacking them with specialized agent skills, cross-reviewing claims, and recording machine-checkable progress.

## Honest mission

We do **not** claim Millennium-problem solutions out of the box. LLMs hallucinate proofs. The product’s job is:

1. **Feasibility-first problem selection** (formalizable, partial-progress friendly, budget-capped).
2. **Multi-perspective attack** (domain skill packs + independent reviewers).
3. **Machine check when possible** (Lean 4 / Mathlib); otherwise clearly labeled *heuristic / informal*.
4. **Scientific logging of failures** as first-class output.
5. **Human board gate** before any public “we solved X” claim.

## Repo layout

| Path | Purpose |
|------|---------|
| `bin/mathforge` | CLI entry |
| `src/` | Implementation |
| `catalog/` | Problem index + scores |
| `problems/<id>/` | Statement, sources, feasibility dossier |
| `attacks/<id>/` | Attempt logs, strategies, dead ends |
| `proofs/<id>/` | Lean / informal writeups |
| `skills/` | Domain skill packs (number theory, combinatorics, …) |
| `docs/` | ADRs, pipeline, claim policy |

## CLI (v1 target)

```bash
mathforge catalog refresh     # pull/curate candidate open problems
mathforge score <id>          # feasibility + risk + budget estimate
mathforge problem new …       # scaffold problem dossier
mathforge attack start <id>   # open attack log
mathforge review <id>         # adversarial checklist
mathforge claim prepare <id>  # board packet only — never auto-publish
mathforge status              # portfolio dashboard
```

## Hard constraints

- Work only in this repository unless a ticket says otherwise.
- No secrets in git; no external “solved” announcements without board approval.
- Prefer Lean-checked artifacts; mark informal claims explicitly.
- Cap token/budget burn per attack; stop and write a failure report when stuck.
- One wake at a time on shared Claude subscription unless board raises concurrency.

## Paperclip org (v1)

```
You (Board)
 └── Research Director — portfolio, refuse crackpottery, ticket split
      ├── Problem Scout — catalogs, literature, feasibility scoring
      ├── Formalist — Lean statements, verification harness
      ├── Attack Lead — strategy + domain skill packs
      └── Adversarial Reviewer — break claims; block false “done”
```

## License / privacy

Personal lab. Not a prize claim factory.
