# Flask API with Terraform and Azure Container Apps

A production-ready reference architecture featuring a Python Flask REST API containerized with Docker, deployable to Azure Container Apps (ACA) using Terraform, and automated via a fully integrated GitHub Actions CI/CD pipeline.

---

## 🚀 Features

- **Flask REST API**: A lightweight Python REST API with `/` and `/health` endpoints.
- **Dockerized Application**: Containerized for consistency across local development, Kubernetes, and cloud environments.
- **Infrastructure as Code (IaC)**: Provisioned on Azure using Terraform, following security best practices (e.g., least-privilege managed identity, resource scoping).
- **Kubernetes Ready**: Manifests provided for deploying locally or to an existing Kubernetes cluster.
- **CI/CD Pipeline**: GitHub Actions workflow for linting, testing, building/pushing Docker images to GitHub Container Registry (GHCR), and deploying via Terraform.

---

## 📁 Repository Structure

```text
├── .github/
│   └── workflows/
│       └── ci-cd.yml      # CI/CD pipeline for testing, linting, building, and deploying
├── k8s/
│   └── deployment.yaml   # Kubernetes deployment and service manifests
├── terraform/
│   ├── main.tf            # Azure resources (RG, ACA, LAW, User Managed Identity)
│   ├── outputs.tf         # Outputs (e.g., Application URL)
│   ├── variables.tf       # Variable declarations and default settings
│   └── terraform.tfvars   # Variable overrides (e.g., default container image)
├── app.py                 # Main Flask REST API application
├── test_app.py            # Unit tests for the Flask application using pytest
├── Dockerfile             # Container configuration for packaging the app
├── .dockerignore          # Excluded files for Docker build contexts
├── requirements.txt       # Python dependencies (flask, pytest, flake8)
└── README.md              # Project documentation (this file)
```

---

## ⚙️ Prerequisites

Before you get started, ensure you have the following installed/configured:

- **Python 3.10+**
- **Docker**
- **Terraform (>= 1.0.0)**
- **Azure CLI** (for local Terraform deployment)
- **kubectl** (optional, for Kubernetes deployments)

---

## 🛠️ Local Development

### 1. Python Local Environment Setup

Create a virtual environment and install dependencies:

```bash
# Create a virtual environment
python -m venv venv

# Activate the virtual environment
# On Windows (PowerShell):
.\venv\Scripts\Activate.ps1
# On macOS/Linux:
source venv/bin/activate

# Install requirements
pip install -r requirements.txt
```

### 2. Run the Application

Start the Flask server locally:

```bash
python app.py
```

The application will be accessible at [http://localhost:5000](http://localhost:5000).
- Home Endpoint: `GET /` -> `{"message": "Hello, World!"}`
- Health Endpoint: `GET /health` -> `{"status": "healthy"}`

### 3. Run Tests & Linter

Run tests using `pytest` and code style checking using `flake8`:

```bash
# Run unit tests
pytest

# Run linter
flake8 .
```

---

## 📦 Containerization (Docker)

To build and run the application container locally:

```bash
# Build the Docker image
docker build -t simple-api:latest .

# Run the container
docker run -p 5000:5000 simple-api:latest
```

---

## ☸️ Kubernetes Deployment

Deploy the application to a local (e.g., Minikube, Kind) or remote Kubernetes cluster:

```bash
# Apply deployment and service configuration
kubectl apply -f k8s/deployment.yaml

# Verify resources are running
kubectl get deployments
kubectl get services
```

The Kubernetes service exposes the application on a NodePort at `30080` (TCP/80 container proxy to target port `5000`).

---

## ☁️ Infrastructure Deployment (Terraform)

The Terraform configuration in `terraform/` provisions:
1. **Azure Resource Group**: Logical container for all project assets.
2. **Log Analytics Workspace**: Centralized logging for container application metrics.
3. **Container App Environment**: Secure hosting boundary.
4. **User Assigned Managed Identity**: Security principle configured with zero Azure RBAC permissions to guarantee least-privilege security.
5. **Azure Container App**: The container host running the Flask API on port 5000.

### Prerequisites for Remote Backend
The configuration uses a remote backend in Azure Storage:
```hcl
backend "azurerm" {
  resource_group_name  = "rg-terraform-state"
  storage_account_name = "sttfstatealioth72"
  container_name       = "tfstate"
  key                  = "terraform.tfstate"
}
```
*Note: Ensure the backend resource group, storage account, and container exist in Azure before executing `terraform init`.*

### Deploy Manually

```bash
cd terraform

# Initialize backend and providers
terraform init

# Plan and preview resources
terraform plan

# Apply infrastructure changes
terraform apply -auto-approve
```

The public URL of the deployed Flask REST API will be outputted after execution (e.g. `app_url = https://ca-simple-api.<unique-id>.azurecontainerapps.io`).

---

## 🔄 CI/CD Pipeline (GitHub Actions)

The CI/CD pipeline automated in `.github/workflows/ci-cd.yml` triggers on `push` and `pull_request` to the `main` branch:

1. **`test-and-lint`**: Checks syntax and conventions with `flake8` and runs unit tests via `pytest`.
2. **`build-and-push`**: On push to `main`, builds the container image and publishes it to the GitHub Container Registry (GHCR).
3. **`deploy`**: Deploys the built image using Terraform to Azure Container Apps.

### GitHub Actions Secrets
To enable successful deployment to Azure, add the following secrets to your GitHub Repository settings (`Settings > Secrets and variables > Actions`):

| Secret Name | Description |
| :--- | :--- |
| `AZURE_CLIENT_ID` | Service Principal Client (Application) ID |
| `AZURE_CLIENT_SECRET` | Service Principal Secret Value |
| `AZURE_TENANT_ID` | Directory (Tenant) ID for Azure Subscription |
| `AZURE_SUBSCRIPTION_ID`| Target Azure Subscription ID |
