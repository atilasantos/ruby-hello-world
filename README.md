# Ruby on Rails Hello World Web App

This repository contains a simple **Ruby on Rails** web application that always responds with "Hello World". The app is designed to be easily deployed both **locally** on docker-desktop and on **Amazon EKS** using **Terraform** and **Terragrunt** for infrastructure management.

## Project Structure

### `.iac` Directory
The **Infrastructure as Code (IaC)** for deploying the app is stored in the `.iac` folder. It contains all Terraform and Terragrunt configurations required for deploying the app either locally or on an EKS cluster.

- **`aws/`**: Contains the infrastructure setup for AWS.
  - **`environments/`**: Different environments (`dev`, `qa`, `prod`) with each environment containing:
    - **`eks/`**: Configures the EKS cluster.
    - **`vpc/`**: Configures the Virtual Private Cloud (VPC).
    - **`lovevery-app/`**: The application configuration within EKS.
  
  The structure is designed for ease of use with **Terragrunt** to manage infrastructure across different environments.

- **`local/`**: Contains the local infrastructure setup for running the application with docker-desktop(kubernetes).

### `.helm` Directory
Contains the Helm chart for deploying the **Ruby on Rails Hello World app**. The Helm chart is configured to deploy the app along with the **Nginx Ingress Controller** to expose the application.

- **Helm Chart**: Includes the application’s deployment configuration.
- **Ingress Controller**: Configured as a dependency to expose the app.

### `Makefile`
The Makefile contains the following targets for managing the app's deployment and development process:

- **`docker-build`**: Builds and pushes the Docker image for the application.
- **`docker-run`**: Allows you to run the application as standalone container locally.
- **`helm-package`**: Packages the Helm chart for deployment and pushes it.
- **`helm-run`**: Install the app helm chart in the current context of kubectl.
- **`helm-uninstall`**: Uninstall the app.
- **`add-hosts`**: adds an entry in the /etc/hosts in order to the app be accessed via local.localhost
- **`remove-hosts`**: remove the entries that are created by `add-hosts` target.

## How to Use

### Deploy on EKS
For deployment to **EKS**, follow these steps:

1. Configure your AWS credentials.
2. Navigate to the `.iac/aws` directory.
3. Run Terragrunt to provision the infrastructure:
   ```bash
   terragrunt run-all apply
   ```
4. From the root repo, run `make helm-run`.
5. After succesfully installed run `make add-hosts`.

### Deploy on docker-desktop (kubernetes)
For deployment in a local kubernetes cluster you just have to:

1. Run `make helm-run`.
2. After succesfully installed run `make add-hosts`.

## Questions

1. How would you manage your terraform state file for multiple environments? e.g stage,
prod, demo?
`Answer`: I would adopt a similar approach to what I've implemented for the `.iac/aws` infrastructure. This involves organizing the resources into separate folders for each environment, utilizing modular components. Each module would maintain its own `terraform.tfstate` file, ensuring clear separation and management of state across different environments.

2. How would you approach managing terraform variables and secrets as well?
`Answer`: I prioritize adding validation rules to all variables in my Terraform code, which enhances consistency and reduces the likelihood of errors. Additionally, I organize variables into separate environment-specific `.tfvars` files for better management. For handling secrets, I advocate for using a dedicated secrets manager, such as AWS Secrets Manager, to retrieve values as needed through data sources. This approach ensures that sensitive information is not exposed in version control systems (VCS).

3. Describe at a high level what steps of this infrastructure should be monitored with
example metrics to collect.
`Answer`: From an infrastructure perspective, it is essential to monitor the health of the Kubernetes API endpoint, as well as the CPU, memory, and disk usage of the worker nodes to ensure they are not under excessive pressure. Additionally, we should track the application's uptime, response time, and error rate to maintain optimal performance and reliability.

4. Describe how you would test this infrastructure
`Answer`: Testing Terraform code involves multiple layers to ensure reliability and correctness. First, always run a `terraform plan` before applying any changes to verify that the proposed changes align with your expectations. If you have a GitOps process in place, consider integrating additional steps such as linting with tools like TFLint, security checks with TFsec, and cost estimation using Infracost to gain insights into the potential expenses of your infrastructure. Furthermore, utilizing pre-commit hooks can enhance your workflow by automating tests and security checks for your infrastructure code before they have been deployed, ensuring best practices are consistently followed.