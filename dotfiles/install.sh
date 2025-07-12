#!/bin/bash

# Dotfiles Installation Script
# i3 Ricing Setup for Arch Linux
# Automated setup for complete i3 desktop environment

set -e

# =================================
# COLORS AND FORMATTING
# =================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Icons
CHECKMARK="\u2713"
CROSS="\u2717"
ARROW="\u2192"
STAR="\u2605"

# =================================
# LOGGING FUNCTIONS
# =================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[${CHECKMARK}]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[${CROSS}]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[${ARROW}]${NC} $1"
}

# =================================
# UTILITY FUNCTIONS
# =================================

print_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
    ╔════════════════════════════════════════════════════════════╗
    ║                                                          ║
    ║               Arch Linux i3 Ricing Setup                 ║
    ║           Ultimate i3 Desktop Environment Installer      ║
    ║                                                          ║
    ║                                                          ║
    ║                                                          ║
    ╚════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

confirm() {
    while true; do
        read -p "$1 [y/N]: " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            "" ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

create_backup() {
    local file="$1"
    if [[ -f "$file" ]] || [[ -d "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        log_warning "Backing up existing $file to $backup"
        mv "$file" "$backup"
    fi
}

# =================================
# PACKAGE INSTALLATION
# =================================

install_packages() {
    log_step "Installing essential packages for i3..."
    
    # Define package arrays
    local official_packages=(
        # Desktop environment
        "i3-wm" "i3status" "dmenu" "picom" "feh" "xorg" "xorg-xinit" "xterm"
        
        # System tools
        "git" "curl" "wget" "unzip" "zip" "tar"
        "htop" "neofetch" "tree" "which" "fd" "ripgrep"
        "bat" "exa" "zsh" "starship" "fzf" "zoxide"
        
        # Development
        "base-devel" "python" "python-pip" "nodejs" "npm"
        "go" "rustup" "docker" "docker-compose"
        
        # Media and graphics
        "pavucontrol" "playerctl" "pamixer"
        
        # File management
        "thunar" "gvfs" "ntfs-3g" "tumbler" "ffmpegthumbnailer"
        
        # Fonts
        "ttf-jetbrains-mono" "ttf-fira-code" "noto-fonts"
        "noto-fonts-emoji" "ttf-liberation" "ttf-dejavu"
        
        # Network
        "networkmanager" "nm-connection-editor" "bluetooth"
        "bluez" "bluez-utils" "blueman"
        
        # Archive support
        "p7zip" "unrar" "lzop" "cpio"
        
        # Image viewers and editors
        "imv" "gimp" "inkscape"
        
        # Document readers
        "zathura" "zathura-pdf-mupdf"
        
        # System monitoring
        "iotop" "nethogs" "lsof" "strace"
    )
    
    # Update system first
    log_step "Updating system packages..."
    sudo pacman -Syu --noconfirm
    
    # Install official packages
    log_step "Installing official packages..."
    for package in "${official_packages[@]}"; do
        if ! pacman -Qi "$package" &> /dev/null; then
            log_info "Installing $package..."
            sudo pacman -S --noconfirm "$package" || log_warning "Failed to install $package"
        else
            log_success "$package already installed"
        fi
    done
    
    log_success "Package installation completed"
}

# =================================
# DOTFILES SETUP
# =================================

setup_dotfiles() {
    log_step "Setting up i3 dotfiles..."
    
    local dotfiles_dir="$HOME/.config"
    local backup_dir="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
    
    # Create backup of existing config
    if [[ -d "$dotfiles_dir/i3" ]]; then
        log_warning "Backing up existing i3 configuration to $backup_dir"
        cp -r "$dotfiles_dir/i3" "$backup_dir"
    fi
    
    # Create necessary directories
    mkdir -p "$HOME/.config/i3"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.local/share"
    mkdir -p "$HOME/.cache"
    
    # Copy i3 configuration files (Neural Nine base)
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local config_source="$script_dir/../config/i3"
    
    if [[ -d "$config_source" ]]; then
        log_step "Copying i3 configuration files..."
        cp -r "$config_source"/* "$HOME/.config/i3/"
        log_success "i3 configuration installed"
    else
        log_error "i3 configuration source directory not found: $config_source"
        return 1
    fi
    
    log_success "Dotfiles setup completed"
}

# =================================
# SHELL SETUP
# =================================

setup_shell() {
    log_step "Setting up shell environment..."
    
    # Install Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_step "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        log_success "Oh My Zsh installed"
    else
        log_success "Oh My Zsh already installed"
    fi
    
    # Install Zsh plugins
    local zsh_custom="$HOME/.oh-my-zsh/custom"
    
    # zsh-autosuggestions
    if [[ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]]; then
        log_step "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions"
        log_success "zsh-autosuggestions installed"
    fi
    
    # zsh-syntax-highlighting
    if [[ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]]; then
        log_step "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$zsh_custom/plugins/zsh-syntax-highlighting"
        log_success "zsh-syntax-highlighting installed"
    fi
    
    # zsh-completions
    if [[ ! -d "$zsh_custom/plugins/zsh-completions" ]]; then
        log_step "Installing zsh-completions..."
        git clone https://github.com/zsh-users/zsh-completions "$zsh_custom/plugins/zsh-completions"
        log_success "zsh-completions installed"
    fi
    
    # Change default shell to zsh
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        log_step "Changing default shell to zsh..."
        chsh -s "$(which zsh)"
        log_success "Default shell changed to zsh"
    else
        log_success "Zsh is already the default shell"
    fi
    
    # Install Starship
    if ! command_exists starship; then
        log_step "Installing Starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
        log_success "Starship prompt installed"
    else
        log_success "Starship prompt already installed"
    fi
    
    log_success "Shell environment setup completed"
}

# =================================
# SERVICES SETUP
# =================================

setup_services() {
    log_step "Setting up system services..."
    
    # Enable NetworkManager
    sudo systemctl enable --now NetworkManager
    log_success "NetworkManager enabled"
    
    # Enable Bluetooth
    sudo systemctl enable --now bluetooth
    log_success "Bluetooth enabled"
    
    # Enable Docker
    if command_exists docker; then
        sudo systemctl enable --now docker
        sudo usermod -aG docker "$USER"
        log_success "Docker enabled and user added to docker group"
    fi
    
    # Enable trim for SSDs
    sudo systemctl enable fstrim.timer
    log_success "SSD trim timer enabled"
    
    # Enable time synchronization
    sudo systemctl enable --now systemd-timesyncd
    log_success "Time synchronization enabled"
    
    log_success "System services setup completed"
}

# =================================
# FONTS SETUP
# =================================

setup_fonts() {
    log_step "Setting up fonts..."
    
    # Create fonts directory
    mkdir -p "$HOME/.local/share/fonts"
    
    # Update font cache
    fc-cache -fv
    
    log_success "Fonts setup completed"
}

# =================================
# GIT SETUP
# =================================

setup_git() {
    log_step "Setting up Git configuration..."
    
    # Check if git is already configured
    if ! git config --global user.name &> /dev/null; then
        echo -n "Enter your Git username: "
        read -r git_username
        git config --global user.name "$git_username"
    fi
    
    if ! git config --global user.email &> /dev/null; then
        echo -n "Enter your Git email: "
        read -r git_email
        git config --global user.email "$git_email"
    fi
    
    # Set up useful Git aliases and settings
    git config --global init.defaultBranch main
    git config --global pull.rebase false
    git config --global core.editor "nvim"
    git config --global color.ui auto
    
    # Set up Git aliases
    git config --global alias.st "status"
    git config --global alias.co "checkout"
    git config --global alias.br "branch"
    git config --global alias.ci "commit"
    git config --global alias.unstage "reset HEAD --"
    git config --global alias.last "log -1 HEAD"
    git config --global alias.visual "!gitk"
    git config --global alias.lg "log --oneline --decorate --graph --all"
    
    log_success "Git configuration completed"
}

# =================================
# DEVELOPMENT ENVIRONMENT
# =================================

setup_development() {
    log_step "Setting up development environment..."
    
    # Install Rust components
    if command_exists rustup; then
        rustup default stable
        rustup component add rustfmt clippy
        log_success "Rust environment configured"
    fi
    
    # Install Node.js LTS via nvm
    if [[ ! -d "$HOME/.nvm" ]]; then
        log_step "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install --lts
        nvm use --lts
        nvm alias default lts/*
        log_success "NVM and Node.js LTS installed"
    fi
    
    # Set up Python virtual environment tools
    if command_exists python3; then
        python3 -m pip install --user --upgrade pip
        python3 -m pip install --user virtualenv pipenv poetry
        log_success "Python development tools installed"
    fi
    
    # Install global npm packages
    if command_exists npm; then
        npm install -g yarn pnpm typescript ts-node eslint prettier
        log_success "Global npm packages installed"
    fi
    
    log_success "Development environment setup completed"
}

# =================================
# WALLPAPERS SETUP
# =================================

setup_wallpapers() {
    log_step "Setting up wallpapers..."
    
    local wallpaper_dir="$HOME/.local/share/wallpapers"
    mkdir -p "$wallpaper_dir"
    
    log_success "Wallpapers setup completed"
}

# =================================
# FINAL SETUP
# =================================

finalize_setup() {
    log_step "Finalizing setup..."
    
    # Set executable permissions for scripts
    find "$HOME/.local/bin" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    
    # Create necessary directories
    mkdir -p "$HOME/Pictures/Screenshots"
    mkdir -p "$HOME/Documents"
    mkdir -p "$HOME/Downloads"
    mkdir -p "$HOME/Projects"
    
    # Set up XDG directories
    xdg-user-dirs-update
    
    log_success "Setup finalized"
}

# =================================
# MAIN INSTALLATION FUNCTION
# =================================

main() {
    print_banner
    
    log_info "Starting Arch Linux i3 Ricing Setup..."
    log_info "This script will install and configure a complete i3 desktop environment"
    log_info ""
    
    if ! confirm "Do you want to proceed with the installation?"; then
        log_info "Installation cancelled by user"
        exit 0
    fi
    
    # Check if running on Arch Linux
    if [[ ! -f /etc/arch-release ]]; then
        log_error "This script is designed for Arch Linux only!"
        exit 1
    fi
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root!"
        exit 1
    fi
    
    log_info "Starting installation process..."
    echo ""
    
    # Installation steps
    install_packages
    setup_dotfiles
    setup_shell
    setup_services
    setup_fonts
    setup_git
    setup_development
    setup_wallpapers
    finalize_setup
    
    echo ""
    log_success "🎉 Installation completed successfully!"
    echo ""
    log_info "Next steps:"
    echo "  1. Reboot your system"
    echo "  2. Log out and select i3 as your session"
    echo "  3. Enjoy your new riced Arch Linux i3 setup!"
    echo ""
    log_info "i3 configuration files are located in ~/.config/i3/"
    log_info "Custom scripts are located in ~/.local/bin/"
    echo ""
    
    if confirm "Would you like to reboot now?"; then
        log_info "Rebooting system..."
        sudo reboot
    else
        log_info "Please reboot manually to complete the setup"
    fi
}

# Run the main function
main "$@"