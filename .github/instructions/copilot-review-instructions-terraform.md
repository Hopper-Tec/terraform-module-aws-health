---
applyTo: "{*/.tf,*/.tfvars,*/.hcl,*/.json}"
---

# Terraform Pull Request Review Instructions

When reviewing pull requests in this repository, enforce the following rules. Flag violations as blocking comments. Respond in *Brazilian Portuguese* (pt-BR).

## Formatting & Syntax (Blocking)

- [ ] All .tf and .tfvars files are formatted with terraform fmt (canonical 2-space indentation, aligned =).
- [ ] All configurations pass terraform validate — no syntax errors, invalid attributes, or type mismatches.
- [ ] Files end with exactly one newline. No trailing whitespace. LF line endings only (no CRLF).
- [ ] YAML files have valid syntax.
- [ ] No files larger than 300 KB are introduced.
- [ ] No merge conflict markers (<<<<<<<, =======, >>>>>>>) present.

## Variable & Output Quality (Blocking)

- [ ] Every variable block has a type constraint. Untyped variables must be flagged.
- [ ] Every variable block has a non-empty description.
- [ ] Every output block has a non-empty description.
- [ ] Variable arguments follow the standard order: description → type → default → nullable → validation.
- [ ] Output arguments follow the standard order: description → value → sensitive.
- [ ] No unused variable, data, locals, or provider alias declarations exist. If a declaration is not referenced anywhere, it must be removed.

## Naming & Style (Blocking)

- [ ] All identifiers (resources, variables, outputs, locals, modules, data sources) use snake_case. Flag camelCase, PascalCase, or kebab-case.
- [ ] Resource names do not repeat the resource type (e.g. aws_route_table "public" not aws_route_table "public_route_table").
- [ ] Singleton resources in a module use this as the name. Flag arbitrary names like main, default, or test for single-instance resources.
- [ ] Comments use # syntax only. Flag // and /* */ comments.
- [ ] No redundant interpolation — "${var.x}" must be var.x when it is the entire expression. When combining expressions, prefer format("prefix-%s-suffix", var.name) over "prefix-${var.name}-suffix".
- [ ] No legacy dot-index syntax — list.0 must be list[0], list.*.attr must be list[*].attr.

## Module Sources (Blocking)

- [ ] All Git/Mercurial module sources are pinned to a specific version tag or commit SHA. References to main, master, or default branches are not acceptable.
- [ ] Registry module sources specify a version constraint.

## Provider & Terraform Version (Blocking)

- [ ] All providers are declared in required_providers with explicit source and version.
- [ ] The AWS provider version must be >= 6.0, < 7.0. Flag any constraint below 6.0 or without an upper bound.
- [ ] Root modules declare required_version in the terraform {} block.
- [ ] The Terraform required_version must be >= 1.14.0. Flag any constraint that allows versions below 1.14.0.
- [ ] terraform.workspace is not used with a remote backend (returns "default" in Terraform v1.0.x remote execution).

## Module Structure (Warning)

- [ ] Modules follow the Standard Module Structure: main.tf, variables.tf, outputs.tf at minimum.
- [ ] Variable declarations are in variables.tf, output declarations are in outputs.tf — not scattered in other files.

## Documentation (Blocking)

- [ ] README.md is present and auto-generated content between <!-- BEGIN_TF_DOCS --> and <!-- END_TF_DOCS --> markers is up to date.
- [ ] No manual edits inside the terraform-docs marker block.

## Security (Blocking)

- [ ] No hardcoded secrets (passwords, tokens, API keys, connection strings) in any file.
- [ ] Secrets are retrieved from AWS Secrets Manager (aws_secretsmanager_secret_version) or SSM Parameter Store (aws_ssm_parameter with with_decryption = true) — *never* from environment variables (TF_VAR_*), terraform.tfvars, or variable default values.
- [ ] Variables that receive secrets do not have default values.
- [ ] Security group rules and network ACLs do not use 0.0.0.0/0 as source or destination unless there is an explicit, documented justification in the PR description.
- [ ] IAM policies follow least privilege — no wildcards (*) in actions or resources without justification.
- [ ] Storage and database resources enable encryption at rest using KMS-managed keys.

## S3 Bucket Hardening (Blocking)

- [ ] aws_s3_bucket_public_access_block is present with all four flags set to true (block_public_acls, block_public_policy, ignore_public_acls, restrict_public_buckets).
- [ ] Bucket versioning is enabled via aws_s3_bucket_versioning.
- [ ] SSL-only bucket policy is present — deny s3:* when aws:SecureTransport = false.
- [ ] Lifecycle configuration is present with expiration/transition rules.
- [ ] Server access logging is enabled via aws_s3_bucket_logging.
- [ ] Encryption uses a CMK (not aws/s3 managed key).

## Compute Security (Blocking)

- [ ] EC2 instances and launch templates enforce IMDSv2 (http_tokens = "required"). IMDSv1 must not be allowed.
- [ ] EBS default encryption is enabled with a CMK in every region used.

## Networking Security (Blocking)

- [ ] AWS services (S3, DynamoDB, STS, KMS, etc.) are accessed via VPC endpoints — not the public internet.
- [ ] Security groups do not use inline ingress/egress blocks. Separate aws_vpc_security_group_ingress_rule/aws_vpc_security_group_egress_rule resources are used (not the deprecated aws_security_group_rule).

## RDS / Aurora Security (Blocking)

- [ ] deletion_protection = true on all database instances and clusters.
- [ ] skip_final_snapshot = false with final_snapshot_identifier configured.
- [ ] storage_encrypted = true with a CMK (kms_key_id set).
- [ ] multi_az = true for production environments.

## TLS (Blocking)

- [ ] Minimum TLS 1.2 enforced on all public-facing endpoints: ALB/NLB listeners, CloudFront distributions, API Gateway, ElastiCache.
- [ ] ALB listeners use a secure SSL policy (e.g. ELBSecurityPolicy-TLS13-1-2-2021-06).
- [ ] CloudFront uses minimum_protocol_version = "TLSv1.2_2021" or higher.

## CloudTrail (Blocking)

- [ ] No changes that disable, delete, or modify existing CloudTrail trails unless explicitly authorized and justified in the PR description.

## IAM Security (Blocking)

- [ ] No aws_iam_user with aws_iam_access_key — use IAM Roles with assume role instead of long-lived credentials.
- [ ] IAM policies for cross-account or cross-service access include conditions (aws:SourceArn, aws:SourceAccount, aws:PrincipalOrgID) to limit blast radius.

## S3 Object Ownership (Blocking)

- [ ] aws_s3_bucket_ownership_controls is set to BucketOwnerEnforced to disable ACLs entirely.

## WAF (Blocking)

- [ ] ALBs, API Gateways, and CloudFront distributions exposed to the internet have AWS WAF associated.

## VPC Flow Logs (Blocking)

- [ ] Every VPC has flow logs enabled (CloudWatch Logs or S3 with CMK).

## SNS / SQS (Blocking)

- [ ] SNS topics are encrypted with a CMK (kms_master_key_id).
- [ ] SQS queues are encrypted with a CMK (kms_master_key_id) and have a dead-letter queue configured (redrive_policy).

## Lambda (Blocking)

- [ ] Lambda functions use architectures = ["arm64"]. Flag any Lambda without this attribute or using ["x86_64"].
- [ ] Lambda functions have an explicit timeout value — not relying on the 3-second default. Flag missing timeout. Flag timeout > 60 without a justifying comment.
- [ ] Lambda functions have vpc_config with subnet_ids and security_group_ids unless there is a documented exception (Lambda@Edge, public-API-only functions). Flag missing vpc_config without a comment explaining why.
- [ ] Lambda functions have reserved_concurrent_executions set to an explicit positive value. Flag = -1 (unreserved) unless justified. Flag = 0 (disabled) unless intentional with a comment.
- [ ] Lambda functions have a dead-letter queue or failure destination configured for async invocations.
- [ ] Lambda runtime is python3.12 or later (check the runtime argument in aws_lambda_function). Flag python3.9, python3.10, python3.11 as outdated.

## Backup Tags (Blocking)

- [ ] Resources that support AWS Backup (RDS, DynamoDB, EFS, EBS, S3, FSx) include the backup tag.
- [ ] The backup tag value is daily_7d_us_local for resources in us-east-1/us-east-2 and daily_7d_sa_local for resources in sa-east-1. No other values are allowed.
- [ ] Resources that do not need backup omit the backup tag entirely — it is never set to empty or any other value.

## Provider Configuration (Blocking)

- [ ] Child modules do not contain provider {} blocks. Provider configuration belongs only in root modules.
- [ ] Child modules may declare required_providers in terraform {} but must not set region, default_tags, or credentials.
- [ ] Multi-region modules receive providers via the providers = {} argument — never implicit inheritance.

## .editorconfig (Warning)

- [ ] An .editorconfig file exists in the repository root with: indent_style = space, indent_size = 2, end_of_line = lf, charset = utf-8, trim_trailing_whitespace = true, insert_final_newline = true.

## README.md (Warning)

- [ ] All links in README.md are absolute URLs — no relative paths like ./docs/foo.md.

## Code Quality (Blocking)

- [ ] No lookup() calls with only 2 arguments — use direct map access var.map["key"] or var.map.key instead. lookup() with 3 arguments (including a default) is acceptable.
- [ ] for_each is used instead of count when iterating over maps or sets. count is only acceptable for conditional creation (count = var.enabled ? 1 : 0).
- [ ] Outputs that expose secrets (passwords, tokens, connection strings) are marked with sensitive = true.
- [ ] No hardcoded AWS account IDs in resources, data sources, locals, or variables — use data.aws_caller_identity.current.account_id instead. *Exception:* backend {} blocks may hardcode bucket/account IDs since data sources are not supported there.
- [ ] Expressions used 2 or more times are extracted into locals — no duplicated expressions across resources.
- [ ] Critical stateful resources (databases, KMS keys, S3 buckets with data, DynamoDB tables) have lifecycle { prevent_destroy = true }.
- [ ] depends_on is used only when Terraform cannot infer the dependency, and always has a comment explaining why.
- [ ] No nested ternary expressions — complex conditions are extracted to locals (maps or intermediate values).
- [ ] Required variables that must not be null have nullable = false (Terraform 1.1+).
- [ ] Resources and data sources use precondition/postcondition blocks for runtime validation where variable validation is insufficient (Terraform 1.2+).

## Encryption (Blocking)

- [ ] Every resource that supports KMS encryption uses a *Customer Managed Key (CMK)* — not AWS-managed keys (aws/s3, aws/ebs, etc.) and not unencrypted.
- [ ] A dedicated aws_kms_key + aws_kms_alias is created for each encryption use case.
- [ ] CMKs have enable_key_rotation = true.
- [ ] CMKs have lifecycle { prevent_destroy = true }.
- [ ] Resources covered: S3, RDS, Aurora, DynamoDB, EBS, EFS, SQS, SNS, CloudWatch Logs, Secrets Manager, SSM Parameter Store, Kinesis, Redshift, ElastiCache, Backup vaults.

## Tagging (Blocking)

- [ ] All resources that support tags receive tags through a tags variable (map(string)) — no hardcoded tag values.
- [ ] Required tags bu, squad, and managed_by are present on every resource, either via default_tags or the resource's own tags block.
- [ ] The AWS provider uses default_tags for organization-wide tags.
- [ ] Resource-specific tags are applied on top of default_tags as needed.
- [ ] When external services manage their own tags (EKS, ASG, AWS Backup), lifecycle { ignore_changes } is used to prevent perpetual drift.

## Naming & Conventions (Blocking)

- [ ] Output names follow the pattern <resource>_<attribute> (e.g. bucket_arn, kms_key_id, instance_id). Generic names like id, arn, name without resource prefix are flagged.
- [ ] Standard Terraform file names use the *plural form*: locals.tf, outputs.tf, providers.tf, variables.tf, versions.tf. Flag singular forms (local.tf, output.tf, provider.tf, variable.tf).
- [ ] Resource file names use kebab-case (e.g. lambda-function.tf, s3-bucket.tf, iam-role.tf).
- [ ] No typos in file names (e.g. lamba.tf instead of lambda.tf).

## Input Validation (Warning)

- [ ] Variables with a finite set of valid values use validation {} blocks with clear error messages (e.g. environment must be one of dev, hom, prd, drp).
- [ ] Variables that represent structured formats (CIDRs, ARNs, email addresses) use validation {} with can() to fail early.
- [ ] No variables use type = any. All variables must have a concrete type (string, number, bool, list(string), map(string), object({...}), etc.). any disables all type checking.

## Dead Code & Duplicates (Warning)

- [ ] No unused modules — every modules/ subdirectory is referenced by at least one module {} block.
- [ ] No files or directories with suffixes like _old, _backup, _copy, _deprecated, or trailing _ — these should be removed or moved to a branch.
- [ ] No duplicate modules (same logic in two directories with slight variations) — extract into a single shared module.
- [ ] No commented-out resource blocks or large commented-out sections. If code is not needed, remove it — Git history preserves it.

## Jinja2 Templates (Blocking)

- [ ] backend.jinja and aft-providers.jinja are not modified unless there is a documented justification.
- [ ] If Jinja templates are customized, default_tags and assume_role patterns are preserved.
- [ ] Rendered files (backend.tf, aft-providers.tf) are NOT committed to the repository.

## State Management (Blocking)

- [ ] Existing AWS resources being adopted use import {} blocks — not the CLI terraform import command.
- [ ] When resources, modules, or for_each keys are renamed, moved {} blocks are used to preserve state. Flag any rename that would cause destroy+recreate without a moved block.
- [ ] When removing a resource from Terraform without destroying it in AWS, removed {} blocks with lifecycle { destroy = false } are used — not terraform state rm.
- [ ] import, moved, and removed blocks from previous applies that are no longer needed should be cleaned up.

## Provider Aliases (Blocking)

- [ ] Multi-region deployments use aliased providers with the standard convention: use1 (us-east-1), sae1 (sa-east-1), use2 (us-east-2).
- [ ] Providers are passed explicitly to modules via the providers argument — never rely on implicit provider inheritance in multi-region setups.

## Provider Version Pinning (Blocking)

- [ ] Provider versions use upper bound constraints (>= X.Y, < Z.0) — not unbounded >= X.Y.

## Timeouts (Warning)

- [ ] Resources that take a long time to create/update/delete (RDS, Aurora, EKS, CloudFront, ACM validation, VPN, Transit Gateway) have explicit timeouts {} blocks configured.

## CI/CD & Operations (Warning)

- [ ] terraform plan output has been reviewed for this PR. No unexpected destroy/replace operations.
- [ ] Drift detection is in place (scheduled plan runs) or planned for the affected infrastructure.

## Anti-Patterns to Flag

- *Hardcoded values*: Suggest using variables or data sources instead of inline literals for environment-specific values.
- *Orphaned resources*: Resources without proper parent/dependency linkage.
- *Missing outputs*: Important resource attributes (IDs, ARNs, endpoints) that other modules may need should be exposed as outputs.
- *Non-descriptive names*: Generic names like main, default, test, this for non-singleton resources.
- *Excessive count usage*: Prefer for_each when iterating over maps or sets.
- *Large inline policies*: Complex IAM policies should be extracted to separate aws_iam_policy_document data sources.
- *Missing lifecycle blocks*: Critical resources (databases, S3 buckets with data, KMS keys) should have prevent_destroy = true.
- *Missing timeouts*: Long-running operations (RDS, EKS, CloudFront) should have explicit timeouts blocks.
- *aws_iam_user with access keys*: Always flag — use IAM Roles instead.
- *type = any in variables*: Always flag — specify the concrete type.
- *Singular file names*: local.tf, output.tf, provider.tf — flag, should be plural.
- *reserved_concurrent_executions = 0* without a comment: Flag — Lambda is disabled, likely a mistake.
- *Lambda without architectures = ["arm64"]*: Flag — all Lambdas must use Graviton2 (ARM64).
- *Lambda without explicit timeout*: Flag — the 3-second default is almost never correct.
- *Lambda without vpc_config*: Flag unless documented exception (Lambda@Edge, public-API-only).
- *Resource type repeated in name*: aws_route_table "public_route_table" — flag, use aws_route_table "public".
- *Nested dynamic inside dynamic*: Flag — deeply nested dynamics are unreadable. Refactor to flatten or use locals.
- *Variable/output argument disorder*: description should always be the first argument inside variable and output blocks.

## .gitignore Compliance (Blocking)

- [ ] .gitignore excludes all required patterns: .terraform/, .terraform.lock.hcl, *.tfstate, *.tfvars, backend.tf, aft-providers.tf, terraform.tfvars, override.tf, *_override.tf, crash.log.
- [ ] .terraform-version is explicitly kept via !.terraform-version negation if a broad **/.terraform* pattern is present.
- [ ] No runtime-generated files (backend.tf, aft-providers.tf, terraform.tfvars) are committed in this PR.

## .terraform-version (Blocking)

- [ ] The repository has a .terraform-version file in the root directory.
- [ ] The file contains a single exact version (e.g. 1.14.7) — not a range.
- [ ] The version in .terraform-version matches the required_version constraint in versions.tf / terraform {} block.
- [ ] If Terraform is upgraded, both .terraform-version and required_version are updated in the same PR.
