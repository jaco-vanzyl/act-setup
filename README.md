# Act Setup Repository

This repository provides a setup for running GitHub Actions workflows locally using `act` with Rancher Desktop as the container and Kubernetes runtime. It includes a script to install `act` and a sample workflow to test the setup. This is particularly useful for testing workflows locally.

## Repository Structure
```
act-setup/
├── .github/
│   └── workflows/
│       └── sample-workflow.yaml
├── scripts/
│   └── install-act.sh
├── LICENSE
└── README.md
```

## Prerequisites
- **Rancher Desktop**: Provides Docker and Kubernetes (Alternates are Minikube or Docker Desktop).
- **Git**: For cloning repositories.
- **Kubeclt**: For interactibg with Kubernetes.
- **curl**: For downloading `act`.

## Setup Instructions

### 1. Install Rancher Desktop
Rancher Desktop is an open-source tool that provides Docker and Kubernetes on your laptop.

- **Download and Install**:
  - Go to [Rancher Desktop downloads](https://rancherdesktop.io/).
  - Download the version for your OS (Linux, macOS, or Windows).
  - Install following the instructions:
    - **Linux**: Install the `.deb` or `.rpm` package (e.g., `sudo apt install ./rancher-desktop_*.deb`).
    - **macOS**: Drag the app to Applications.
    - **Windows**: Run the installer.
- **Start Rancher Desktop**:
  - Launch Rancher Desktop.
  - In the UI, go to **Kubernetes Settings** and enable Kubernetes.
  - Choose a container runtime (e.g., `containerd` or `dockerd`).
  - Wait for Kubernetes to start (check **Cluster Status** in the UI).
- **Verify**:
  ```bash
  kubectl cluster-info
  ```
  Ensure `~/.kube/config` is updated with the Rancher Desktop Kubernetes context.

### 2. Clone Repositories
- Clone this repository:
  ```bash
  git clone https://github.com/your-org/act-setup.git
  cd act-setup
  ```

### 3. Install act
Use the provided script to install `act`.

- **Make the script executable**:
  ```bash
  chmod +x scripts/install-act.sh
  ```
- **Run the script**:
  ```bash
  ./scripts/install-act.sh
  ```
- **Verify**:
  ```bash
  act --version
  ```

### 4. Test act with the Sample Workflow
Test `act` with the sample workflow in this repository to ensure it’s working.

- Run:
  ```bash
  cd ../act-setup
  act -W .github/workflows/sample-workflow.yaml

## Troubleshooting
- **Rancher Desktop**:
  - Ensure Kubernetes is enabled in the Rancher Desktop UI.
  - Check `kubectl cluster-info` for connectivity.
  - If Docker isn’t working, restart Rancher Desktop or verify the container runtime.
- **act**:
  - Ensure the local bin path exists in case of `mv: rename ./bin/act to /usr/local/bin/act: No such file or directory`.

## Notes
For further assistance, see the [act documentation](https://github.com/nektos/act) or [Rancher Desktop documentation](https://docs.rancherdesktop.io/).