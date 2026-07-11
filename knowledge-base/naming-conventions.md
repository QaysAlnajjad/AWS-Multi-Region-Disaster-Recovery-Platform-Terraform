---
title: Naming Conventions
version: 1.0
---

# Naming Conventions

These naming conventions are mandatory across the repository.

---

# Terraform

Rules

- Variables use snake_case.
- Outputs use snake_case.
- Resources use snake_case.

---

# Modules

Rules

Module directories use kebab-case.

Examples

network-vpc

ecs-service

route53

---

# Environments

Rules

Environment directories use lowercase names.

Deployment layers use descriptive names.

---

# Scripts

Rules

Script filenames use kebab-case.

---

# GitHub Workflows

Rules

Workflow filenames use kebab-case.

Workflow names must clearly describe their purpose.

---

# Parameter Store

Rules

Parameter names use hierarchical paths.

Example

/wordpress/application/database/endpoint
