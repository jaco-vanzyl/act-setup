# Act Setup

This repository provides a setup for running GitHub Actions workflows locally using `act` with Rancher Desktop as the container and Kubernetes runtime. It includes scripts to install and clean up `act` and a sample workflow to test connectivity to a local Kubernetes cluster by running `kubectl get nodes`.

## Repository Structure
```
act-setup/
├── .github/
│   └── workflows/
│       └── sample-workflow.yaml
├── scripts/
│   ├── install-act.sh
│   └── cleanup-act.sh
├── LICENSE
└── README.md
```

## Prerequisites
- **Rancher Desktop**: Provides Docker and Kubernetes.
- **Git**: For cloning the repository.
- **curl**: For downloading `act` and `kubectl` (installed in the workflow for `kubectl`).
- **Base64-encoded kubeconfig**: Required for Kubernetes access in the workflow.

## Setup Instructions

### 1. Install Rancher Desktop
Rancher Desktop provides Docker and Kubernetes on your laptop.

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

### 2. Clone the Repository
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

### 4. Configure act Images
To ensure compatibility and avoid issues like DNS resolution errors, configure the `act` runner images.

- Create or edit the `actrc` file:
  - **macOS**:
    ```bash
    mkdir -p ~/Library/Application\ Support/act
    nano ~/Library/Application\ Support/act/actrc
    ```
  - **Linux**:
    ```bash
    mkdir -p ~/.act
    nano ~/.act/actrc
    ```
  - **Windows**:
    ```bash
    mkdir %USERPROFILE%\.act
    notepad %USERPROFILE%\.act\actrc
    ```
- Add the following lines to `actrc`:
  ```
  -P ubuntu-latest=catthehacker/ubuntu:act-latest
  -P ubuntu-22.04=catthehacker/ubuntu:act-22.04
  -P ubuntu-20.04=catthehacker/ubuntu:act-20.04
  -P ubuntu-18.04=catthehacker/ubuntu:act-18.04
  ```
- These images (from `catthehacker/ubuntu`) are optimized for `act` and resolve networking issues seen with default images.

### 5. Configure Secrets
Create a `.secrets` file to simulate GitHub secrets for the sample workflow.

- In the `act-setup` directory, create and populate the `.secrets` file with the base64-encoded kubeconfig:
  ```bash
  echo "KUBE_CONFIG=$(cat ~/.kube/config | base64)" > .secrets
  ```
- For Windows, use PowerShell to encode:
  ```powershell
  [Convert]::ToBase64String([IO.File]::ReadAllBytes("$HOME\.kube\config")) | Set-Content .secrets -Encoding UTF8
  ```
  Then edit `.secrets` to prepend `KUBE_CONFIG=` to the encoded output.
- Verify the `.secrets` file contains the encoded kubeconfig:
  ```bash
  cat .secrets
  ```

### 6. Test act with the Sample Workflow
Test `act` with the sample workflow to verify Kubernetes connectivity.

- Run with automatic container cleanup:
  ```bash
  act -W .github/workflows/sample-workflow.yaml --secret-file .secrets --rm
  ```
- The `--rm` flag removes Docker containers after execution. The workflow downloads `kubectl` using `curl`, configures the kubeconfig, and runs `kubectl get nodes`. Check the output for node information.
- **Note on kubectl Download Path**:
  - The workflow uses `curl -LO "https://dl.k8s.io/release/v1.33.2/bin/linux/arm64/kubectl"` for ARM64 systems (e.g., Apple Silicon Macs). For x86_64 systems, update the path to `bin/linux/amd64/kubectl` in `.github/workflows/sample-workflow.yaml`. Confirm your host architecture:
    ```bash
    uname -m
    ```
    - Output `arm64` or `aarch64`: Use `bin/linux/arm64/kubectl`.
    - Output `x86_64`: Use `bin/linux/amd64/kubectl`.

### 7. Cleanup act
If you need to remove `act` and its associated Docker resources, use the provided cleanup script.

- **Make the script executable**:
  ```bash
  chmod +x scripts/cleanup-act.sh
  ```
- **Run the script**:
  ```bash
  ./scripts/cleanup-act.sh
  ```
- **Windows Users**:
  - Manually remove the `act` binary from your PATH.
  - Delete the `%USERPROFILE%\.act` directory if it exists.
  - Clean up Docker containers and images using PowerShell (see Troubleshooting for details).

## Troubleshooting
- **"act not found"**:
  - Verify `act` is installed:
    ```bash
    act --version
    ```
    If not found, reinstall:
    ```bash
    ./scripts/install-act.sh
    ```
  - Ensure `/usr/local/bin` is in your PATH:
    ```bash
    echo $PATH
    ```
    Add it if missing:
    ```bash
    export PATH=$PATH:/usr/local/bin
    echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
    source ~/.bashrc
    ```
  - Check for residual files:
    ```bash
    ls /usr/local/bin/act
    ls ~/.act
    ```
    Remove manually if needed:
    ```bash
    sudo rm -f /usr/local/bin/act
    rm -rf ~/.act
    ```
- **Rancher Desktop**:
  - Ensure Kubernetes is enabled in the Rancher Desktop UI.
  - Verify connectivity:
    ```bash
    kubectl cluster-info
    ```
  - If Docker isn’t working, restart Rancher Desktop or verify the container runtime:
    - Linux/macOS:
      ```bash
      systemctl --user restart rancher-desktop
      ```
    - Windows: Restart via the Rancher Desktop UI.
- **Kubernetes Connection Errors**:
  - Ensure the kubeconfig is valid:
    ```bash
    kubectl --kubeconfig ~/.kube/config get nodes
    ```
  - Verify the base64-encoded `KUBE_CONFIG` in `.secrets`:
    ```bash
    cat .secrets | grep KUBE_CONFIG | cut -d'=' -f2 | base64 -d > test-config
    kubectl --kubeconfig test-config get nodes
    ```
    If it fails, regenerate the base64-encoded kubeconfig:
    ```bash
    echo "KUBE_CONFIG=$(cat ~/.kube/config | base64)" > .secrets
    ```
    For Windows:
    ```powershell
    [Convert]::ToBase64String([IO.File]::ReadAllBytes("$HOME\.kube\config")) | Set-Content .secrets -Encoding UTF8
    ```
    Then edit `.secrets` to prepend `KUBE_CONFIG=` to the encoded output.
  - Ensure Rancher Desktop’s Kubernetes cluster is running (check UI status).
- **kubectl Installation Error (e.g., "NoSuchKey" or "syntax error")**:
  - Verify the `curl` command in `sample-workflow.yaml` uses the correct architecture path:
    - ARM64: `https://dl.k8s.io/release/v1.33.2/bin/linux/arm64/kubectl`
    - x86_64: `https://dl.k8s.io/release/v1.33.2/bin/linux/amd64/kubectl`
  - Test the download URL locally:
    ```bash
    curl -LO https://dl.k8s.io/release/v1.33.2/bin/linux/arm64/kubectl
    file kubectl
    ```
    The output should include "ELF 64-bit LSB executable, ARM aarch64" (or "x86-64" for x86_64).
  - Test in a Docker container:
    ```bash
    docker run --rm catthehacker/ubuntu:act-latest bash -c "curl -LO https://dl.k8s.io/release/v1.33.2/bin/linux/arm64/kubectl && file kubectl"
    ```
- **Cleaning up act Docker containers**:
  - Use the `--rm` flag to automatically remove containers after execution:
    ```bash
    act -W .github/workflows/sample-workflow.yaml --secret-file .secrets --rm
    ```
  - If containers persist (e.g., due to interruption), run the cleanup script:
    ```bash
    ./scripts/cleanup-act.sh
    ```

## Notes
- **Security**: The `.secrets` file contains sensitive kubeconfig data. Ensure it’s not committed (add to `.gitignore`).
- **act Limitations**: Some GitHub Actions features may not work perfectly in `act`. The sample workflow is simple and compatible.
- **Windows Users**: The `install-act.sh` and `cleanup-act.sh` scripts are for Linux/macOS. For Windows, download the `act` binary from [act releases](https://github.com/nektos/act/releases) and manually manage installation/cleanup. Use PowerShell for `.secrets` creation and Docker cleanup (see Troubleshooting).
- **Kubernetes Context**: The workflow uses the base64-encoded kubeconfig from `KUBE_CONFIG`. Ensure it matches Rancher Desktop’s context.
- **kubectl Architecture**: Confirm the correct `kubectl` binary path (`arm64` or `amd64`) based on your system architecture. The sample workflow uses `arm64` for Apple Silicon Macs; adjust to `amd64` for x86_64 systems if needed.

For further assistance, see the [act documentation](https://github.com/nektos/act) or [Rancher Desktop documentation](https://docs.rancherdesktop.io/).