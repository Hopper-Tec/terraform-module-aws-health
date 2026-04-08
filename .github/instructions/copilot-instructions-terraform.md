---
applyTo: "{*/.tf,*/.tfvars,*/.hcl}"
---

> All generated code must use *American English (en-US)*: variable names, function names, comments and log strings.

# Terraform Development Best Practices

This repository enforces Terraform best practices through pre-commit hooks. All code must comply with the rules below before being committed.

## Formatting & Syntax

- *All .tf and .tfvars files must be formatted with terraform fmt*. The canonical format uses 2-space indentation, aligned = signs, and sorted arguments. Run terraform fmt -recursive before committing.
- *All configurations must pass terraform validate*. This catches syntax errors, invalid attribute references, type mismatches, and missing required arguments.
- Files must end with exactly one newline (no extra blank lines at the end).
- No trailing whitespace on any line.
- Use LF (\n) line endings only — never CRLF (\r\n).
- YAML files (.yaml, .yml) must have valid syntax.
- Do not commit files larger than 300 KB — state files, binaries, and generated artifacts belong in remote backends or artifact storage, not in Git.
- Never commit files containing merge conflict markers (<<<<<<<, =======, >>>>>>>).

## Variable & Output Declarations

- *Every variable block must have a type constraint*. Never leave variables untyped — this prevents runtime surprises and improves documentation.

  hcl
  # Bad
  variable "name" {}

  # Good
  variable "name" {
    type = string
  }


- *Every variable block must have a description*. Descriptions are used by terraform-docs to generate documentation and help consumers understand the module interface.

  hcl
  variable "name" {
    type        = string
    description = "The name of the resource to create."
  }


- *Every output block must have a description*.

  hcl
  output "id" {
    value       = aws_instance.this.id
    description = "The ID of the created EC2 instance."
  }


- *Follow a consistent argument order inside variable and output blocks.* This makes scanning through variables.tf and outputs.tf predictable.

  For variable:
  hcl
  variable "environment" {
    description = "The deployment environment."      # 1. description (always first)
    type        = string                              # 2. type
    default     = "prd"                               # 3. default (if any)
    nullable    = false                               # 4. nullable (if set)

    validation {                                      # 5. validation (last)
      condition     = contains(["dev", "hom", "prd", "drp"], var.environment)
      error_message = "Must be one of: dev, hom, prd, drp."
    }
  }


  For output:
  hcl
  output "bucket_arn" {
    description = "The ARN of the S3 bucket."        # 1. description
    value       = aws_s3_bucket.this.arn              # 2. value
    sensitive   = false                               # 3. sensitive (if applicable)
  }


## Remove Unused Declarations

- *Do not leave unused variable, data, locals, or provider alias declarations in the code*. If a variable, data source, local value, or aliased provider is declared but never referenced, remove it. Dead declarations create confusion and bloat.

## Naming Conventions

- *Use snake_case for all identifiers*: resource names, variable names, output names, local values, module names, and data source names.

  hcl
  # Bad
  resource "aws_s3_bucket" "myBucket" {}
  resource "aws_s3_bucket" "My-Bucket" {}

  # Good
  resource "aws_s3_bucket" "my_bucket" {}


- *Do not repeat the resource type in the resource name.* The resource type already appears in the reference (aws_s3_bucket.this), so repeating it is redundant and verbose.

  hcl
  # Bad — redundant
  resource "aws_route_table" "public_route_table" {}
  resource "aws_iam_role" "iam_role_lambda" {}

  # Good — descriptive without repetition
  resource "aws_route_table" "public" {}
  resource "aws_iam_role" "lambda_execution" {}


- *Use this as the resource name when a module creates only a single resource of that type.* This is the widely adopted convention in the Terraform community (terraform-aws-modules, etc.) and avoids inventing arbitrary names for singletons.

  hcl
  # Good — single VPC in the module
  resource "aws_vpc" "this" {
    cidr_block = var.cidr_block
  }

  # Good — multiple security groups need descriptive names
  resource "aws_security_group" "public" { ... }
  resource "aws_security_group" "private" { ... }


## File Naming Conventions

- *Use the standard plural file names* for Terraform files. Never use the singular form.

  | Correct (always use) | Incorrect (never use) |
  |---------------------|-----------------------|
  | locals.tf | local.tf |
  | outputs.tf | output.tf |
  | providers.tf | provider.tf |
  | variables.tf | variable.tf |
  | versions.tf | version.tf |

- *Use kebab-case for file names* that describe resources (e.g. lambda-function.tf, s3-bucket.tf, iam-role.tf). The standard structural files (main.tf, locals.tf, outputs.tf, variables.tf, providers.tf, versions.tf, data.tf) keep their conventional names.

- *Double-check spelling in file names.* Typos like lamba.tf instead of lambda.tf are hard to catch later and cause confusion. File names are not validated by Terraform — a misspelled file still works but hurts discoverability.

## Comment Syntax

- *Use # for all comments* — both single-line and multi-line. Do not use // or /* */ style comments. The # syntax is the idiomatic Terraform standard.

  hcl
  # Good: single-line comment
  # Good: multi-line comment
  # that spans multiple lines

  // Bad: C-style single-line comment
  /* Bad: C-style block comment */


## Interpolation Syntax

- *Do not use redundant interpolation wrappers*. In Terraform 0.12+, standalone variable/local/resource references do not need "${...}".

  hcl
  # Bad
  instance_type = "${var.type}"

  # Good
  instance_type = var.type


  When combining expressions, prefer the format() function over inline interpolation:

  hcl
  # Acceptable but not preferred
  name = "prefix-${var.name}-suffix"

  # Preferred
  name = format("prefix-%s-suffix", var.name)


## Index Syntax

- *Use square bracket syntax for list/map access*. The legacy dot-index syntax (list.0, list.*.attr) is deprecated.

  hcl
  # Bad
  value = aws_instance.this.0.id
  attrs = aws_instance.this.*.id

  # Good
  value = aws_instance.this[0].id
  attrs = aws_instance.this[*].id


## Module Sources

- *Pin all Git/Mercurial module sources to a specific version* — never reference main, master, or default branches. Use a tag (preferably semver) or a commit SHA.

  hcl
  # Bad
  source = "git::https://github.com/org/module.git"
  source = "git::https://github.com/org/module.git?ref=main"

  # Good
  source = "git::https://github.com/org/module.git?ref=v1.2.0"


## Provider Version Constraints

- *All providers must be declared in required_providers with both source and version*. Never rely on implicit provider resolution.
- *The AWS provider must be pinned to version >= 6.0, < 7.0*.

  hcl
  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = ">= 6.0, < 7.0"
      }
    }
  }


## Terraform Version Constraint

- *Every root module must declare required_version* in the terraform {} block. This prevents running the configuration with an incompatible Terraform CLI version.
- *The minimum Terraform version must be >= 1.14.0*.

  hcl
  terraform {
    required_version = ">= 1.14.0"
  }


## Standard Module Structure

- *Follow the Terraform Standard Module Structure*. At minimum, a module should have:
  - main.tf — primary resources
  - variables.tf — all variable declarations
  - outputs.tf — all output declarations
- Do not place variable blocks in main.tf or output blocks in variables.tf. Keep them in their conventional files.

## Workspace Usage with Remote Backend

- *Do not use terraform.workspace* when using a remote backend with remote execution (Terraform v1.0.x). It always returns "default" in that context. Use a dedicated variable instead.

## Documentation

- *README.md must be auto-generated* using terraform-docs. The documentation is inserted between <!-- BEGIN_TF_DOCS --> and <!-- END_TF_DOCS --> markers. Do not edit content between these markers manually — it will be overwritten.

## Lookup Function

- *Do not use lookup() with only 2 arguments*. Since Terraform 0.12+, direct map access replaces the legacy lookup(map, key) pattern.

  hcl
  # Bad
  value = lookup(var.tags, "environment")

  # Good
  value = var.tags["environment"]
  value = var.tags.environment

  # lookup with a default is still valid
  value = lookup(var.tags, "optional_key", "fallback")


## Prefer for_each over count

- *Use for_each instead of count when iterating over maps or sets*. count uses integer indices — removing an item from the middle causes all subsequent resources to be destroyed and recreated. for_each uses stable keys.

  hcl
  # Bad — removing "b" from the list destroys "c" and recreates it
  variable "buckets" {
    default = ["a", "b", "c"]
  }
  resource "aws_s3_bucket" "this" {
    count  = length(var.buckets)
    bucket = var.buckets[count.index]
  }

  # Good — removing "b" only destroys "b"
  variable "buckets" {
    default = toset(["a", "b", "c"])
  }
  resource "aws_s3_bucket" "this" {
    for_each = var.buckets
    bucket   = each.value
  }


- count is acceptable only for conditional creation (count = var.enabled ? 1 : 0).

## dynamic Blocks

- *Use dynamic blocks to generate repeated nested blocks* (e.g. ingress, rule, setting) from a variable or local. This avoids copy-pasting identical blocks with minor differences.

  hcl
  # Bad — duplicated blocks
  resource "aws_security_group" "this" {
    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Good — dynamic block from variable
  variable "ingress_rules" {
    type = list(object({
      port        = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  }

  resource "aws_security_group" "this" {
    dynamic "ingress" {
      for_each = var.ingress_rules
      content {
        from_port   = ingress.value.port
        to_port     = ingress.value.port
        protocol    = ingress.value.protocol
        cidr_blocks = ingress.value.cidr_blocks
      }
    }
  }


- *Do not over-use dynamic blocks.* If a block appears only once or twice and its structure is simple, writing it out directly is more readable than a dynamic block. Use dynamic when the number of blocks is variable or the repetition is significant (3+).
- *Never nest dynamic inside dynamic* unless absolutely unavoidable — deeply nested dynamics are extremely hard to read and debug.

## Sensitive Outputs

- *Mark outputs that expose secrets with sensitive = true*. This prevents passwords, tokens, connection strings, and other sensitive values from being displayed in terraform plan and terraform apply output.

  hcl
  output "database_password" {
    value       = aws_db_instance.this.password
    description = "The master password for the RDS instance."
    sensitive   = true
  }


## Data Sources over Hardcoded Values

- *Use data sources instead of hardcoding AWS account IDs, regions, partition, or other environment-specific values*.

  hcl
  # Bad
  account_id = "393376590818"
  region     = "us-east-1"

  # Good
  data "aws_caller_identity" "current" {}
  data "aws_region" "current" {}

  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.id


## Use Locals for Repeated Expressions

- *Extract expressions used 2 or more times into locals*. This reduces duplication and makes the code easier to maintain.

  hcl
  # Bad — same expression repeated
  resource "aws_s3_bucket" "this" {
    bucket = format("%s-%s-%s", var.project, var.environment, "data")
    tags   = { Name = format("%s-%s-%s", var.project, var.environment, "data") }
  }

  # Good
  locals {
    bucket_name = format("%s-%s-%s", var.project, var.environment, "data")
  }
  resource "aws_s3_bucket" "this" {
    bucket = local.bucket_name
    tags   = { Name = local.bucket_name }
  }


## Locals for Explicit Dependency Hints

- When Terraform cannot automatically infer a dependency between resources (and depends_on would be too coarse), use a *local value to create an explicit data dependency*. This is cleaner than depends_on because it creates a precise, targeted dependency rather than forcing the entire resource to wait.

  hcl
  # Instead of depends_on (which blocks the entire resource):
  locals {
    role_ready = aws_iam_role_policy_attachment.this.id
  }

  resource "aws_lambda_function" "this" {
    # This creates a data dependency on the policy attachment
    # without blocking unrelated attributes.
    tags = {
      DependsOn = local.role_ready
    }
  }


- Use this pattern sparingly — only when Terraform's implicit dependency graph is insufficient and depends_on would cause unnecessary serialization.

## Provider Configuration Only in Root Modules

- *Child modules must never contain provider blocks.* Provider configuration (credentials, region, default_tags) belongs exclusively in the root module (composition).
- Child modules receive providers implicitly or via the providers argument in the module {} block.
- This is especially important in the AFT context: aft-providers.jinja renders the provider config at the root level — child modules must never duplicate or override it.
- Exception: the required_providers block inside terraform {} *is allowed* in child modules to declare which providers the module needs and their version constraints.

## .editorconfig Standard

- Every repository should have an .editorconfig file in the root to ensure consistent formatting across editors and CI:

  ini
  root = true

  [*]
  indent_style = space
  indent_size = 2
  end_of_line = lf
  charset = utf-8
  trim_trailing_whitespace = true
  insert_final_newline = true

  [*.md]
  trim_trailing_whitespace = false

  [Makefile]
  indent_style = tab


- This ensures that .tf, .py, .sh, .md, and all other files have consistent whitespace, line endings, and charset — regardless of which editor or OS the developer uses.

## README.md Links

- *All links in README.md files must be absolute URLs* (not relative paths). This ensures they render correctly when the module is published to the Terraform Registry or viewed from external tools.

## Protect Critical Resources

- *Add lifecycle { prevent_destroy = true } to critical resources* that should never be accidentally deleted — databases, KMS keys, S3 buckets with data, DynamoDB tables, and similar stateful resources.

  hcl
  resource "aws_db_instance" "this" {
    # ...
    lifecycle {
      prevent_destroy = true
    }
  }


## Encryption at Rest with Customer Managed Keys (CMK)

- *Every resource that supports KMS encryption must use a Customer Managed Key (CMK)* — never rely on AWS-managed keys (aws/s3, aws/ebs, etc.) or leave encryption disabled. Always create a dedicated aws_kms_key + aws_kms_alias for the resource.
- This applies to (but is not limited to): S3, RDS, Aurora, DynamoDB, EBS, EFS, SQS, SNS, CloudWatch Logs, Secrets Manager, SSM Parameter Store, Kinesis, Redshift, ElastiCache, and Backup vaults.

  hcl
  # Create a dedicated CMK
  resource "aws_kms_key" "bucket" {
    description             = "CMK for S3 bucket encryption"
    deletion_window_in_days = 30
    enable_key_rotation     = true

    lifecycle {
      prevent_destroy = true
    }
  }

  resource "aws_kms_alias" "bucket" {
    name          = format("alias/%s-bucket", var.project)
    target_key_id = aws_kms_key.bucket.key_id
  }

  # Use the CMK in the resource
  resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
    bucket = aws_s3_bucket.this.id

    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.bucket.arn
      }
      bucket_key_enabled = true
    }
  }


- *Always enable key rotation* (enable_key_rotation = true) on CMKs.
- *Always protect CMKs with prevent_destroy* — losing a KMS key means losing access to all data encrypted with it.

## Tagging Strategy

- *All resources that support tags must receive tags through a variable*. Define a tags variable of type map(string) and pass it consistently to every resource.
- Use default_tags in the AWS provider block for organization-wide tags, and merge resource-specific tags on top.

  hcl
  variable "tags" {
    type        = map(string)
    description = "A map of tags to apply to all resources."
    default     = {}
  }

  provider "aws" {
    default_tags {
      tags = var.tags
    }
  }

  # Resource-specific tags are merged with default_tags automatically
  resource "aws_s3_bucket" "this" {
    bucket = local.bucket_name

    tags = {
      Name = local.bucket_name  # resource-specific override; bu/squad/managed_by come from default_tags
    }
  }


- *Required tags are bu, squad, and managed_by* — every AWS resource must carry these three at minimum. Set them via default_tags in the provider so they are applied automatically; resource-specific blocks only need to add supplementary tags like Name.
- *Never hardcode tag values* directly in resources. Pass them through variables so they can be controlled by the caller.
- When external services (EKS, ASG, AWS Backup) manage their own tags, use lifecycle { ignore_changes } to prevent perpetual drift:

  hcl
  resource "aws_autoscaling_group" "this" {
    # ...
    lifecycle {
      ignore_changes = [tag]
    }
  }


## Output Naming Convention

- *Follow the pattern <resource>_<attribute>* for output names. This makes outputs predictable and easy to consume from other modules.

  hcl
  # Bad
  output "id" { ... }
  output "arn" { ... }

  # Good
  output "bucket_id" {
    value       = aws_s3_bucket.this.id
    description = "The ID of the S3 bucket."
  }

  output "bucket_arn" {
    value       = aws_s3_bucket.this.arn
    description = "The ARN of the S3 bucket."
  }

  output "kms_key_arn" {
    value       = aws_kms_key.bucket.arn
    description = "The ARN of the KMS key used for bucket encryption."
  }


## Variable Validation

- *Use validation blocks to enforce constraints on input variables*. Fail early with clear error messages instead of failing during apply.

  hcl
  variable "environment" {
    type        = string
    description = "The deployment environment."

    validation {
      condition     = contains(["dev", "hom", "prd", "drp"], var.environment)
      error_message = "Environment must be one of: dev, hom, prd, drp."
    }
  }

  variable "cidr_block" {
    type        = string
    description = "The CIDR block for the VPC."

    validation {
      condition     = can(cidrhost(var.cidr_block, 0))
      error_message = "Must be a valid CIDR block (e.g. 10.0.0.0/16)."
    }
  }


## Variable Type Safety

- *Never use type = any in variable declarations.* Always specify the concrete type — string, number, bool, list(string), map(string), object({...}), etc. type = any disables all type checking, which means invalid input is only caught at apply time (or worse, silently produces wrong behavior).

  hcl
  # Bad — no type safety, anything passes
  variable "policy_vars" {
    type = any
  }

  # Good — explicit type catches errors at plan time
  variable "policy_vars" {
    type = object({
      backup_vault_name = string
      retention_days    = number
      schedule          = string
      regions           = list(string)
    })
    description = "Variables for the backup policy template."
  }


- *any is acceptable only* in extremely generic passthrough variables (e.g. a module that wraps another module and forwards its input unchanged). Even then, prefer object({}) with known attributes.

## State Management: import, moved, and removed Blocks

Terraform provides three declarative blocks to manage state transitions without manual CLI commands. *Always prefer these blocks over terraform import, terraform state mv, or terraform state rm commands.*

### import — Bring Existing Resources Under Terraform Management

- Use import blocks to adopt existing AWS resources into Terraform state via code. This is auditable, reproducible, and works in CI/CD — unlike the CLI terraform import command.

  hcl
  import {
    to = aws_s3_bucket.existing
    id = "my-existing-bucket-name"
  }

  resource "aws_s3_bucket" "existing" {
    bucket = "my-existing-bucket-name"
    # ...
  }


- After successful apply, remove the import block — it is a one-time directive.
- Run terraform plan first to verify the imported state matches the configuration. Fix any drift before applying.

### moved — Rename or Reorganize Without Destroy/Recreate

- Use moved blocks when renaming resources, changing for_each keys, moving resources into/out of modules, or refactoring module structure.

  hcl
  # Renamed resource
  moved {
    from = aws_s3_bucket.main
    to   = aws_s3_bucket.this
  }

  # Changed for_each key
  moved {
    from = aws_s3_bucket.this["old-key"]
    to   = aws_s3_bucket.this["new-key"]
  }

  # Moved into a module
  moved {
    from = aws_s3_bucket.this
    to   = module.storage.aws_s3_bucket.this
  }

  # Moved between modules
  moved {
    from = module.old_module.aws_s3_bucket.this
    to   = module.new_module.aws_s3_bucket.this
  }


- After successful apply, remove the moved block.
- *Never rename a resource or change a for_each key without a moved block* — Terraform will plan a destroy+create, causing downtime and data loss.

### removed — Remove from State Without Destroying the Resource

- Use removed blocks (Terraform 1.7+) when you want to stop managing a resource in Terraform *without deleting it from AWS*. This replaces terraform state rm.

  hcl
  removed {
    from = aws_s3_bucket.legacy

    lifecycle {
      destroy = false
    }
  }


- This is useful for handing off resources to another Terraform workspace, another team, or manual management.
- After successful apply, remove the removed block.

## Provider Aliases for AWS Regions

- *Always use aliased providers for multi-region deployments*. Follow the standard alias convention:

  | Region | Alias |
  |--------|-------|
  | us-east-1 | use1 |
  | us-east-2 | use2 |
  | sa-east-1 | sae1 |

  hcl
  provider "aws" {
    alias  = "use1"
    region = "us-east-1"
  }

  provider "aws" {
    alias  = "sae1"
    region = "sa-east-1"
  }

  provider "aws" {
    alias  = "use2"
    region = "us-east-2"
  }


- *Always pass providers explicitly to modules* — never rely on implicit provider inheritance in multi-region setups:

  hcl
  module "bucket_sae1" {
    source = "./modules/s3"
    providers = {
      aws = aws.sae1
    }
  }


## Explicit Timeouts

- *Configure explicit timeouts blocks on resources that take a long time to create, update, or delete*. This avoids hanging on the Terraform default (which can be too short or too long) and makes failures surface faster.

  hcl
  resource "aws_db_instance" "this" {
    # ...
    timeouts {
      create = "60m"
      update = "60m"
      delete = "60m"
    }
  }

  resource "aws_eks_cluster" "this" {
    # ...
    timeouts {
      create = "30m"
      update = "60m"
      delete = "30m"
    }
  }


- Common resources that need explicit timeouts: RDS, Aurora, EKS, CloudFront, ACM certificate validation, VPN, Transit Gateway, and Direct Connect.

## depends_on Usage

- *Use depends_on only when Terraform cannot infer the dependency automatically*, and always add a comment explaining why. Terraform resolves most dependencies through reference expressions — explicit depends_on should be the exception, not the rule.

  hcl
  resource "aws_ecs_service" "this" {
    # ...

    # depends_on is required because the IAM role policy attachment
    # is not referenced directly by the ECS service, but the service
    # needs the policy to be attached before it can pull images.
    depends_on = [aws_iam_role_policy_attachment.ecs_execution]
  }


- *Never use depends_on as a lazy fix* for ordering issues that could be solved by referencing the correct attribute.

## Conditional Expressions

- *Avoid nested ternary expressions* — they are hard to read and maintain. Extract complex conditions into locals.

  hcl
  # Bad — nested ternary
  cidr_block = var.environment == "prd" ? "10.0.0.0/16" : var.environment == "hom" ? "10.1.0.0/16" : "10.2.0.0/16"

  # Good — use a local map
  locals {
    cidr_map = {
      prd = "10.0.0.0/16"
      hom = "10.1.0.0/16"
      dev = "10.2.0.0/16"
    }
  }
  cidr_block = local.cidr_map[var.environment]


- Simple one-level ternaries are fine: count = var.enabled ? 1 : 0.

## nullable = false on Required Variables

- *Set nullable = false on variables that must always have a value* (Terraform 1.1+). This prevents callers from passing null — which would silently use the default or cause runtime errors.

  hcl
  variable "vpc_id" {
    type        = string
    description = "The VPC ID where resources will be created."
    nullable    = false
  }


- Variables with default = null (optional variables) should keep nullable = true (the default).

## precondition and postcondition Blocks

- *Use precondition and postcondition blocks for runtime validation* (Terraform 1.2+). Unlike variable validation, these can reference other resources and data sources.

  hcl
  data "aws_vpc" "selected" {
    id = var.vpc_id

    lifecycle {
      postcondition {
        condition     = self.state == "available"
        error_message = "VPC ${var.vpc_id} is not in 'available' state."
      }
    }
  }

  resource "aws_subnet" "this" {
    vpc_id     = data.aws_vpc.selected.id
    cidr_block = var.subnet_cidr

    lifecycle {
      precondition {
        condition     = can(cidrhost(var.subnet_cidr, 0))
        error_message = "subnet_cidr must be a valid CIDR block."
      }
    }
  }


## Provider Version Upper Bound

- *Pin provider versions with an upper bound* to prevent unexpected breaking changes from major version upgrades. Use >= X.Y, < Z.0 instead of just >= X.Y.

  hcl
  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = ">= 6.0, < 7.0"
      }
    }
  }


## terraform plan Before Merge

- *Every pull request must include a reviewed terraform plan output* before approval. Never approve a PR without confirming that the plan shows no unexpected changes (especially destroy/replace operations).
- In CI/CD pipelines, plan output should be posted as a PR comment for visibility.

## Drift Detection

- *Scheduled terraform plan runs should be configured* to detect drift between the actual infrastructure state and the Terraform configuration. Drift must be investigated and resolved — either by updating the code or correcting the infrastructure.

## Security

### General

- No hardcoded secrets (passwords, tokens, API keys, connection strings) in any file. Never set default values on variables that hold secrets.
- *Secrets must come from AWS Secrets Manager or SSM Parameter Store* — never from environment variables, terraform.tfvars, or variable defaults. Environment variables are visible in process listings, CI/CD logs, and shell history. Use aws_secretsmanager_secret_version or aws_ssm_parameter data sources to retrieve secrets at runtime.

  hcl
  # Bad — secret in environment variable or tfvars
  variable "db_password" {
    type    = string
    default = "my-secret-password"  # NEVER do this
  }

  # Bad — passed via TF_VAR_db_password env var (leaks in logs/process list)

  # Good — retrieve from Secrets Manager at runtime
  data "aws_secretsmanager_secret_version" "db_password" {
    secret_id = "my-app/db-password"
  }

  resource "aws_db_instance" "this" {
    # ...
    password = data.aws_secretsmanager_secret_version.db_password.secret_string
  }

  # Good — retrieve from SSM Parameter Store (SecureString)
  data "aws_ssm_parameter" "db_password" {
    name            = "/my-app/db-password"
    with_decryption = true
  }


- Security group rules and network ACLs must not use 0.0.0.0/0 unless explicitly justified.
- IAM policies must follow least privilege — avoid wildcards (*) in actions or resources.
- All storage and database resources must enable encryption at rest using KMS-managed keys (see CMK section above).

### S3 Bucket Hardening

Every S3 bucket must have the following protections enabled:

- *Block Public Access (BPA)* — all four flags set to true. No exceptions without documented justification.

  hcl
  resource "aws_s3_bucket_public_access_block" "this" {
    bucket = aws_s3_bucket.this.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }


- *Versioning enabled* — protects against accidental deletion and overwrites.

  hcl
  resource "aws_s3_bucket_versioning" "this" {
    bucket = aws_s3_bucket.this.id

    versioning_configuration {
      status = "Enabled"
    }
  }


- *SSL-only policy* — deny any request that does not use HTTPS.

  hcl
  resource "aws_s3_bucket_policy" "ssl_only" {
    bucket = aws_s3_bucket.this.id

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.this.arn,
          format("%s/*", aws_s3_bucket.this.arn),
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }]
    })
  }


- *Lifecycle policies* — configure expiration and transition rules for cost optimization.

  hcl
  resource "aws_s3_bucket_lifecycle_configuration" "this" {
    bucket = aws_s3_bucket.this.id

    rule {
      id     = "expire-noncurrent"
      status = "Enabled"

      noncurrent_version_expiration {
        noncurrent_days = 90
      }
    }
  }


- *Server access logging* — enable access logs to an audit bucket.

  hcl
  resource "aws_s3_bucket_logging" "this" {
    bucket = aws_s3_bucket.this.id

    target_bucket = var.logging_bucket_id
    target_prefix = format("s3-access-logs/%s/", aws_s3_bucket.this.id)
  }


- *Encryption* — always use CMK (covered in the Encryption section above).

### EC2 / Compute

- *IMDSv2 required* — all EC2 instances and launch templates must enforce IMDSv2 to prevent SSRF-based credential theft.

  hcl
  resource "aws_instance" "this" {
    # ...
    metadata_options {
      http_tokens   = "required"  # Enforces IMDSv2
      http_endpoint = "enabled"
    }
  }

  resource "aws_launch_template" "this" {
    # ...
    metadata_options {
      http_tokens   = "required"
      http_endpoint = "enabled"
    }
  }


- *EBS encryption by default* — enable default EBS encryption with a CMK in every region used.

  hcl
  resource "aws_ebs_default_encryption" "this" {
    provider = aws.sae1
    enabled  = true
  }

  resource "aws_ebs_encryption_by_default" "this" {
    provider = aws.sae1
    enabled  = true
  }


### Networking

- *VPC Endpoints* — access AWS services (S3, DynamoDB, STS, KMS, CloudWatch Logs, ECR, etc.) via VPC endpoints instead of the public internet. Use Gateway endpoints for S3 and DynamoDB; Interface endpoints for other services.

  hcl
  resource "aws_vpc_endpoint" "s3" {
    vpc_id       = var.vpc_id
    service_name = format("com.amazonaws.%s.s3", data.aws_region.current.id)
    vpc_endpoint_type = "Gateway"
    route_table_ids   = var.private_route_table_ids
  }


- *Security Groups without inline rules* — always use separate aws_vpc_security_group_ingress_rule/aws_vpc_security_group_egress_rule resources instead of inline ingress/egress blocks. The legacy aws_security_group_rule resource is deprecated since provider v5.0 — do not use it. Inline rules cause conflicts when multiple modules manage the same security group.

  hcl
  # Bad — inline rules
  resource "aws_security_group" "this" {
    ingress { ... }
    egress  { ... }
  }

  # Good — separate rule resources
  resource "aws_security_group" "this" {
    name        = "my-sg"
    description = "My security group"
    vpc_id      = var.vpc_id
  }

  resource "aws_vpc_security_group_ingress_rule" "https" {
    security_group_id = aws_security_group.this.id
    from_port         = 443
    to_port           = 443
    ip_protocol       = "tcp"
    cidr_ipv4         = var.allowed_cidr
  }


### RDS / Aurora

- *Deletion protection enabled* — deletion_protection = true on all database instances and clusters.
- *Final snapshot required* — skip_final_snapshot = false and final_snapshot_identifier configured.
- *Encryption enabled* — storage_encrypted = true with a CMK.
- *Multi-AZ* for production environments.

  hcl
  resource "aws_db_instance" "this" {
    # ...
    deletion_protection      = true
    skip_final_snapshot      = false
    final_snapshot_identifier = format("%s-final", var.identifier)
    storage_encrypted        = true
    kms_key_id               = aws_kms_key.rds.arn
    multi_az                 = var.environment == "prd" ? true : false

    lifecycle {
      prevent_destroy = true
    }
  }


### TLS

- *Minimum TLS 1.2* — enforce TLS 1.2 or higher on all public-facing endpoints: ALB/NLB listeners, CloudFront distributions, API Gateway, and ElastiCache.

  hcl
  # ALB HTTPS listener
  resource "aws_lb_listener" "https" {
    # ...
    ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  }

  # CloudFront
  resource "aws_cloudfront_distribution" "this" {
    viewer_certificate {
      minimum_protocol_version = "TLSv1.2_2021"
      # ...
    }
  }


### CloudTrail

- *Never disable, delete, or modify existing CloudTrail trails* via Terraform unless explicitly authorized. CloudTrail is a compliance requirement — any change must be discussed and approved before merge.

### IAM: Roles over Users

- *Never create aws_iam_user with access keys*. Use IAM Roles with assume role for all service-to-service and cross-account access. IAM Users with long-lived credentials are a security risk.

  hcl
  # Bad — IAM user with access key
  resource "aws_iam_user" "deployer" { ... }
  resource "aws_iam_access_key" "deployer" { ... }

  # Good — IAM role with assume role
  resource "aws_iam_role" "deployer" {
    name = "deployer"
    assume_role_policy = data.aws_iam_policy_document.assume.json
  }


### IAM Policy Conditions

- *Use conditions in IAM policies for cross-account and cross-service access* to limit the blast radius. Always include aws:SourceArn, aws:SourceAccount, or aws:PrincipalOrgID where applicable.

  hcl
  data "aws_iam_policy_document" "sns_publish" {
    statement {
      effect    = "Allow"
      actions   = ["sns:Publish"]
      resources = [aws_sns_topic.alerts.arn]

      principals {
        type        = "Service"
        identifiers = ["events.amazonaws.com"]
      }

      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [data.aws_caller_identity.current.account_id]
      }
    }
  }


### S3 Object Ownership

- *Set aws_s3_bucket_ownership_controls to BucketOwnerEnforced* to disable ACLs entirely. This is the AWS recommended setting since April 2023.

  hcl
  resource "aws_s3_bucket_ownership_controls" "this" {
    bucket = aws_s3_bucket.this.id

    rule {
      object_ownership = "BucketOwnerEnforced"
    }
  }


### WAF on Public-Facing Resources

- *ALBs, API Gateways, and CloudFront distributions exposed to the internet must have AWS WAF associated*. Use aws_wafv2_web_acl_association to attach a WAF ACL.

### VPC Flow Logs

- *Every VPC must have flow logs enabled* for network traffic auditing. Send logs to CloudWatch Logs or S3 with a CMK.

  hcl
  resource "aws_flow_log" "this" {
    vpc_id               = aws_vpc.this.id
    traffic_type         = "ALL"
    log_destination_type = "cloud-watch-logs"
    log_destination      = aws_cloudwatch_log_group.flow_logs.arn
    iam_role_arn         = aws_iam_role.flow_logs.arn
  }


### SNS Topic Encryption

- *All SNS topics must be encrypted with a CMK*.

  hcl
  resource "aws_sns_topic" "this" {
    name              = "my-topic"
    kms_master_key_id = aws_kms_key.sns.arn
  }


### SQS Queue Encryption and Dead-Letter Queue

- *All SQS queues must be encrypted with a CMK* and have a *dead-letter queue (DLQ)* configured.

  hcl
  resource "aws_sqs_queue" "dlq" {
    name              = "my-queue-dlq"
    kms_master_key_id = aws_kms_key.sqs.arn
  }

  resource "aws_sqs_queue" "this" {
    name              = "my-queue"
    kms_master_key_id = aws_kms_key.sqs.arn

    redrive_policy = jsonencode({
      deadLetterTargetArn = aws_sqs_queue.dlq.arn
      maxReceiveCount     = 3
    })
  }


### Lambda: Architecture, Concurrency, Timeout, VPC, and Failure Handling

- *All Lambda functions must use ARM64 architecture* (architectures = ["arm64"]). Graviton2 provides better price-performance than x86_64 for the same workload. There is no exception — all new Lambdas must be ARM.
- *Every Lambda must have an explicit timeout value* appropriate for its workload. The default (3 seconds) is almost never correct. Analyze the function's expected execution time and set a value with reasonable headroom. Document the rationale with a comment if the timeout exceeds 60 seconds.
- *Lambda functions should run inside a VPC whenever possible* (vpc_config block with subnet_ids and security_group_ids). This is mandatory when the function needs to access VPC resources (RDS, ElastiCache, internal ALBs, etc.) and strongly recommended for all other functions to reduce attack surface. Exceptions: Lambda@Edge, functions that only call public AWS APIs with no VPC resource access — document the exception with a comment.
- *Lambda functions must have reserved_concurrent_executions configured* to prevent runaway invocations from exhausting account-level concurrency. Choose an explicit value based on the function's expected throughput.
- *reserved_concurrent_executions = 0 means the Lambda is DISABLED* (throttled to zero). Only use this intentionally to disable a function. If you see = 0 without a comment explaining why, it is likely a mistake.
- *reserved_concurrent_executions = -1 means unreserved* (no limit, shares the account pool). This is acceptable for low-risk functions, but prefer an explicit positive value for production workloads to prevent one function from starving others.
- *Lambda functions must have a dead-letter queue or failure destination* configured to capture failed invocations. Without this, failed async invocations are silently discarded after retries.

  hcl
  resource "aws_lambda_function" "this" {
    function_name = "my-function"
    runtime       = "python3.12"
    handler       = "main.handler"
    timeout       = 30  # 30s — typical for API-backed functions
    architectures = ["arm64"]

    reserved_concurrent_executions = 100

    vpc_config {
      subnet_ids         = var.private_subnet_ids
      security_group_ids = [aws_security_group.lambda.id]
    }

    dead_letter_config {
      target_arn = aws_sqs_queue.lambda_dlq.arn
    }
  }

  # Intentionally disabled function (document why)
  resource "aws_lambda_function" "deprecated" {
    # ...
    architectures                  = ["arm64"]
    reserved_concurrent_executions = 0  # Disabled — migrated to new_function
  }

  # Exception: no VPC needed — only calls public S3 API
  resource "aws_lambda_function" "s3_processor" {
    # ...
    architectures = ["arm64"]
    timeout       = 120  # Processing large files, 2 min headroom
    # No vpc_config — only accesses S3 via public endpoint
  }


### Backup Tags

- *Resources that support AWS Backup (RDS, DynamoDB, EFS, EBS, S3, FSx) must include the backup tag* so they are automatically included in backup plans. The tag value depends on the region:

  | Region | Alias | Tag Value |
  |--------|-------|-----------|
  | us-east-1 | use1 | daily_7d_us_local |
  | us-east-2 | use2 | daily_7d_us_local |
  | sa-east-1 | sae1 | daily_7d_sa_local |

  hcl
  # Resource in us-east-1 or us-east-2
  resource "aws_db_instance" "this" {
    provider = aws.use1  # or aws.use2
    # ...
    tags = {
      backup = "daily_7d_us_local"
    }
  }

  # Resource in sa-east-1
  resource "aws_db_instance" "this" {
    provider = aws.sae1
    # ...
    tags = {
      backup = "daily_7d_sa_local"
    }
  }


- *No other backup tag values are allowed.* If a resource does not need backup, omit the tag entirely — do not set it to empty or any other value.

## Jinja2 Templates (AFT Runtime)

- The backend.jinja and aft-providers.jinja files are *rendered by the AFT framework at runtime* (CodePipeline/CodeBuild) to generate backend.tf and aft-providers.tf. They are not standard Terraform files.
- *Do not modify these templates* unless there is a documented, justified need. They are part of the AFT contract and changes may break the pipeline or introduce drift across accounts.
- If you must customize a Jinja template (e.g. adding a provider alias or cross-account assume role):
  - Maintain the existing default_tags and assume_role patterns — do not remove them.
  - *Do not hardcode AWS account IDs* in the template. Use Jinja variables (e.g. {{ account_id }}, {{ aft_admin_role_arn }}) when available, or document the hardcoded IDs with a comment explaining why parametrization is not possible.
  - Test the rendered output locally (via aft.sh or jinja2-cli) before pushing.
- *Never commit the rendered files* (backend.tf, aft-providers.tf) to the repository — they must remain in .gitignore.

## .gitignore — Required Exclusions

The following files *must always be in .gitignore* and never committed to the repository:

| File / Pattern | Reason |
|----------------|--------|
| **/.terraform/* | Local provider and module cache — machine-specific |
| .terraform.lock.hcl | Lock file is auto-generated and varies by platform |
| *.tfstate / *.tfstate.* | State files contain secrets and resource metadata |
| *.tfvars / *.tfvars.json | Variable files may contain sensitive values or are runtime-generated |
| backend.tf | AFT renders this from backend.jinja at runtime |
| aft-providers.tf | AFT renders this from aft-providers.jinja at runtime |
| terraform.tfvars | Generated by get-tf-custom-fields.sh from SSM parameters at runtime |
| override.tf / *_override.tf | Terraform override files — used locally, never committed |
| .terraformrc / terraform.rc | CLI config — user-specific |
| crash.log / crash.*.log | Terraform crash dumps |
| .DS_Store | macOS metadata |

*Important:*

- The .terraform-version file must be *excluded from the ignore rules* (use !.terraform-version negation) because it pins the Terraform version for tfenv/tfswitch.
- If new runtime-generated files appear (e.g. from new AFT scripts), add them to .gitignore immediately — never commit transient artifacts.
- When in doubt, ask: "Is this file the same on every developer's machine and CI/CD?" If no, it belongs in .gitignore.

## .terraform-version — Pinning the Terraform Version

- Every repository *must have a .terraform-version file* in the root directory. This file is consumed by tfenv and tfswitch to automatically select the correct Terraform binary.
- The file contains a single line with the version number, e.g. 1.14.7.
- *This file must be committed to Git* — add !.terraform-version to .gitignore if a broad **/.terraform* pattern would otherwise exclude it.
- When upgrading Terraform, update .terraform-version *and* required_version in versions.tf in the same PR. They must always agree.
- Do not use a version range (e.g. >= 1.14.0) in this file — use the exact version.
