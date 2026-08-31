# Infrastructure as Code (IaC): AWS Budgeted Identity & Least-Privilege Architecture

An automated AWS infrastructure provisioning project using HashiCorp Terraform. This project demonstrates strict financial guardrails, dynamic S3 storage provisioning, surgical IAM least-privilege policy engineering, and automated EC2 deployment for a enterprise financial architecture.

---

## 🔒 Executive Summary & Scenario

As Lead Cloud Security Architect for "Titan FinTech," this infrastructure was designed to mitigate two primary cloud operational risks:
1. **Denial of Wallet Attacks:** Mitigated by setting hard financial thresholds and real-time email alert notifications via AWS Budgets.
2. **Credential Compromise & Over-Privileged Access:** Mitigated by engineering a custom, least-privilege IAM role using Terraform dynamic resource referencing (interpolating the S3 bucket ARN rather than hardcoding) to enforce strict access control.

---

## 🛠️ Infrastructure & Key Components

### 1. Financial Guardrails (`aws_budgets_budget`)
* Provisioned an AWS Budget enforcing a **$10.00 USD monthly hard limit**.
* Configured automated email notifications triggered at an **80% threshold ($8.00 USD)** to prevent unbudgeted cloud expenditure.

### 2. Encrypted Storage Vault (`aws_s3_bucket`)
* Created a private S3 bucket dynamically named using a hex identifier (`titan-fintech-vault-gjl-${random_id.id.hex}`).
* Enforced default private access controls to prevent accidental exposure of enterprise data.

### 3. Surgical IAM Role & Least-Privilege Policy (`aws_iam_role` & `aws_iam_policy`)
* Built the `Titan-EC2-Vault-Role` IAM role with an EC2 service trust policy (`ec2.amazonaws.com`).
* Attached a custom inline JSON policy permitting strictly `s3:PutObject` operations scoped specifically to the provisioned vault S3 bucket ARN via Terraform interpolation.

### 4. Secure Compute Provisioning (`aws_instance` & `aws_iam_instance_profile`)
* Deployed an Ubuntu `t2.micro` EC2 compute instance attached to the custom `Titan-EC2-Vault-Role` via an IAM instance profile.

---

## 💻 Tech Stack & Tools

* **Infrastructure as Code (IaC):** HashiCorp Terraform (HCL)
* **Cloud Provider:** Amazon Web Services (AWS)
* **AWS Services:** IAM, S3, EC2, AWS Budgets
* **Version Control:** Git, GitHub

---

## 📸 Deliverables & Proof of Execution

The repository contains full visual verification of the infrastructure deployment lifecycle:

* **Build Success:** `build_success.png` — Screenshot confirming `terraform apply` completion and resource creation.
* **Security Audit:** `security_audit.png` — AWS Management Console capture verifying the running EC2 instance attached to `Titan-EC2-Vault-Role`.
* **Resource Cleanup:** `destroy_verification.png` — Verification of full resource teardown via `terraform destroy` (`Resources: 0 added, 0 changed, X destroyed`).

