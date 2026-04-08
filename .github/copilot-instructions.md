# Copilot Instructions — terraform-module-aws-health

## Team

This repository is owned by the *Engineering* team at GeoMaps. [AWS Organization Link](https://geomaps.awsapps.com/start/#/).

## About This Repository

Reusable Terraform module for AWS Health event alerts via EventBridge rules and SNS targets. Consumed by [terragrunt-live-aws](https://github.com/Hopper-Tec/terragrunt-live-aws) via module source.

*Primary stack:* Terraform.

### Submodules

- **modules/health-event-rule** — Creates an EventBridge rule for AWS Health events with configurable targets (SNS, Lambda, etc.).

## Coding Principles

- *Least privilege* — every IAM role, policy, and security group must grant only the minimum permissions required. Never use `*` in resource ARNs unless absolutely necessary and documented.
- *Encryption everywhere* — all data at rest must use KMS (prefer CMK over AWS-managed keys). All data in transit must use TLS 1.2+.
- *No secrets in code* — never hardcode credentials, tokens, API keys, or connection strings. Use AWS Secrets Manager or SSM Parameter Store.
- *Tagging is mandatory* — every AWS resource must include at minimum the required tags: `team`, `product`, `managed_by`. Pass tags through a `tags` variable; never hardcode tag values.
- *Account IDs* — never hardcode account IDs in code. Use `data.aws_caller_identity.current.account_id` or variables.

## Implementation Standards

### Naming

- Resource names use `this` when there is a single resource of that type (e.g., `aws_cloudwatch_event_rule.this`).
- Variables and outputs use snake_case.
- Module directories use kebab-case.

### Formatting

- Use `terraform fmt` canonical style.
- Align `=` signs within blocks for readability.
- One blank line between top-level blocks.

### Variables (`variables.tf`)

- Always include `description`, `type`, and `default` (when optional).
- Use `validation` blocks for input constraints.
- Mark required variables with `(Required)` and optional with `(Optional)` in descriptions.

### Outputs (`outputs.tf`)

- Prefix output names with the resource type (e.g., `cloudwatch_event_rule_arn`).
- Always include `description`.

### Versions (`versions.tf`)

- `required_version = ">= 1.10.0"`
- AWS provider `>= 6.0.0`

### Examples (`examples/`)

- One directory per module under `examples/`.
- Each example must contain `main.tf` with a working, minimal usage of the module.

## Review Standards

### PR Checklist

- [ ] `terraform fmt` passes.
- [ ] `terraform validate` passes.
- [ ] All variables have descriptions and types.
- [ ] All outputs have descriptions.
- [ ] `versions.tf` present with correct constraints.
- [ ] `README.md` updated.
- [ ] Example added/updated under `examples/`.

### Acceptance Criteria

- Module is self-contained (no cross-module dependencies unless explicit).
- Inputs validated where applicable.
- Outputs expose all useful resource attributes.

## Git Conventions

### Branches

- `feat/<description>` — new features or submodules
- `fix/<description>` — bug fixes
- `chore/<description>` — maintenance, docs, CI

### Commits

- Use [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`
- Allowed types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `style`, `ci`.
- Write commit messages in English.

### Pull Requests

- PR description must explain *what* changed and *why*.
- One logical change per PR — do not bundle unrelated changes.
- All conversations must be resolved before merge.
- Squash merge to main.

## Conversation Language

Copilot must always respond in **Brazilian Portuguese (pt-BR)**. All explanations, questions, summaries, and messages to the user must be in Portuguese.

## Code Language

All code must be written in **American English (en-US)**:

- Variable names, resource names, and constants in English.
- Code comments in English.
- File and directory names in English.

PR review comments are in Brazilian Portuguese — the code itself must always be in English.
