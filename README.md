# Terraform + GitHub Actions — AWS VPC & EC2 Automation (Dev Environment)

## 🚀 Overview

This project provisions a **development-focused AWS environment** using **Terraform**, backed by a secure remote state (S3 + DynamoDB), and fully automated with **GitHub Actions CI/CD**. It deploys a custom VPC, subnets, and EC2 instances running different user‑data scripts. The setup is production-influenced while remaining lightweight for learning and junior DevOps experience.

This repository demonstrates DevOps skills:

* Infrastructure as Code (Terraform)
* Modular architecture
* AWS networking fundamentals
* CI/CD pipelines (GitHub Actions)
* Secure remote state & state locking
* Debugging real IaC + CI issues
* Clean repo structure & automation best practices

---

## 🧱 Architecture Diagram (High-Level)

```
Developer (push) → GitHub Actions → Terraform → S3 (state) + DynamoDB (lock) → AWS Infrastructure

AWS:
 VPC 10.0.0.0/16
 ├── Internet Gateway
 ├── Public Route Table (0.0.0.0/0 → IGW)
 ├── Public Subnet A (10.0.1.0/24) → EC2 (App1, App2)
 └── Public Subnet B (10.0.2.0/24) → EC2 (App1, App2)
```

> ALB is intentionally disabled due to account permissions, but the design supports enabling it later with a single variable (`enable_alb`).

---

## 📁 Repository Structure

```
infra/
  live/
    dev/
      backend.tf
      backend.hcl
      main.tf
      outputs.tf
      providers.tf
      versions.tf

  modules/
    vpc/
      main.tf
      variables.tf
      outputs.tf

    compute/
      main.tf
      variables.tf
      outputs.tf

.github/workflows/
  terraform.yml   # CI/CD pipeline
```

This layout separates reusable modules from environment-specific configuration.

---

## ⚙️ Features

### **✔ Terraform Infrastructure**

* VPC (10.0.0.0/16)
* Two public subnets across two AZs
* Internet Gateway + public route table
* EC2 instances:

  * Deployed across both subnets
  * Public IPs for testing
  * Two different user-data scripts (App1 vs App2)
* Security groups for inbound/outbound rules

### **✔ Remote State** (Production Standard)

* S3 bucket (versioning + encryption)
* DynamoDB table for Terraform state locking
* Backend defined through `backend.hcl`

### **✔ GitHub Actions CI/CD**

* Runs on PR: `init`, `validate`, `plan`
* Runs on push to `main`: `apply`
* Uses GitHub Secrets for AWS credentials
* Includes identity check (`aws sts get-caller-identity`)
* Handles module changes cleanly with `terraform init`

---

## 🧪 How to Run Locally

From `infra/live/dev`:

```sh
terraform init -backend-config=backend.hcl
terraform plan -var="aws_region=eu-west-2"
terraform apply -var="aws_region=eu-west-2"
```

Get EC2 public IPs:

```sh
terraform output instance_public_ips
```

Destroy:

```sh
terraform destroy -var="aws_region=eu-west-2"
```

---

## 🔄 CI/CD Workflow (terraform.yml)

Key pipeline stages:

* Checkout repo
* Configure AWS credentials
* Terraform installation
* `terraform init` with remote backend
* `terraform validate`
* `terraform plan` / `terraform apply`

Full workflow is available here:

```
.github/workflows/terraform.yml
```

---

## 🧩 Common Issues & Fixes

### **Module changes not detected**

Re-run:

```sh
terraform init
```

### **Security Group DependencyViolation**

Destroy instances first:

```sh
terraform destroy -target=module.compute.aws_instance.web
```

### **ALB OperationNotPermitted**

Added feature flag:

```
variable "enable_alb" {
  default = false
}
```

### **CI creds not loading**

Fixed by adding correct GitHub Secrets and testing with:

```sh
aws sts get-caller-identity
```

---

## 🔐 Security Best Practices

* No credentials in code
* Use GitHub Secrets or OIDC
* S3 bucket must block public access
* DynamoDB used for locking
* Tags added for traceability (Project, Environment, ManagedBy)

---

## 🧭 Why This Project Matters (Career Impact)

This project demonstrates **real DevOps skills** used in production environments:

* Infrastructure as Code (Terraform) with modules
* Cloud architecture design (VPC, subnets, routing)
* Automated CI/CD deployment pipelines
* State management, locking, and backend design
* Debugging and iterative improvements


---

