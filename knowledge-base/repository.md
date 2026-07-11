---
title: Repository Structure
version: 1.0
---

# Repository Structure

This document defines the repository organization used throughout this project.

The repository structure is considered part of the project contract.

Every contributor and every AI review must follow these rules.

---

# Root Layout

The repository is divided into the following top-level directories.

modules/

Reusable Terraform modules.

environments/

Deployable Terraform stacks.

scripts/

Automation scripts.

.github/

GitHub workflows.

knowledge-base/

Project-specific documentation used by the AI review process.

---

# Modules

The modules directory contains reusable infrastructure components.

Rules

- Every reusable infrastructure component belongs inside modules/.
- Modules must never represent complete deployments.
- Modules must remain independent.
- Modules communicate only through variables and outputs.
- Modules must never reference another module directly.

---

# Environments

The environments directory contains deployable infrastructure.

Rules

- Every deployment owns its own Terraform state.
- Every environment configures its own providers.
- Every environment configures its own backend.
- Environments may consume module outputs.
- Environments may consume remote state only when required by another deployment layer.

---

# Scripts

The scripts directory contains operational automation.

Rules

- Scripts must never contain infrastructure definitions.
- Scripts may interact with deployed infrastructure.
- Scripts must remain independent from Terraform modules.

---

# Knowledge Base

The knowledge-base directory contains project-specific information.

Rules

- Documentation must describe this project only.
- Public documentation must not be duplicated.
- Information already known by foundation models must not be stored here.

---

# General Rules

- Infrastructure code belongs only inside modules or environments.
- Operational logic belongs only inside scripts.
- Documentation belongs only inside knowledge-base.
- GitHub workflows belong only inside .github/workflows.
