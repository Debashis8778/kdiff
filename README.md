# kdiff - Kubernetes Resource Differ

A tool to compare Kubernetes resources between different namespaces, making it easy to spot differences across environments.

## Features

- 🔍 Compare Kubernetes resources between any two namespaces
- 🎨 Colored diff output for better readability
- 🧹 Optional `kubectl neat` integration to clean output
- 📊 Multiple output formats (unified, context, side-by-side)
- 🔧 Support for all Kubernetes resource types
- 📝 Verbose logging for debugging

## Installation

### 🚀 Quick Install (Recommended)

#### Unix/Linux/macOS
```bash
curl -sSL https://raw.githubusercontent.com/rajamohan-rj/kdiff/main/install.sh | bash
```

#### Windows (PowerShell)
```powershell
iwr -useb https://raw.githubusercontent.com/rajamohan-rj/kdiff/main/install.ps1 | iex
```

### 📦 Package Managers

#### Using Go
```bash
go install github.com/rajamohan-rj/kdiff@latest
```

#### Using Homebrew (macOS/Linux)
```bash
# Add the tap (after setting up Homebrew tap)
brew tap rajamohan-rj/tap
brew install kdiff
```

### 🛠️ Advanced Installation

#### Install to custom directory
```bash
# Unix/Linux/macOS
curl -sSL https://raw.githubusercontent.com/rajamohan-rj/kdiff/main/install.sh | bash -s -- --dir ~/.local/bin

# Windows
iwr -useb https://raw.githubusercontent.com/rajamohan-rj/kdiff/main/install.ps1 | iex -InstallDir 'C:\tools'
```

#### Install specific version
```bash
# Unix/Linux/macOS
curl -sSL https://raw.githubusercontent.com/rajamohan-rj/kdiff/main/install.sh | bash -s -- --version v0.1.0

# Windows
iwr -useb https://raw.githubusercontent.com/rajamohan-rj/kdiff/main/install.ps1 | iex -Version 'v0.1.0'
```

### 📥 Manual Download

Download the latest binary from [releases](https://github.com/rajamohan-rj/kdiff/releases) and extract.

## Usage

```bash
# Compare deployments between staging and production
kdiff staging my-app production my-app

# Compare services with verbose output
kdiff --verbose dev my-service prod my-service

# Compare without colored output
kdiff --no-color namespace1 deployment/app namespace2 deployment/app

# Use context diff format
kdiff --output context ns1 svc/api ns2 svc/api

# Compare with side-by-side format and skip kubectl neat
kdiff --output side-by-side --no-neat ns1 pod/web ns2 pod/web
```

## Options

- `--no-color` - Disable colored output
- `--no-neat` - Skip kubectl neat processing  
- `--output` - Output format (unified, context, side-by-side)
- `--verbose` - Enable verbose logging
- `--version` - Show version information

## Prerequisites

- `kubectl` command-line tool
- `kubectl neat` plugin (optional, for cleaner YAML output)
- `colordiff` (optional, for colored output)

## How it works

1. Retrieves the specified resource from the first namespace using `kubectl get`
2. Retrieves the specified resource from the second namespace
3. Optionally processes the YAML through `kubectl neat` to remove cluster-specific metadata
4. Performs a diff between the two YAML files
5. Optionally colorizes the output using `colordiff`

## License

MIT License - see [LICENSE](LICENSE) file for details.
