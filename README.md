# Terraform Module: AWS Health Alerts 🏥

Reusable Terraform module for AWS Health event alerts via EventBridge rules and SNS targets.

---

## Index

- [Project Structure](#project-structure)
- [Tooling Setup](#tooling-setup)
- [Usage Guide](#usage-guide)
- [Release Process](#release-process)
- [Troubleshooting](#troubleshooting)
- [Support](#support)

---

## 🗂️ Project Structure

- `.pre-commit-config.yaml` – Shared linting hooks
- `modules/` – Terraform modules
  - [Health Event Rule](./modules/health-event-rule/README.md)

---

## 🧰 Tooling Setup

```sh
brew install warrensbox/tap/tfswitch
brew install terraform-docs
brew install tflint
brew install pre-commit
```

### ✅ Pre-commit Hooks

```sh
pre-commit install --install-hooks
pre-commit run --all-files
```

---

## 🚀 Usage Guide

1. Clone this repository and navigate to the desired module folder.
2. Review the module-specific README for inputs, examples, and outputs.
3. Use `terraform init`, `terraform plan`, and `terraform apply` to provision resources.

---

## 🏷️ Release Process

- Cut a new tag for every release following [SemVer](https://semver.org/).
- Include changelog notes summarizing module updates.

---

## 🧰 Troubleshooting

```sh
pre-commit run --all-files
```

---

## 🤝 Support

- Open an issue or pull request with detailed context.
- Mention the affected module and include Terraform versions.
