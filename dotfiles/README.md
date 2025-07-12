# Arch Linux Ricing Dotfiles

Ultimate desktop customization setup for Arch Linux featuring Hyprland, Tokyo Night theme, and a complete development environment.

## 🌟 Features

### Desktop Environment
- **Hyprland**: Modern Wayland compositor with animations
- **Waybar**: Beautiful status bar with custom modules
- **Wofi/Rofi**: Application launchers with Tokyo Night theme
- **Kitty**: GPU-accelerated terminal with custom themes
- **Picom**: Advanced compositor with blur and animations

### Shell & Prompt
- **Zsh**: Enhanced shell with Oh My Zsh
- **Starship**: Fast, customizable prompt
- **Advanced aliases and functions**
- **FZF integration for fuzzy finding**

### Theme
- **Tokyo Night**: Consistent color scheme across all applications
- **Nerd Fonts**: JetBrains Mono with icons
- **Custom icons and wallpapers**

### Development Tools
- **Languages**: Python, Go, Rust, Node.js, TypeScript
- **Editors**: VS Code, Neovim configurations
- **Git**: Pre-configured with useful aliases
- **Docker**: Container development ready

## 📦 Installation

### Prerequisites
- Fresh Arch Linux installation
- Internet connection
- User account with sudo privileges

### Quick Install
```bash
# Clone the repository
git clone https://github.com/yourusername/arch-ricing-setup.git
cd arch-ricing-setup

# Make install script executable
chmod +x dotfiles/install.sh

# Run the installation
./dotfiles/install.sh
```

### Manual Installation
If you prefer to install components individually:

```bash
# 1. Install AUR helper
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si

# 2. Install essential packages
yay -S hyprland waybar wofi kitty rofi picom-git

# 3. Copy configurations
cp -r config/* ~/.config/

# 4. Set up shell
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s $(which zsh)
```

## 🎨 Customization

### Colors
The Tokyo Night theme uses these primary colors:
- **Background**: `#1a1b26`
- **Foreground**: `#c0caf5`
- **Blue**: `#7aa2f7`
- **Purple**: `#bb9af7`
- **Green**: `#9ece6a`
- **Red**: `#f7768e`
- **Yellow**: `#e0af68`
- **Orange**: `#ff9e64`

### Key Bindings

#### Hyprland
- `Super + Return`: Open terminal
- `Super + D`: Application launcher (Wofi)
- `Super + R`: Application launcher (Rofi)
- `Super + Q`: Close window
- `Super + Space`: Toggle floating
- `Super + F`: Toggle fullscreen
- `Super + 1-9`: Switch workspaces
- `Super + Shift + 1-9`: Move window to workspace

#### Terminal (Kitty)
- `Ctrl + Shift + C`: Copy
- `Ctrl + Shift + V`: Paste
- `Ctrl + Shift + T`: New tab
- `Ctrl + Shift + Enter`: New window

### Configuration Files

```
~/.config/
├── hypr/
│   ├── hyprland.conf          # Main Hyprland config
│   └── scripts/               # Custom scripts
├── waybar/
│   ├── config                 # Waybar configuration
│   ├── style.css             # Waybar styling
│   └── scripts/              # Waybar modules
├── kitty/
│   └── kitty.conf            # Terminal configuration
├── wofi/
│   ├── config                # Wofi settings
│   └── style.css             # Wofi theming
├── rofi/
│   ├── config.rasi           # Rofi configuration
│   └── tokyo-night.rasi      # Tokyo Night theme
├── picom/
│   └── picom.conf            # Compositor settings
└── starship/
    └── starship.toml         # Prompt configuration
```

## 🚀 Post-Installation

### 1. Reboot System
```bash
sudo reboot
```

### 2. Select Hyprland Session
At the login screen, select Hyprland as your desktop session.

### 3. First Launch Setup
- Waybar will start automatically
- Press `Super + D` to open application launcher
- Press `Super + Return` to open terminal

### 4. Optional Configurations

#### Set up development environment
```bash
# Configure Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Install Rust components
rustup component add rustfmt clippy

# Install Node.js via NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install --lts
```

#### Configure additional applications
```bash
# Install VS Code extensions
code --install-extension ms-python.python
code --install-extension rust-lang.rust-analyzer
code --install-extension bradlc.vscode-tailwindcss

# Set up Docker
sudo usermod -aG docker $USER
```

## 🛠️ Troubleshooting

### Common Issues

#### Hyprland won't start
```bash
# Check if NVIDIA drivers are properly installed
lsmod | grep nvidia

# Ensure Wayland support
echo $XDG_SESSION_TYPE
```

#### Audio not working
```bash
# Start PipeWire services
systemctl --user restart pipewire pipewire-pulse
```

#### Fonts not displaying correctly
```bash
# Rebuild font cache
fc-cache -fv
```

#### Waybar not showing
```bash
# Check Waybar configuration
waybar --config ~/.config/waybar/config --style ~/.config/waybar/style.css
```

### Performance Issues

#### High memory usage
- Disable animations in Hyprland: Set `animations = false`
- Reduce blur effects in Picom
- Lower Waybar update intervals

#### Slow application startup
- Check if using SSD TRIM: `sudo systemctl status fstrim.timer`
- Optimize font loading: `fc-cache -fv`

## 📁 Directory Structure

```
arch-ricing-setup/
├── 00-INSTALLATION-GUIDE.md    # Complete installation guide
├── config/                     # Configuration files
│   ├── hypr/                  # Hyprland configs
│   ├── waybar/                # Status bar configs
│   ├── kitty/                 # Terminal configs
│   ├── wofi/                  # App launcher configs
│   ├── rofi/                  # Alternative launcher
│   ├── picom/                 # Compositor configs
│   ├── zsh/                   # Shell configs
│   └── starship/              # Prompt configs
├── dotfiles/                   # Installation scripts
│   ├── install.sh             # Main installer
│   └── README.md              # This file
└── scripts/                    # Utility scripts
    ├── screenshot.sh           # Screenshot tool
    ├── power-menu.sh          # Power management
    └── wallpaper.sh           # Wallpaper changer
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on a clean Arch installation
5. Submit a pull request

### Development Guidelines
- Follow existing code style
- Test all configurations
- Update documentation
- Add comments for complex configurations

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Tokyo Night Theme](https://github.com/enkia/tokyo-night-vscode-theme) - Color scheme inspiration
- [Hyprland](https://hyprland.org/) - Amazing Wayland compositor
- [r/unixporn](https://reddit.com/r/unixporn) - Community inspiration
- All the amazing open-source developers

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section
2. Search existing GitHub issues
3. Create a new issue with:
   - System information (`neofetch`)
   - Error messages
   - Steps to reproduce

---

**Made with ❤️ for the Arch Linux community**