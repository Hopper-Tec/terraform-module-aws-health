# Code Review Guidelines

These instructions apply to *all pull request reviews* in this repository, regardless of file type. For language-specific review checklists, see:

- .github/instructions/copilot-review-instructions-terraform.md
- .github/instructions/copilot-review-instructions-python.md

## Review Response Language

Always respond in *Brazilian Portuguese* (pt-BR) when reviewing PRs.

## Severity Levels

Classify every finding using one of three severity levels:

| Level | Label | Merge Impact |
|---|---|---|
| *Blocking* | 🔴 [Blocking] | PR must *not* be merged until resolved |
| *Warning* | 🟡 [Warning] | Should be fixed but does not block merge |
| *Info* | 🟢 [Info] | Suggestion for improvement — optional |

*Default to Blocking* when in doubt. It is safer to over-flag than to miss a real issue.

## Review Checklist (All PRs)

### Commit & PR Quality

- [ ] PR title includes Jira ticket (CPLAT-XXXX description).
- [ ] PR description explains *what* changed and *why*.
- [ ] Commits follow Conventional Commits format with Jira prefix.
- [ ] No unrelated changes bundled in the same PR.
- [ ] No merge commits — squash merge only.

### Security (Blocking)

- [ ] No secrets, tokens, API keys, or passwords in code, comments, or commit messages.
- [ ] No hardcoded AWS account IDs — use data.aws_caller_identity.current.account_id or variables.
- [ ] IAM policies follow least privilege — no Action: "*" or Resource: "*" without explicit justification.
- [ ] Sensitive data is never logged (account keys, PII, tokens).
- [ ] No eval(), exec(), pickle.loads(), or equivalent dynamic code execution on untrusted input.

### Code Quality

- [ ] No dead code (commented-out blocks, _old/_backup files, unreachable branches).
- [ ] No duplicate logic — shared patterns should be extracted to modules/functions.
- [ ] Error handling exists for all operations that can fail.
- [ ] Variable and function names are descriptive and follow the repository's naming conventions.
- [ ] No TODO/FIXME/HACK comments without a linked Jira ticket.

### Infrastructure (Blocking)

- [ ] All AWS resources include the required tags: bu, squad, managed_by — no resource is missing any of these three.
- [ ] Encryption at rest is enabled (S3, DynamoDB, EBS, RDS, CloudWatch Logs, SNS, SQS).
- [ ] Lambda functions use arm64 architecture.
- [ ] Lambda functions have explicit timeout values.
- [ ] Lambda functions in VPC have VPC endpoints for AWS services they call.
- [ ] No public access to resources unless explicitly required and documented.

### Destructive Changes (Blocking)

- [ ] Flag any operation that destroys or replaces existing resources — require explicit justification.
- [ ] Resources with prevent_destroy = true must not have that protection removed without discussion.
- [ ] State operations (import, moved, removed) are reviewed for correctness and safety.

## Cross-Language Anti-Patterns (Always Flag)

- *Secrets in code or logs* — API keys, tokens, passwords, connection strings hardcoded or printed. Always blocking.
- *Dead code* — files or blocks with _old, _backup, _deprecated suffixes, commented-out code spanning more than 5 lines, unreachable logic. Flag for removal.
- *Missing error handling* — operations that can fail (API calls, file I/O, network requests) without try/catch or error checks.
- *Vendored dependencies in Git* — Lambda layers, Python packages, or Node modules committed to the repository. Must be built in CI/CD.
- *Inconsistent naming* — mixing camelCase, snake_case, and kebab-case within the same scope or file type.
- *Large undocumented changes* — PRs with 500+ lines and no description, no context, no linked Jira ticket.

## How to Write Review Comments

1. *State the severity* — start every comment with [Blocking], [Warning], or [Info].
2. *Be specific* — point to the exact line, explain the problem, show the impact.
3. *Suggest the fix* — include corrected code when possible. "This is wrong" without a fix is not helpful.
4. *Keep it short* — one issue per comment. No walls of text.
5. *Be constructive* — review the code, not the person. Focus on outcomes.

## Approval Criteria

- *Approve* only when all Blocking items are resolved and the change is safe to deploy.
- *Request changes* when any Blocking item is open.
- When ADRs exist (in ./adr), verify changes comply with them.
