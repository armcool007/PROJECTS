# Terraform + Ansible + Jenkins + Tomcat CI/CD Pipeline

End-to-end pipeline: Jenkins pulls code from GitHub → Terraform provisions an AWS EC2 instance → Terraform hands off to Ansible → Ansible installs Java + Tomcat, configures it, and deploys a Maven web app on it.

## Architecture Flow

```
GitHub Repo
   │  (git pull)
   ▼
Jenkins Pipeline (declarative)
   │  ACTION = apply / destroy
   ▼
Terraform (main.tf)
   │  provisions EC2 (Amazon Linux)
   │  connects via SSH (remote-exec)
   │  triggers Ansible (local-exec)
   ▼
Ansible (tomcat.yml)
   │  installs java-17, wget, tree
   │  downloads + extracts Tomcat 9
   │  configures tomcat-users.xml, context.xml
   │  creates systemd service for Tomcat
   │  packages & deploys maven-web-app.war
   ▼
Running Tomcat App on EC2 (port 8080)
```

## Folder Structure

```
terraform-ansible-jenkins-tomcat-cicd/
├── Jenkinsfile              # Orchestrates the whole pipeline
├── main.tf                  # Terraform: provisions EC2 + triggers Ansible
├── tomcat.yml                # Ansible playbook: installs & configures Tomcat
├── tomcat-users.xml          # Tomcat manager credentials config
├── context.xml                # Tomcat manager app access config
├── maven-web-app/             # Unpacked app source (used for zipping)
├── maven-web-app.war          # Built WAR file to deploy on Tomcat
└── README.md
```

## Prerequisites

- Jenkins server with Terraform, Ansible, and AWS CLI installed
- AWS credentials configured on the Jenkins agent
- `/etc/ansible/awspractice36.pem` present on the Jenkins/Ansible controller with correct permissions (`chmod 400`)
- An existing AWS key pair named `awspractice36`
- Ansible installed on the same machine that runs `terraform apply` (since `local-exec` calls `ansible-playbook` directly)

## How to Run

1. Open the Jenkins job → **Build with Parameters**
2. Choose `ACTION`:
   - `apply` → provisions the EC2 instance, installs Tomcat, deploys the app
   - `destroy` → tears down the EC2 instance
3. Monitor console output for the Ansible playbook run (Terraform's `local-exec` output shows here)
4. Once complete, access the app at `http://<ec2-public-or-private-ip>:8080/maven-web-app`

## Notes / Gotchas

- The `connection` block inside the `aws_instance` resource uses `self.private_ip` — this only works if Jenkins/Terraform runs from a machine inside the same VPC (or has private IP access), otherwise switch to `self.public_ip`.
- `remote-exec` just verifies SSH connectivity; the actual Tomcat setup work happens entirely in the `local-exec` → Ansible step.
- Ansible's `archive` task uses `delegate_to: localhost` + `become: no` to zip the app on the **Ansible controller**, not on the remote EC2 instance.
- First Jenkins build won't show "Build with Parameters" until the `parameters{}` block has been scanned once — run the job once, then it appears on subsequent runs.
