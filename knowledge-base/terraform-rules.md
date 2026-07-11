---
title: Terraform Rules
version: 1.0
---

# Terraform Rules

This document defines Terraform conventions specific to this project.

---

# Providers

Rules

- Provider blocks are allowed only inside environments.
- Reusable modules must never define providers.

---

# Backend

Rules

- Backend configuration belongs only inside environments.
- Backend configuration must never be hardcoded inside modules.

---

# Modules

Rules

- Modules must expose only required outputs.
- Modules must receive all external values through variables.
- Modules must never depend directly on another module.

---

# Variables

Rules

- Every variable must define a type.
- Every variable must include a description.
- Default values are allowed only when the value is optional.

---

# Outputs

Rules

- Outputs exist only to expose values consumed elsewhere.
- Unused outputs should be removed.

---

# State

Rules

- Every deployment owns an independent Terraform state.
- Runtime communication must not depend on Terraform outputs.

---

# Runtime Values

Rules

Runtime identifiers shared between deployments are stored in AWS Systems Manager Parameter Store.

Terraform outputs are not considered runtime storage.

---

# Formatting

Rules

Terraform code committed to the repository must already be formatted and validated.
