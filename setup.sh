#!/bin/bash

# Arch Linux Ultimate Ricing Setup
# Complete Desktop Environment Installation and Configuration
# Tokyo Night Theme with Hyprland

set -e

# =================================
# SCRIPT INFORMATION
# =================================

SCRIPT_NAME="Arch Linux Ultimate Ricing Setup"
SCRIPT_VERSION="1.0.0"
SCRIPT_AUTHOR="AI Assistant"
SCRIPT_DATE="2025-01-10"

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
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Unicode symbols
CHECKMARK="✓"
CROSS="✗"
ARROW="→"
STAR="★"
GEAR="⚙"
ROCKET="🚀"
HEART="❤"

# =================================
# CONFIGURATION
# =================================

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SOURCE_DIR="$SCRIPT_DIR/config"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"

# URLs and repositories
REPO_URL="https://github.com/yourusername/arch-ricing-setup"
OH_MY_ZSH_URL="https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
STARSHIP_URL="https://starship.rs/install.sh"
NVM_URL="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh"

# Flags
DRY_RUN=false
SKIP_PACKAGES=false
SKIP_CONFIGS=false
VERBOSE=false
FORCE=false

# =================================
# LOGGING FUNCTIONS
# =================================

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        "INFO")
            echo -e "${BLUE}[${timestamp}] [INFO]${NC} $message"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[${timestamp}] [${CHECKMARK}]${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}[${timestamp}] [!]${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}[${timestamp}] [${CROSS}]${NC} $message"
            ;;
        "STEP")
            echo -e "${PURPLE}[${timestamp}] [${ARROW}]${NC} $message"
            ;;
        "DEBUG")
            if [[ "$VERBOSE" == true ]]; then
                echo -e "${DIM}[${timestamp}] [DEBUG]${NC} $message"
            fi
            ;;
    esac
}

log_info() { log "INFO" "$1"; }
log_success() { log "SUCCESS" "$1"; }
log_warning() { log "WARNING" "$1"; }
log_error() { log "ERROR" "$1"; }
log_step() { log "STEP" "$1"; }
log_debug() { log "DEBUG" "$1"; }

# =================================
# BANNER AND HELP
# =================================

print_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔══════════════════════════════════════════════════════════════════════╗
    ║                                                                      ║
    ║                 Arch Linux Ultimate Ricing Setup                    ║
    ║                                                                      ║
    ║              🌟 Complete Desktop Environment Installer 🌟            ║
    ║                                                                      ║
    ║                        Tokyo Night Theme                            ║
    ║                     Hyprland + Waybar + More                        ║
    ║                                                                      ║
    ║     Features: Window Manager, Status Bar, Terminal, Launcher,       ║
    ║               Shell, Compositor, Development Environment             ║
    ║                                                                      ║
    ╚══════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    echo -e "${WHITE}Version:${NC} $SCRIPT_VERSION"
    echo -e "${WHITE}Author:${NC} $SCRIPT_AUTHOR"
    echo -e "${WHITE}Date:${NC} $SCRIPT_DATE"
    echo ""
}

show_help() {
    cat << EOF
$SCRIPT_NAME

Usage: $0 [OPTIONS]

OPTIONS:
    --dry-run              Show what would be done without executing
    --skip-packages        Skip package installation
    --skip-configs         Skip configuration setup
    --verbose, -v          Enable verbose output
    --force                Force overwrite existing configurations
    --help, -h             Show this help message

INSTALLATION PHASES:
    1. System Validation   Check system requirements and dependencies
    2. Package Installation Install AUR helper and required packages
    3. Configuration Setup Copy and setup dotfiles and configurations
    4. Shell Environment   Setup Zsh, Oh My Zsh, and Starship
    5. System Services     Enable and configure system services
    6. Development Tools   Setup development environment
    7. Finalization        Final touches and cleanup

WHAT GETS INSTALLED:
    Desktop Environment:
        - Hyprland (Wayland compositor)
        - Waybar (status bar)
        - Wofi/Rofi (application launchers)
        - Kitty (terminal emulator)
        - Picom (compositor effects)
    
    System Tools:
        - Git, curl, wget, various CLI tools
        - Font packages (JetBrains Mono Nerd Font)
        - Audio (PipeWire) and Bluetooth
        - Network tools and file management
    
    Development:
        - Python, Node.js, Go, Rust toolchains
        - VS Code, Docker, Git configuration
        - Various development utilities
    
    Shell & Prompt:
        - Zsh with Oh My Zsh framework
        - Starship prompt with custom config
        - Enhanced aliases and functions

CONFIGURATION FILES:
    - ~/.config/hypr/         Hyprland configuration
    - ~/.config/waybar/       Status bar configuration
    - ~/.config/kitty/        Terminal configuration
    - ~/.config/wofi/         Application launcher
    - ~/.config/rofi/         Alternative launcher
    - ~/.config/picom/        Compositor configuration
    - ~/.zshrc                Shell configuration
    - ~/.config/starship/     Prompt configuration

REQUIREMENTS:
    - Arch Linux (or Arch-based distribution)
    - User account with sudo privileges
    - Internet connection
    - At least 4GB free disk space

EXAMPLES:
    $0                     # Full installation
    $0 --dry-run           # Preview installation
    $0 --skip-packages     # Only setup configurations
    $0 --verbose           # Detailed output
    $0 --force             # Overwrite existing configs

BACKUP:
    Existing configurations are backed up to:
    $BACKUP_DIR

POST-INSTALLATION:
    1. Reboot the system
    2. Select Hyprland session at login
    3. Enjoy your riced desktop!

For support and updates: $REPO_URL
EOF
}

# =================================
# UTILITY FUNCTIONS
# =================================

confirm() {
    if [[ "$FORCE" == true ]]; then
        return 0
    fi
    
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

package_installed() {
    pacman -Qi "$1" &>/dev/null
}

aur_package_installed() {
    local aur_helper="${2:-yay}"
    $aur_helper -Qi "$1" &>/dev/null
}

create_backup() {
    local source="$1"
    local backup_name="$2"
    
    if [[ -e "$source" ]]; then
        log_warning "Backing up existing $source"
        if [[ ! -d "$BACKUP_DIR" ]]; then
            mkdir -p "$BACKUP_DIR"
        fi
        cp -r "$source" "$BACKUP_DIR/$backup_name" || {
            log_error "Failed to backup $source"
            return 1
        }
        log_success "Backup created: $BACKUP_DIR/$backup_name"
    fi
}

progress_bar() {
    local current="$1"
    local total="$2"
    local description="$3"
    local width=50
    
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r${BLUE}[${NC}"
    printf "%*s" $filled | tr ' ' '█'
    printf "%*s" $empty | tr ' ' '░'
    printf "${BLUE}] %3d%% ${NC}%s" $percentage "$description"
    
    if [[ $current -eq $total ]]; then
        echo ""
    fi
}

# =================================
# VALIDATION FUNCTIONS
# =================================

validate_system() {
    log_step "Validating system requirements..."
    
    # Check if running on Arch Linux
    if [[ ! -f /etc/arch-release ]]; then
        log_error "This script requires Arch Linux or an Arch-based distribution"
        return 1
    fi
    log_success "Running on Arch Linux"
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        return 1
    fi
    log_success "Running as non-root user"
    
    # Check sudo access
    if ! sudo -n true 2>/dev/null; then
        log_info "Testing sudo access..."
        if ! sudo true; then
            log_error "Sudo access required"
            return 1
        fi
    fi
    log_success "Sudo access confirmed"
    
    # Check internet connectivity
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        log_error "Internet connection required"
        return 1
    fi
    log_success "Internet connectivity confirmed"
    
    # Check available disk space (at least 4GB)
    local available_space
    available_space=$(df "$HOME" | awk 'NR==2 {print $4}')
    local required_space=$((4 * 1024 * 1024)) # 4GB in KB
    
    if [[ $available_space -lt $required_space ]]; then
        log_error "Insufficient disk space. At least 4GB required"
        return 1
    fi
    log_success "Sufficient disk space available"
    
    # Check for conflicting desktop environments
    local conflicting_des=("gnome" "kde" "xfce4" "lxde" "mate")
    for de in "${conflicting_des[@]}"; do
        if package_installed "$de"; then
            log_warning "Conflicting desktop environment detected: $de"
            if ! confirm "Continue anyway? This may cause conflicts."; then
                return 1
            fi
            break
        fi
    done
    
    log_success "System validation completed"
    return 0
}

# =================================
# PACKAGE INSTALLATION
# =================================

install_aur_helper() {
    if command_exists yay; then
        log_success "yay AUR helper already installed"
        return 0
    elif command_exists paru; then
        log_success "paru AUR helper already installed"
        return 0
    fi
    
    log_step "Installing AUR helper (yay)..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would install yay AUR helper"
        return 0
    fi
    
    # Install base-devel if not present
    if ! package_installed base-devel; then
        sudo pacman -S --noconfirm base-devel
    fi
    
    # Install git if not present
    if ! package_installed git; then
        sudo pacman -S --noconfirm git
    fi
    
    # Clone and build yay
    local temp_dir="/tmp/yay_install_$$"
    mkdir -p "$temp_dir"
    cd "$temp_dir"
    
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    
    cd - >/dev/null
    rm -rf "$temp_dir"
    
    log_success "yay AUR helper installed"
}

install_packages() {
    if [[ "$SKIP_PACKAGES" == true ]]; then
        log_info "Skipping package installation"
        return 0
    fi
    
    log_step "Installing packages..."
    
    # Update system first
    log_info "Updating system packages..."
    if [[ "$DRY_RUN" != true ]]; then
        sudo pacman -Syu --noconfirm
    fi
    
    # Define package arrays
    local official_packages=(
        # Desktop environment core
        "hyprland" "xdg-desktop-portal-hyprland" "waybar" "wofi" "kitty"
        
        # System essentials
        "git" "curl" "wget" "unzip" "zip" "tar" "gzip" "bzip2"
        "htop" "neofetch" "tree" "which" "fd" "ripgrep" "bat" "exa"
        "zsh" "starship" "fzf" "zoxide" "thefuck"
        
        # Development tools
        "base-devel" "python" "python-pip" "nodejs" "npm" "go" "rustup"
        "docker" "docker-compose" "git" "vim" "neovim"
        
        # Media and graphics
        "pipewire" "pipewire-alsa" "pipewire-pulse" "pipewire-jack" "wireplumber"
        "pavucontrol" "brightnessctl" "playerctl" "pamixer"
        "grim" "slurp" "swappy" "wl-clipboard" "imagemagick"
        
        # File management
        "thunar" "gvfs" "gvfs-smb" "ntfs-3g" "exfat-utils"
        "tumbler" "ffmpegthumbnailer" "file-roller"
        
        # Fonts
        "ttf-jetbrains-mono" "ttf-fira-code" "noto-fonts" "noto-fonts-emoji"
        "ttf-liberation" "ttf-dejavu" "adobe-source-code-pro-fonts"
        
        # Network and bluetooth
        "networkmanager" "nm-connection-editor" "network-manager-applet"
        "bluetooth" "bluez" "bluez-utils" "blueman"
        
        # Archive support
        "p7zip" "unrar" "lzop" "cpio" "xz"
        
        # Audio/Video
        "mpv" "vlc" "firefox" "chromium"
        
        # Graphics
        "gimp" "inkscape" "krita" "blender"
        
        # System monitoring
        "lsof" "strace" "iotop" "nethogs" "bandwhich"
        
        # Utilities
        "rsync" "rclone" "syncthing" "timeshift"
    )
    
    local aur_packages=(
        # Desktop enhancements
        "picom-git" "hyprpicker" "hyprlock" "hypridle" "swww"
        "rofi-lbonn-wofi-wayland-git" "dunst" "mako"
        
        # Fonts
        "nerd-fonts-jetbrains-mono" "nerd-fonts-fira-code"
        "nerd-fonts-source-code-pro"
        
        # Applications
        "visual-studio-code-bin" "discord" "spotify" "obsidian"
        "brave-bin" "telegram-desktop" "notion-app"
        
        # Development
        "postman-bin" "github-desktop-bin" "jetbrains-toolbox"
        
        # System
        "ly" "auto-cpufreq" "tlp"
        
        # Entertainment
        "cava" "pipes.sh" "cbonsai" "tty-clock" "lolcat"
        "figlet" "cowsay" "fortune-mod" "sl"
    )
    
    # Install official packages
    log_info "Installing official packages (${#official_packages[@]} packages)..."
    local count=0
    for package in "${official_packages[@]}"; do
        ((count++))
        progress_bar $count ${#official_packages[@]} "Installing $package..."
        
        if [[ "$DRY_RUN" == true ]]; then
            sleep 0.1
            continue
        fi
        
        if ! package_installed "$package"; then
            sudo pacman -S --noconfirm "$package" || {
                log_warning "Failed to install $package"
            }
        fi
    done
    
    # Determine AUR helper
    local aur_helper="yay"
    if command_exists paru; then
        aur_helper="paru"
    fi
    
    # Install AUR packages
    log_info "Installing AUR packages (${#aur_packages[@]} packages)..."
    count=0
    for package in "${aur_packages[@]}"; do
        ((count++))
        progress_bar $count ${#aur_packages[@]} "Installing $package..."
        
        if [[ "$DRY_RUN" == true ]]; then
            sleep 0.1
            continue
        fi
        
        if ! aur_package_installed "$package" "$aur_helper"; then
            $aur_helper -S --noconfirm "$package" || {
                log_warning "Failed to install $package"
            }
        fi
    done
    
    log_success "Package installation completed"
}

# =================================
# CONFIGURATION SETUP
# =================================

setup_configurations() {
    if [[ "$SKIP_CONFIGS" == true ]]; then
        log_info "Skipping configuration setup"
        return 0
    fi
    
    log_step "Setting up configurations..."
    
    # Create necessary directories
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.local/share"
    mkdir -p "$HOME/.cache"
    
    # Configuration mappings
    local configs=(
        "hypr:$HOME/.config/hypr"
        "waybar:$HOME/.config/waybar"
        "kitty:$HOME/.config/kitty"
        "wofi:$HOME/.config/wofi"
        "rofi:$HOME/.config/rofi"
        "picom:$HOME/.config/picom"
        "starship:$HOME/.config/starship"
    )
    
    # Copy configurations
    for config in "${configs[@]}"; do
        local source_name="${config%%:*}"
        local dest_path="${config##*:}"
        local source_path="$CONFIG_SOURCE_DIR/$source_name"
        
        if [[ -d "$source_path" ]]; then
            log_info "Installing $source_name configuration..."
            
            if [[ "$DRY_RUN" == true ]]; then
                log_info "[DRY RUN] Would copy $source_path to $dest_path"
                continue
            fi
            
            create_backup "$dest_path" "$(basename "$dest_path")"
            cp -r "$source_path" "$dest_path"
            log_success "$source_name configuration installed"
        else
            log_warning "Configuration source not found: $source_path"
        fi
    done
    
    # Setup Zsh configuration
    if [[ -f "$CONFIG_SOURCE_DIR/zsh/.zshrc" ]]; then
        log_info "Installing Zsh configuration..."
        if [[ "$DRY_RUN" != true ]]; then
            create_backup "$HOME/.zshrc" ".zshrc"
            cp "$CONFIG_SOURCE_DIR/zsh/.zshrc" "$HOME/"
            log_success "Zsh configuration installed"
        fi
    fi
    
    # Copy scripts and make executable
    if [[ -d "$CONFIG_SOURCE_DIR/hypr/scripts" ]]; then
        log_info "Installing custom scripts..."
        if [[ "$DRY_RUN" != true ]]; then
            cp -r "$CONFIG_SOURCE_DIR/hypr/scripts"/* "$HOME/.local/bin/" 2>/dev/null || true
            chmod +x "$HOME/.local/bin"/* 2>/dev/null || true
            log_success "Custom scripts installed"
        fi
    fi
    
    log_success "Configuration setup completed"
}

# =================================
# SHELL ENVIRONMENT SETUP
# =================================

setup_shell_environment() {
    log_step "Setting up shell environment..."
    
    # Install Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Installing Oh My Zsh..."
        if [[ "$DRY_RUN" != true ]]; then
            curl -fsSL "$OH_MY_ZSH_URL" | sh -s -- --unattended
        fi
        log_success "Oh My Zsh installed"
    else
        log_success "Oh My Zsh already installed"
    fi
    
    # Install Zsh plugins
    local zsh_custom="$HOME/.oh-my-zsh/custom"
    local plugins=(
        "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
        "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting"
        "zsh-completions:https://github.com/zsh-users/zsh-completions"
    )
    
    for plugin in "${plugins[@]}"; do
        local plugin_name="${plugin%%:*}"
        local plugin_url="${plugin##*:}"
        local plugin_dir="$zsh_custom/plugins/$plugin_name"
        
        if [[ ! -d "$plugin_dir" ]]; then
            log_info "Installing $plugin_name..."
            if [[ "$DRY_RUN" != true ]]; then
                git clone "$plugin_url" "$plugin_dir"
            fi
            log_success "$plugin_name installed"
        fi
    done
    
    # Install Starship
    if ! command_exists starship; then
        log_info "Installing Starship prompt..."
        if [[ "$DRY_RUN" != true ]]; then
            curl -sS "$STARSHIP_URL" | sh -s -- --yes
        fi
        log_success "Starship prompt installed"
    else
        log_success "Starship prompt already installed"
    fi
    
    # Change default shell to Zsh
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        log_info "Changing default shell to Zsh..."
        if [[ "$DRY_RUN" != true ]]; then
            chsh -s "$(which zsh)"
        fi
        log_success "Default shell changed to Zsh"
    fi
    
    log_success "Shell environment setup completed"
}

# =================================
# SYSTEM SERVICES
# =================================

setup_system_services() {
    log_step "Setting up system services..."
    
    local services=(
        "NetworkManager:Enable network management"
        "bluetooth:Enable Bluetooth support"
        "docker:Enable Docker service"
        "fstrim.timer:Enable SSD TRIM"
        "systemd-timesyncd:Enable time synchronization"
    )
    
    for service_info in "${services[@]}"; do
        local service="${service_info%%:*}"
        local description="${service_info##*:}"
        
        log_info "$description..."
        if [[ "$DRY_RUN" != true ]]; then
            sudo systemctl enable --now "$service" 2>/dev/null || {
                log_warning "Failed to enable $service"
            }
        fi
    done
    
    # Add user to Docker group
    if command_exists docker; then
        log_info "Adding user to docker group..."
        if [[ "$DRY_RUN" != true ]]; then
            sudo usermod -aG docker "$USER"
        fi
        log_success "User added to docker group"
    fi
    
    log_success "System services setup completed"
}

# =================================
# DEVELOPMENT ENVIRONMENT
# =================================

setup_development_environment() {
    log_step "Setting up development environment..."
    
    # Setup Rust
    if command_exists rustup; then
        log_info "Configuring Rust environment..."
        if [[ "$DRY_RUN" != true ]]; then
            rustup default stable
            rustup component add rustfmt clippy
        fi
        log_success "Rust environment configured"
    fi
    
    # Setup Node.js via NVM
    if [[ ! -d "$HOME/.nvm" ]]; then
        log_info "Installing NVM and Node.js..."
        if [[ "$DRY_RUN" != true ]]; then
            curl -o- "$NVM_URL" | bash
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            nvm install --lts
            nvm use --lts
            nvm alias default lts/*
        fi
        log_success "NVM and Node.js installed"
    fi
    
    # Setup Python development tools
    if command_exists python3; then
        log_info "Setting up Python development tools..."
        if [[ "$DRY_RUN" != true ]]; then
            python3 -m pip install --user --upgrade pip
            python3 -m pip install --user virtualenv pipenv poetry black flake8 mypy
        fi
        log_success "Python development tools installed"
    fi
    
    # Install global npm packages
    if command_exists npm; then
        log_info "Installing global npm packages..."
        if [[ "$DRY_RUN" != true ]]; then
            npm install -g yarn pnpm typescript ts-node eslint prettier
        fi
        log_success "Global npm packages installed"
    fi
    
    log_success "Development environment setup completed"
}

# =================================
# FINALIZATION
# =================================

finalize_setup() {
    log_step "Finalizing setup..."
    
    # Set permissions for scripts
    if [[ "$DRY_RUN" != true ]]; then
        find "$HOME/.local/bin" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
        find "$HOME/.config/hypr/scripts" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    fi
    
    # Create useful directories
    local directories=(
        "$HOME/Pictures/Screenshots"
        "$HOME/Pictures/Wallpapers"
        "$HOME/Documents/Projects"
        "$HOME/Downloads"
        "$HOME/.local/share/wallpapers"
    )
    
    for dir in "${directories[@]}"; do
        if [[ "$DRY_RUN" != true ]]; then
            mkdir -p "$dir"
        fi
    done
    
    # Update XDG user directories
    if [[ "$DRY_RUN" != true ]] && command_exists xdg-user-dirs-update; then
        xdg-user-dirs-update
    fi
    
    # Update font cache
    if [[ "$DRY_RUN" != true ]] && command_exists fc-cache; then
        fc-cache -fv >/dev/null 2>&1
    fi
    
    log_success "Setup finalized"
}

# =================================
# MAIN INSTALLATION PROCESS
# =================================

run_installation() {
    local phases=(
        "validate_system:System Validation"
        "install_aur_helper:AUR Helper Installation"
        "install_packages:Package Installation"
        "setup_configurations:Configuration Setup"
        "setup_shell_environment:Shell Environment"
        "setup_system_services:System Services"
        "setup_development_environment:Development Environment"
        "finalize_setup:Finalization"
    )
    
    log_info "Starting installation process..."
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "DRY RUN MODE - No changes will be made"
    fi
    echo ""
    
    local phase_count=0
    local total_phases=${#phases[@]}
    
    for phase_info in "${phases[@]}"; do
        local phase_func="${phase_info%%:*}"
        local phase_name="${phase_info##*:}"
        
        ((phase_count++))
        
        echo ""
        log_step "Phase $phase_count/$total_phases: $phase_name"
        echo ""
        
        if ! $phase_func; then
            log_error "Failed during phase: $phase_name"
            return 1
        fi
        
        progress_bar $phase_count $total_phases "Completed: $phase_name"
    done
    
    return 0
}

# =================================
# POST-INSTALLATION SUMMARY
# =================================

show_installation_summary() {
    echo ""
    echo -e "${GREEN}${BOLD}"
    cat << 'EOF'
    ╔══════════════════════════════════════════════════════════════════════╗
    ║                                                                      ║
    ║                    🎉 INSTALLATION COMPLETED! 🎉                     ║
    ║                                                                      ║
    ╚══════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    log_success "Arch Linux Ultimate Ricing Setup completed successfully!"
    echo ""
    
    echo -e "${CYAN}${BOLD}What was installed:${NC}"
    echo "  ${CHECKMARK} Hyprland window manager with custom configuration"
    echo "  ${CHECKMARK} Waybar status bar with Tokyo Night theme"
    echo "  ${CHECKMARK} Kitty terminal with enhanced features"
    echo "  ${CHECKMARK} Wofi and Rofi application launchers"
    echo "  ${CHECKMARK} Picom compositor with animations and blur"
    echo "  ${CHECKMARK} Zsh shell with Oh My Zsh and Starship prompt"
    echo "  ${CHECKMARK} Development environment (Python, Node.js, Go, Rust)"
    echo "  ${CHECKMARK} Custom scripts and automation tools"
    echo "  ${CHECKMARK} Tokyo Night theme across all applications"
    echo ""
    
    echo -e "${YELLOW}${BOLD}Next steps:${NC}"
    echo "  1. ${ARROW} Reboot your system"
    echo "  2. ${ARROW} At login, select 'Hyprland' as your session"
    echo "  3. ${ARROW} Press Super+Return to open terminal"
    echo "  4. ${ARROW} Press Super+D to open application launcher"
    echo "  5. ${ARROW} Enjoy your riced Arch Linux setup!"
    echo ""
    
    echo -e "${BLUE}${BOLD}Key bindings:${NC}"
    echo "  Super + Return       Open terminal"
    echo "  Super + D            Application launcher (Wofi)"
    echo "  Super + R            Application launcher (Rofi)"
    echo "  Super + Q            Close window"
    echo "  Super + Space        Toggle floating"
    echo "  Super + F            Toggle fullscreen"
    echo "  Super + 1-9          Switch workspaces"
    echo "  Super + Shift + 1-9  Move window to workspace"
    echo "  Print                Take screenshot"
    echo ""
    
    echo -e "${PURPLE}${BOLD}Configuration locations:${NC}"
    echo "  ~/.config/hypr/      Hyprland configuration"
    echo "  ~/.config/waybar/    Status bar configuration"
    echo "  ~/.config/kitty/     Terminal configuration"
    echo "  ~/.zshrc             Shell configuration"
    echo "  ~/.local/bin/        Custom scripts"
    echo ""
    
    if [[ -d "$BACKUP_DIR" ]]; then
        echo -e "${CYAN}${BOLD}Backup location:${NC}"
        echo "  $BACKUP_DIR"
        echo ""
    fi
    
    echo -e "${GREEN}${BOLD}Support and Documentation:${NC}"
    echo "  Repository: $REPO_URL"
    echo "  Issues: ${REPO_URL}/issues"
    echo "  Wiki: ${REPO_URL}/wiki"
    echo ""
    
    echo -e "${RED}${HEART}${NC} ${BOLD}Made with love for the Arch Linux community${NC}"
    echo ""
}

# =================================
# MAIN FUNCTION
# =================================

main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --skip-packages)
                SKIP_PACKAGES=true
                shift
                ;;
            --skip-configs)
                SKIP_CONFIGS=true
                shift
                ;;
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Show banner
    print_banner
    
    # Show warning and get confirmation
    if [[ "$DRY_RUN" != true ]]; then
        echo -e "${YELLOW}${BOLD}WARNING:${NC} This script will:"
        echo "  • Install numerous packages and dependencies"
        echo "  • Modify your shell and desktop environment"
        echo "  • Replace existing configurations (with backup)"
        echo "  • Change your default shell to Zsh"
        echo ""
        
        if ! confirm "Do you want to proceed with the installation?"; then
            log_info "Installation cancelled by user"
            exit 0
        fi
        echo ""
    fi
    
    # Run installation
    if run_installation; then
        show_installation_summary
        
        # Ask for reboot
        if [[ "$DRY_RUN" != true ]]; then
            echo ""
            if confirm "Would you like to reboot now to complete the setup?"; then
                log_info "Rebooting system..."
                sudo reboot
            else
                log_info "Please reboot manually to complete the setup"
                log_info "Then select Hyprland at the login screen"
            fi
        fi
    else
        log_error "Installation failed!"
        echo ""
        log_info "Check the output above for error details"
        log_info "You can re-run the script to retry the installation"
        if [[ -d "$BACKUP_DIR" ]]; then
            log_info "Your original configurations are backed up in: $BACKUP_DIR"
        fi
        exit 1
    fi
}

# =================================
# SCRIPT EXECUTION
# =================================

# Trap to handle interruption
trap 'log_error "Installation interrupted by user"; exit 130' INT TERM

# Run main function
main "$@"