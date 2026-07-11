---
service: terraform
category: language
topic: overview
version: 1.0
---

# Terraform Language Overview

## Purpose

Terraform is an Infrastructure as Code (IaC) language used to provision,
update, and destroy infrastructure resources through declarative
configuration.

Terraform describes the desired infrastructure state instead of the
individual steps required to build it.

---

# Core Principles

Terraform follows five main principles.

## Declarative

Terraform describes the desired final state.

Terraform automatically determines the required operations.

Example

```hcl
resource "aws_s3_bucket" "logs" {

  bucket = "company-logs"

}
```

The configuration does not describe how AWS should create the bucket.

It only describes the desired result.

---

## Immutable Infrastructure

Infrastructure should be replaced instead of manually modified whenever
possible.

Replacing infrastructure improves consistency and repeatability.

---

## State Management

Terraform stores the current infrastructure state inside a state file.

The state file is used to calculate differences between:

- Current infrastructure
- Desired infrastructure

---

## Dependency Graph

Terraform automatically builds a dependency graph.

Example

```hcl
resource "aws_subnet" "private" {

  vpc_id = aws_vpc.main.id

}
```

Terraform automatically creates the VPC before the subnet.

---

## Idempotency

Applying the same configuration multiple times should produce the same
result.

Running

terraform apply

multiple times should not recreate unchanged resources.

---

# Main Configuration Blocks

Terraform configurations are composed of several block types.

## terraform

Defines backend configuration and required providers.

## provider

Defines cloud providers.

## resource

Creates infrastructure resources.

## data

Reads existing infrastructure.

## module

Reuses infrastructure code.

## variable

Defines configurable inputs.

## output

Exports values.

## locals

Defines local expressions.

---

# Typical Workflow

1. terraform init

Downloads providers and configures the backend.

2. terraform fmt

Formats configuration.

3. terraform validate

Validates configuration.

4. terraform plan

Calculates infrastructure changes.

5. terraform apply

Applies infrastructure changes.

6. terraform destroy

Destroys managed infrastructure.

---

# Best Practices

- Store Terraform state remotely.
- Never edit state files manually.
- Use modules to reduce duplication.
- Keep configurations small.
- Prefer explicit variables.
- Format every file using terraform fmt.
- Validate every configuration before applying.
- Review every execution plan before deployment.

---

# Common Mistakes

- Storing state locally.
- Hardcoding secrets.
- Using mutable manual changes outside Terraform.
- Creating circular dependencies.
- Ignoring terraform plan output.
- Sharing state files manually.

---

# Related Topics

- Modules
- Providers
- State
- Variables
- Outputs
- Backend
