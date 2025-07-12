# Arch Linux Installation & Ricing Setup Guide

## Pre-Installation Preparation

### 1. Backup Your Current System
```bash
# Backup your current dotfiles
tar -czf ~/pop-os-backup-$(date +%Y%m%d).tar.gz ~/.config ~/.bashrc ~/.zshrc ~/.local

# Backup your development projects (already done in ai-workspace)
rsync -av ~/ai-workspace/ ~/backup/ai-workspace/
rsync -av ~/ai-context/ ~/backup/ai-context/
```

### 2. Download Arch Linux ISO
- Download from: https://archlinux.org/download/
- Verify checksums
- Create bootable USB with `dd` or Ventoy

### 3. Hardware Information Gathering
```bash
# Get your hardware info before wiping
lscpu > ~/hardware-info.txt
lspci >> ~/hardware-info.txt
lsusb >> ~/hardware-info.txt
ip addr >> ~/hardware-info.txt
```

## Installation Process

### Phase 1: Boot and Setup

1. **Boot from USB**
   - Select UEFI mode
   - Set keyboard layout: `loadkeys us`

2. **Connect to Internet**
   ```bash
   # For Wi-Fi
   iwctl
   station wlan0 scan
   station wlan0 get-networks
   station wlan0 connect "YOUR_WIFI_NAME"
   exit
   
   # Test connection
   ping google.com
   ```

3. **Update System Clock**
   ```bash
   timedatectl set-ntp true
   timedatectl status
   ```

### Phase 2: Disk Partitioning

1. **Identify Disks**
   ```bash
   lsblk
   fdisk -l
   ```

2. **Partition Scheme (UEFI)**
   ```bash
   cfdisk /dev/nvme0n1  # or your disk
   
   # Create partitions:
   # /dev/nvme0n1p1 - 512M - EFI System
   # /dev/nvme0n1p2 - 16G  - Linux swap
   # /dev/nvme0n1p3 - Rest - Linux filesystem (will be encrypted)
   ```

3. **Encryption Setup**
   ```bash
   # Encrypt root partition
   cryptsetup luksFormat /dev/nvme0n1p3
   cryptsetup open /dev/nvme0n1p3 cryptroot
   
   # Format partitions
   mkfs.fat -F32 /dev/nvme0n1p1    # EFI
   mkswap /dev/nvme0n1p2           # Swap
   mkfs.ext4 /dev/mapper/cryptroot # Root
   ```

4. **Mount Partitions**
   ```bash
   mount /dev/mapper/cryptroot /mnt
   mkdir -p /mnt/boot
   mount /dev/nvme0n1p1 /mnt/boot
   swapon /dev/nvme0n1p2
   ```

### Phase 3: Base System Installation

1. **Install Base System**
   ```bash
   pacstrap /mnt base linux linux-firmware
   pacstrap /mnt base-devel git vim networkmanager
   ```

2. **Generate Fstab**
   ```bash
   genfstab -U /mnt >> /mnt/etc/fstab
   ```

3. **Chroot into System**
   ```bash
   arch-chroot /mnt
   ```

### Phase 4: System Configuration

1. **Time Zone**
   ```bash
   ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
   hwclock --systohc
   ```

2. **Localization**
   ```bash
   echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
   locale-gen
   echo "LANG=en_US.UTF-8" > /etc/locale.conf
   ```

3. **Network Configuration**
   ```bash
   echo "arch-rice" > /etc/hostname
   cat >> /etc/hosts << EOF
   127.0.0.1   localhost
   ::1         localhost
   127.0.1.1   arch-rice.localdomain arch-rice
   EOF
   ```

4. **Users and Passwords**
   ```bash
   passwd  # Set root password
   useradd -m -G wheel,storage,power -s /bin/bash locker
   passwd locker
   EDITOR=vim visudo  # Uncomment %wheel ALL=(ALL) ALL
   ```

5. **Initramfs Configuration**
   ```bash
   vim /etc/mkinitcpio.conf
   # Add 'encrypt' to HOOKS before 'filesystems'
   # HOOKS=(base udev autodetect microcode modconf keyboard keymap consolefont block encrypt filesystems fsck)
   mkinitcpio -P
   ```

### Phase 5: Bootloader Setup

1. **Install systemd-boot**
   ```bash
   bootctl --path=/boot install
   ```

2. **Create Boot Entry**
   ```bash
   cat > /boot/loader/entries/arch.conf << EOF
   title   Arch Linux
   linux   /vmlinuz-linux
   initrd  /initramfs-linux.img
   options cryptdevice=/dev/nvme0n1p3:cryptroot root=/dev/mapper/cryptroot rw
   EOF
   ```

3. **Configure Loader**
   ```bash
   cat > /boot/loader/loader.conf << EOF
   default arch
   timeout 3
   console-mode max
   editor no
   EOF
   ```

### Phase 6: Final Steps

1. **Enable Essential Services**
   ```bash
   systemctl enable NetworkManager
   systemctl enable fstrim.timer  # For SSD
   ```

2. **Exit and Reboot**
   ```bash
   exit
   umount -R /mnt
   reboot
   ```

## Post-Installation Setup

### 1. Connect to Internet
```bash
sudo systemctl start NetworkManager
nmcli dev wifi connect "YOUR_WIFI" password "PASSWORD"
```

### 2. Install AUR Helper
```bash
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

### 3. Essential Package Installation
```bash
# Development tools
yay -S python python-pip nodejs npm go docker docker-compose

# Desktop essentials
yay -S hyprland-git waybar wofi kitty firefox
yay -S pipewire pipewire-alsa pipewire-pulse wireplumber
yay -S thunar gvfs ntfs-3g
yay -S brightnessctl playerctl pamixer

# Ricing tools
yay -S picom-git rofi dunst swww grim slurp
yay -S ttf-jetbrains-mono nerd-fonts-fira-code
yay -S neofetch htop ranger

# Your specific tools
yay -S uv  # Python package manager you prefer
```

### 4. Enable Services
```bash
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
sudo systemctl --user enable --now pipewire pipewire-pulse
```

## Next Steps

After completing the installation:

1. **Clone the dotfiles repository** (created in next steps)
2. **Run the automated setup script**
3. **Configure your development environment**
4. **Restore your projects from backup**

## Troubleshooting

### Common Issues

1. **Boot Issues**
   - Check encryption password
   - Verify boot entry paths
   - Use `lsblk` to confirm partition UUIDs

2. **Network Issues**
   - `sudo systemctl restart NetworkManager`
   - Check `ip addr` for interface names

3. **Audio Issues**
   - `systemctl --user restart pipewire`
   - Install `pavucontrol` for GUI control

4. **Graphics Issues**
   - Install GPU drivers: `nvidia` or `mesa`
   - Configure Xorg/Wayland properly

### Recovery

If something goes wrong:
```bash
# Boot from live USB
cryptsetup open /dev/nvme0n1p3 cryptroot
mount /dev/mapper/cryptroot /mnt
mount /dev/nvme0n1p1 /mnt/boot
arch-chroot /mnt
# Fix issues and reboot
```

This guide provides the foundation for your complete Arch Linux ricing setup. The next files will contain all the configuration files and scripts needed for the perfect desktop environment.