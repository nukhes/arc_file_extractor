#!/bin/bash

# Arc File Extractor Installation Script
# Supports Ubuntu/Debian, Fedora/RHEL/CentOS, Arch Linux, and macOS

set -e

# output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # nc stands for no color
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case $ID in
                ubuntu|debian)
                    OS="debian"
                    ;;
                fedora|rhel|centos|rocky|almalinux)
                    OS="fedora"
                    ;;
                arch|manjaro)
                    OS="arch"
                    ;;
                *)
                    OS="unknown"
                    ;;
            esac
        else
            OS="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        OS="unknown"
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install dependencies on Ubuntu/Debian
install_debian_deps() {
    print_status "Installing dependencies for Ubuntu/Debian..."
    
    # Update package list
    sudo apt update
    
    # Install required packages
    sudo apt install -y unzip tar gzip bzip2 xz-utils p7zip-full zip python3 python3-pip
    
    # Try to install unrar (may not be available in all repos)
    if ! sudo apt install -y unrar 2>/dev/null; then
        print_warning "unrar not available in default repositories. Installing unrar-free..."
        sudo apt install -y unrar-free || print_warning "Could not install unrar. RAR extraction may not work."
    fi
}

# Function to install dependencies on Fedora/RHEL/CentOS
install_fedora_deps() {
    print_status "Installing dependencies for Fedora/RHEL/CentOS..."
    
    # Determine package manager probably yum is useless now
    if command_exists dnf; then
        PKG_MGR="dnf"
    elif command_exists yum; then
        PKG_MGR="yum"
    else
        print_error "Neither dnf nor yum found. Cannot install dependencies."
        exit 1
    fi
    
    # idk if fedora has unrar in default repos
    sudo $PKG_MGR install -y unzip tar gzip bzip2 xz p7zip zip python3 python3-pip
    if ! sudo $PKG_MGR install -y unrar 2>/dev/null; then
        print_warning "unrar not available. You may need to enable RPM Fusion or EPEL repositories for RAR support."
    fi
}

# Function to install dependencies on Arch Linux
install_arch_deps() {
    print_status "Installing dependencies for Arch Linux..."
    sudo pacman -Sy
    sudo pacman -S --needed --noconfirm unrar unzip tar gzip bzip2 xz p7zip zip python python-pip python-pipx
}

# Function to install dependencies on macOS
install_macos_deps() {
    print_status "Installing dependencies for macOS..."
    
    if ! command_exists brew; then
        print_status "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install p7zip unrar zip
    
    # Python should be available on macOS oobe
}

# Function to install Arc File Extractor
install_arc_extractor() {
    print_status "Installing Arc File Extractor..."
    
    # Check if pip is available
    if command_exists pip3; then
        PIP_CMD="pip3"
    elif command_exists pip; then
        PIP_CMD="pip"
    if command_exists pipx; then # pipx is nedded for archlinux
        PIP_CMD="pipx"
    else
        print_error "pip not found. Please install pip and try again."
        exit 1
    fi
    
    # Install Arc File Extractor
    $PIP_CMD install --user arc-file-extractor
    
    # Check if installation was successful
    if command_exists arc; then
        print_success "Arc File Extractor installed successfully!"
    else
        print_warning "Arc File Extractor was installed but 'arc' command is not in PATH."
        print_warning "You may need to add ~/.local/bin to your PATH or use:"
        print_warning "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
}

# Function to verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    # Check Arc File Extractor
    if command_exists arc; then
        print_success "✓ Arc File Extractor is installed"
        arc --help | head -n 3
    else
        print_error "✗ Arc File Extractor not found in PATH"
        return 1
    fi
    
    # Check dependencies
    print_status "Checking dependencies..."
    
    local missing_deps=()
    
    # Check required tools
    for tool in unzip tar gzip bzip2 xz zip; do
        if command_exists $tool; then
            print_success "✓ $tool is available"
        else
            print_error "✗ $tool is missing"
            missing_deps+=($tool)
        fi
    done
    
    # Check optional tools
    for tool in 7z unrar; do
        if command_exists $tool; then
            print_success "✓ $tool is available"
        else
            print_warning "⚠ $tool is missing (optional)"
        fi
    done
    
    if [ ${#missing_deps[@]} -eq 0 ]; then
        print_success "All required dependencies are installed!"
        return 0
    else
        print_error "Missing dependencies: ${missing_deps[*]}"
        return 1
    fi
}

# Function to show usage
show_usage() {
    echo "Arc File Extractor Installation Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -d, --deps-only         Install only system dependencies"
    echo "  -a, --arc-only          Install only Arc File Extractor (skip dependencies)"
    echo "  -v, --verify            Verify installation"
    echo "  -f, --force             Force installation even if already installed"
    echo ""
    echo "Supported systems:"
    echo "  - Ubuntu/Debian"
    echo "  - Fedora/RHEL/CentOS"
    echo "  - Arch Linux/Manjaro"
    echo "  - macOS"
    echo ""
}

# Main function
main() {
    local deps_only=false
    local arc_only=false
    local verify_only=false
    local force=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -d|--deps-only)
                deps_only=true
                shift
                ;;
            -a|--arc-only)
                arc_only=true
                shift
                ;;
            -v|--verify)
                verify_only=true
                shift
                ;;
            -f|--force)
                force=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Show header
    echo "========================================"
    echo "    Arc File Extractor Installer"
    echo "========================================"
    echo ""
    
    # Verify only
    if [ "$verify_only" = true ]; then
        verify_installation
        exit $?
    fi
    
    # Detect OS
    detect_os
    print_status "Detected OS: $OS"
    
    if [ "$OS" = "unknown" ]; then
        print_error "Unsupported operating system. Please install dependencies manually."
        exit 1
    fi
    
    # Check if Arc File Extractor is already installed
    if [ "$force" = false ] && [ "$deps_only" = false ] && command_exists arc; then
        print_warning "Arc File Extractor is already installed. Use --force to reinstall."
        arc --help | head -n 3
        exit 0
    fi
    
    # Install dependencies
    if [ "$arc_only" = false ]; then
        case $OS in
            debian)
                install_debian_deps
                ;;
            fedora)
                install_fedora_deps
                ;;
            arch)
                install_arch_deps
                ;;
            macos)
                install_macos_deps
                ;;
        esac
        
        print_success "Dependencies installed successfully!"
    fi
    
    # Install Arc File Extractor
    if [ "$deps_only" = false ]; then
        install_arc_extractor
    fi
    
    # Verify installation
    echo ""
    verify_installation
    
    # Show final message
    echo ""
    print_success "Installation complete!"
    echo ""
    echo "You can now use Arc File Extractor with:"
    echo "  arc x archive.zip    # Extract files"
    echo "  arc c directory/     # Compress files"
    echo "  arc --help           # Show help"
    echo ""
    echo "If 'arc' command is not found, add ~/.local/bin to your PATH:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
}

# Run main function
main "$@"
