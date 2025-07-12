#!/bin/bash

# Power Menu Script for Hyprland
# Ultimate Ricing Setup for Arch Linux
# Provides shutdown, reboot, logout, lock, and suspend options

# =================================
# CONFIGURATION
# =================================

# Theme colors (Tokyo Night)
BG_COLOR="#1a1b26"
FG_COLOR="#c0caf5"
ACCENT_COLOR="#7aa2f7"
URGENT_COLOR="#f7768e"
SUCCESS_COLOR="#9ece6a"

# Icons
SHUTDOWN_ICON=""
REBOOT_ICON=""
LOGOUT_ICON=""
LOCK_ICON=""
SUSPEND_ICON="⏾"
CANCEL_ICON=""

# =================================
# FUNCTIONS
# =================================

show_rofi_menu() {
    local options="$SHUTDOWN_ICON Shutdown\n$REBOOT_ICON Reboot\n$LOGOUT_ICON Logout\n$LOCK_ICON Lock\n$SUSPEND_ICON Suspend\n$CANCEL_ICON Cancel"
    
    echo -e "$options" | rofi -dmenu \
        -p "Power Menu" \
        -theme-str "window { width: 400px; }" \
        -theme-str "listview { lines: 6; }" \
        -theme-str "element-text { font: \"JetBrainsMono Nerd Font 14\"; }" \
        -no-custom \
        -i
}

show_wofi_menu() {
    local temp_file="/tmp/power_menu_$$"
    
    cat > "$temp_file" << EOF
$SHUTDOWN_ICON Shutdown
$REBOOT_ICON Reboot
$LOGOUT_ICON Logout
$LOCK_ICON Lock
$SUSPEND_ICON Suspend
$CANCEL_ICON Cancel
EOF
    
    wofi --show dmenu \
        --prompt "Power Menu" \
        --width 400 \
        --height 300 \
        --location center \
        --allow-markup \
        --insensitive \
        --hide-scroll \
        --no-actions \
        < "$temp_file"
    
    rm -f "$temp_file"
}

show_dmenu_menu() {
    local options="$SHUTDOWN_ICON Shutdown\n$REBOOT_ICON Reboot\n$LOGOUT_ICON Logout\n$LOCK_ICON Lock\n$SUSPEND_ICON Suspend\n$CANCEL_ICON Cancel"
    
    echo -e "$options" | dmenu \
        -p "Power Menu:" \
        -nb "$BG_COLOR" \
        -nf "$FG_COLOR" \
        -sb "$ACCENT_COLOR" \
        -sf "$BG_COLOR" \
        -fn "JetBrainsMono Nerd Font:size=12" \
        -l 6 \
        -i
}

confirm_action() {
    local action="$1"
    local icon="$2"
    
    # Use different confirmation methods based on available tools
    if command -v rofi >/dev/null 2>&1; then
        local choice
        choice=$(echo -e "Yes\nNo" | rofi -dmenu \
            -p "Confirm $action?" \
            -theme-str "window { width: 300px; }" \
            -theme-str "listview { lines: 2; }" \
            -no-custom)
        [[ "$choice" == "Yes" ]]
    elif command -v wofi >/dev/null 2>&1; then
        local temp_file="/tmp/confirm_$$"
        echo -e "Yes\nNo" > "$temp_file"
        local choice
        choice=$(wofi --show dmenu \
            --prompt "Confirm $action?" \
            --width 300 \
            --height 150 \
            --location center \
            --insensitive \
            < "$temp_file")
        rm -f "$temp_file"
        [[ "$choice" == "Yes" ]]
    elif command -v zenity >/dev/null 2>&1; then
        zenity --question --text="Are you sure you want to $action?"
    else
        # Fallback to terminal confirmation
        read -p "Are you sure you want to $action? [y/N]: " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]]
    fi
}

send_notification() {
    local title="$1"
    local message="$2"
    local icon="$3"
    local urgency="${4:-normal}"
    
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$title" "$message" -i "$icon" -u "$urgency" -t 3000
    fi
}

countdown_notification() {
    local action="$1"
    local seconds="$2"
    
    for ((i=seconds; i>0; i--)); do
        send_notification "Power Menu" "$action in $i seconds..." "system-shutdown" "normal"
        sleep 1
    done
}

perform_shutdown() {
    if confirm_action "shutdown" "$SHUTDOWN_ICON"; then
        send_notification "Power Menu" "Shutting down system..." "system-shutdown" "critical"
        countdown_notification "Shutdown" 3
        
        # Try different shutdown methods
        if command -v systemctl >/dev/null 2>&1; then
            systemctl poweroff
        elif command -v shutdown >/dev/null 2>&1; then
            sudo shutdown -h now
        else
            sudo poweroff
        fi
    fi
}

perform_reboot() {
    if confirm_action "reboot" "$REBOOT_ICON"; then
        send_notification "Power Menu" "Rebooting system..." "system-reboot" "critical"
        countdown_notification "Reboot" 3
        
        # Try different reboot methods
        if command -v systemctl >/dev/null 2>&1; then
            systemctl reboot
        elif command -v shutdown >/dev/null 2>&1; then
            sudo shutdown -r now
        else
            sudo reboot
        fi
    fi
}

perform_logout() {
    if confirm_action "logout" "$LOGOUT_ICON"; then
        send_notification "Power Menu" "Logging out..." "system-log-out" "normal"
        
        # Hyprland logout
        if [[ "$XDG_CURRENT_DESKTOP" == "Hyprland" ]]; then
            hyprctl dispatch exit
        # GNOME logout
        elif [[ "$XDG_CURRENT_DESKTOP" == "GNOME" ]]; then
            gnome-session-quit --logout --no-prompt
        # KDE logout
        elif [[ "$XDG_CURRENT_DESKTOP" == "KDE" ]]; then
            qdbus org.kde.ksmserver /KSMServer logout 0 0 0
        # XFCE logout
        elif [[ "$XDG_CURRENT_DESKTOP" == "XFCE" ]]; then
            xfce4-session-logout --logout
        # Generic X11 logout
        elif [[ -n "$DISPLAY" ]]; then
            killall -u "$USER"
        # Fallback
        else
            loginctl terminate-user "$USER"
        fi
    fi
}

perform_lock() {
    send_notification "Power Menu" "Locking screen..." "system-lock-screen" "normal"
    
    # Try different lock methods in order of preference
    if command -v hyprlock >/dev/null 2>&1; then
        hyprlock
    elif command -v swaylock >/dev/null 2>&1; then
        swaylock -f -c "$BG_COLOR" --ring-color "$ACCENT_COLOR" --key-hl-color "$SUCCESS_COLOR" --line-color "$BG_COLOR" --inside-color "$BG_COLOR"
    elif command -v i3lock >/dev/null 2>&1; then
        i3lock -c "${BG_COLOR#\#}"
    elif command -v gnome-screensaver-command >/dev/null 2>&1; then
        gnome-screensaver-command -l
    elif command -v xdg-screensaver >/dev/null 2>&1; then
        xdg-screensaver lock
    elif command -v dm-tool >/dev/null 2>&1; then
        dm-tool lock
    else
        send_notification "Power Menu" "No lock screen found!" "dialog-error" "critical"
        return 1
    fi
}

perform_suspend() {
    if confirm_action "suspend" "$SUSPEND_ICON"; then
        send_notification "Power Menu" "Suspending system..." "system-suspend" "normal"
        
        # Lock screen before suspend if lock is available
        if command -v hyprlock >/dev/null 2>&1 || command -v swaylock >/dev/null 2>&1 || command -v i3lock >/dev/null 2>&1; then
            perform_lock &
            sleep 1
        fi
        
        # Suspend system
        if command -v systemctl >/dev/null 2>&1; then
            systemctl suspend
        elif command -v pm-suspend >/dev/null 2>&1; then
            sudo pm-suspend
        else
            echo mem | sudo tee /sys/power/state
        fi
    fi
}

show_help() {
    cat << EOF
Power Menu Script for Hyprland

Usage: $0 [OPTIONS] [ACTION]

OPTIONS:
    --launcher LAUNCHER    Use specific launcher (rofi, wofi, dmenu)
    --no-confirm          Skip confirmation dialogs
    --countdown SECONDS   Countdown time before action (default: 3)
    --help, -h            Show this help message

ACTIONS:
    shutdown              Shutdown the system
    reboot                Reboot the system
    logout                Logout current user
    lock                  Lock the screen
    suspend               Suspend the system

EXAMPLES:
    $0                    # Show interactive menu
    $0 shutdown           # Direct shutdown with confirmation
    $0 --no-confirm lock  # Lock without confirmation
    $0 --launcher wofi    # Use wofi launcher

LAUNCHERS:
    The script will automatically detect and use available launchers:
    1. Rofi (preferred for Wayland/X11)
    2. Wofi (Wayland native)
    3. Dmenu (X11 fallback)

LOCK SCREENS:
    The script supports multiple lock screens:
    1. Hyprlock (Hyprland native)
    2. Swaylock (Wayland)
    3. i3lock (X11)
    4. Desktop environment locks

DEPENDENCIES:
    - rofi OR wofi OR dmenu (for menu)
    - hyprlock OR swaylock OR i3lock (for lock)
    - systemctl OR shutdown (for power actions)
    - notify-send (for notifications)
EOF
}

# =================================
# MAIN SCRIPT
# =================================

main() {
    local launcher=""
    local no_confirm=false
    local countdown_time=3
    local direct_action=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --launcher)
                launcher="$2"
                shift 2
                ;;
            --no-confirm)
                no_confirm=true
                shift
                ;;
            --countdown)
                countdown_time="$2"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            shutdown|reboot|logout|lock|suspend)
                direct_action="$1"
                shift
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Handle direct actions
    if [[ -n "$direct_action" ]]; then
        case "$direct_action" in
            shutdown)
                if [[ "$no_confirm" == true ]]; then
                    send_notification "Power Menu" "Shutting down system..." "system-shutdown" "critical"
                    countdown_notification "Shutdown" "$countdown_time"
                    systemctl poweroff
                else
                    perform_shutdown
                fi
                ;;
            reboot)
                if [[ "$no_confirm" == true ]]; then
                    send_notification "Power Menu" "Rebooting system..." "system-reboot" "critical"
                    countdown_notification "Reboot" "$countdown_time"
                    systemctl reboot
                else
                    perform_reboot
                fi
                ;;
            logout)
                if [[ "$no_confirm" == true ]]; then
                    send_notification "Power Menu" "Logging out..." "system-log-out" "normal"
                    hyprctl dispatch exit
                else
                    perform_logout
                fi
                ;;
            lock)
                perform_lock
                ;;
            suspend)
                if [[ "$no_confirm" == true ]]; then
                    perform_lock &
                    sleep 1
                    systemctl suspend
                else
                    perform_suspend
                fi
                ;;
        esac
        exit 0
    fi
    
    # Show interactive menu
    local choice
    
    # Determine which launcher to use
    if [[ -z "$launcher" ]]; then
        if command -v rofi >/dev/null 2>&1; then
            launcher="rofi"
        elif command -v wofi >/dev/null 2>&1; then
            launcher="wofi"
        elif command -v dmenu >/dev/null 2>&1; then
            launcher="dmenu"
        else
            echo "Error: No supported launcher found (rofi, wofi, or dmenu)"
            exit 1
        fi
    fi
    
    # Show menu based on launcher
    case "$launcher" in
        rofi)
            choice=$(show_rofi_menu)
            ;;
        wofi)
            choice=$(show_wofi_menu)
            ;;
        dmenu)
            choice=$(show_dmenu_menu)
            ;;
        *)
            echo "Error: Unsupported launcher: $launcher"
            exit 1
            ;;
    esac
    
    # Handle menu choice
    case "$choice" in
        *"Shutdown"*)
            perform_shutdown
            ;;
        *"Reboot"*)
            perform_reboot
            ;;
        *"Logout"*)
            perform_logout
            ;;
        *"Lock"*)
            perform_lock
            ;;
        *"Suspend"*)
            perform_suspend
            ;;
        *"Cancel"*|"")
            send_notification "Power Menu" "Cancelled" "dialog-cancel" "normal"
            exit 0
            ;;
        *)
            echo "Unknown choice: $choice"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"