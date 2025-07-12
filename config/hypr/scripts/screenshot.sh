#!/bin/bash

# Screenshot Script for Hyprland
# Ultimate Ricing Setup for Arch Linux
# Supports full screen, area selection, and window capture

# =================================
# CONFIGURATION
# =================================

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
TEMP_DIR="/tmp"
DATE=$(date '+%Y-%m-%d_%H-%M-%S')

# =================================
# COLORS
# =================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# =================================
# FUNCTIONS
# =================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

show_help() {
    cat << EOF
Screenshot Script for Hyprland

Usage: $0 [OPTIONS]

OPTIONS:
    --full, -f          Take fullscreen screenshot
    --area, -a          Take area selection screenshot
    --window, -w        Take active window screenshot
    --output, -o FILE   Specify output filename
    --clipboard, -c     Copy to clipboard only (no file)
    --edit, -e          Open screenshot in editor after capture
    --delay, -d SECS    Delay before capture (default: 0)
    --silent, -s        Silent mode (no notifications)
    --help, -h          Show this help message

EXAMPLES:
    $0 --full                    # Fullscreen screenshot
    $0 --area --edit             # Area selection with editor
    $0 --window --clipboard      # Window to clipboard
    $0 --full --delay 3          # Fullscreen with 3 second delay
    $0 --area -o custom.png      # Area selection with custom filename

KEYBINDINGS (configured in Hyprland):
    Print                        # Fullscreen screenshot
    Shift + Print                # Area selection
    Ctrl + Print                 # Active window
    Alt + Print                  # Clipboard only

FILES:
    Screenshots saved to: $SCREENSHOT_DIR
    Temporary files in: $TEMP_DIR
EOF
}

check_dependencies() {
    local missing_deps=()
    
    # Check required tools
    command -v grim >/dev/null 2>&1 || missing_deps+=("grim")
    command -v slurp >/dev/null 2>&1 || missing_deps+=("slurp")
    command -v wl-copy >/dev/null 2>&1 || missing_deps+=("wl-clipboard")
    command -v notify-send >/dev/null 2>&1 || missing_deps+=("libnotify")
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_info "Install with: yay -S ${missing_deps[*]}"
        exit 1
    fi
}

create_screenshot_dir() {
    if [[ ! -d "$SCREENSHOT_DIR" ]]; then
        mkdir -p "$SCREENSHOT_DIR"
        log_info "Created screenshot directory: $SCREENSHOT_DIR"
    fi
}

get_output_filename() {
    local prefix="$1"
    local custom_name="$2"
    
    if [[ -n "$custom_name" ]]; then
        if [[ "$custom_name" =~ \.(png|jpg|jpeg)$ ]]; then
            echo "$SCREENSHOT_DIR/$custom_name"
        else
            echo "$SCREENSHOT_DIR/${custom_name}.png"
        fi
    else
        echo "$SCREENSHOT_DIR/${prefix}_${DATE}.png"
    fi
}

apply_delay() {
    local delay="$1"
    if [[ "$delay" -gt 0 ]]; then
        log_info "Taking screenshot in $delay seconds..."
        for ((i=delay; i>0; i--)); do
            if [[ "$silent_mode" != true ]]; then
                notify-send "Screenshot" "Taking screenshot in $i seconds..." -t 1000 -i camera-photo
            fi
            sleep 1
        done
    fi
}

send_notification() {
    local title="$1"
    local message="$2"
    local icon="$3"
    local file="$4"
    
    if [[ "$silent_mode" != true ]]; then
        if [[ -n "$file" ]] && [[ -f "$file" ]]; then
            notify-send "$title" "$message" -i "$file" -t 3000
        else
            notify-send "$title" "$message" -i "$icon" -t 3000
        fi
    fi
}

copy_to_clipboard() {
    local file="$1"
    if [[ -f "$file" ]]; then
        wl-copy < "$file"
        log_success "Copied to clipboard"
    else
        log_error "Failed to copy to clipboard: file not found"
    fi
}

open_editor() {
    local file="$1"
    if [[ -f "$file" ]]; then
        # Try different editors in order of preference
        if command -v swappy >/dev/null 2>&1; then
            swappy -f "$file" &
        elif command -v gimp >/dev/null 2>&1; then
            gimp "$file" &
        elif command -v krita >/dev/null 2>&1; then
            krita "$file" &
        elif command -v pinta >/dev/null 2>&1; then
            pinta "$file" &
        else
            log_warning "No image editor found. Install swappy, gimp, or krita"
            return 1
        fi
        log_info "Opened in editor"
    fi
}

take_fullscreen() {
    local output_file="$1"
    local temp_file="$TEMP_DIR/screenshot_full_$$.png"
    
    log_info "Taking fullscreen screenshot..."
    
    if grim "$temp_file"; then
        if [[ "$clipboard_only" == true ]]; then
            copy_to_clipboard "$temp_file"
            send_notification "Screenshot" "Fullscreen copied to clipboard" "camera-photo"
            rm -f "$temp_file"
        else
            mv "$temp_file" "$output_file"
            log_success "Screenshot saved: $output_file"
            send_notification "Screenshot" "Fullscreen saved" "camera-photo" "$output_file"
            
            if [[ "$copy_clipboard" == true ]]; then
                copy_to_clipboard "$output_file"
            fi
            
            if [[ "$open_editor_flag" == true ]]; then
                open_editor "$output_file"
            fi
        fi
        return 0
    else
        log_error "Failed to take fullscreen screenshot"
        rm -f "$temp_file"
        return 1
    fi
}

take_area() {
    local output_file="$1"
    local temp_file="$TEMP_DIR/screenshot_area_$$.png"
    
    log_info "Select area for screenshot..."
    
    # Get area selection
    local area
    area=$(slurp -d -c '#7aa2f7' -b '#1a1b2688' -s '#7dcfff33' -w 3)
    
    if [[ -z "$area" ]]; then
        log_warning "Area selection cancelled"
        return 1
    fi
    
    if grim -g "$area" "$temp_file"; then
        if [[ "$clipboard_only" == true ]]; then
            copy_to_clipboard "$temp_file"
            send_notification "Screenshot" "Area selection copied to clipboard" "camera-photo"
            rm -f "$temp_file"
        else
            mv "$temp_file" "$output_file"
            log_success "Screenshot saved: $output_file"
            send_notification "Screenshot" "Area selection saved" "camera-photo" "$output_file"
            
            if [[ "$copy_clipboard" == true ]]; then
                copy_to_clipboard "$output_file"
            fi
            
            if [[ "$open_editor_flag" == true ]]; then
                open_editor "$output_file"
            fi
        fi
        return 0
    else
        log_error "Failed to take area screenshot"
        rm -f "$temp_file"
        return 1
    fi
}

take_window() {
    local output_file="$1"
    local temp_file="$TEMP_DIR/screenshot_window_$$.png"
    
    log_info "Taking active window screenshot..."
    
    # Get active window
    local active_window
    active_window=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
    
    if [[ -z "$active_window" ]] || [[ "$active_window" == "null null nullxnull" ]]; then
        log_error "No active window found"
        return 1
    fi
    
    if grim -g "$active_window" "$temp_file"; then
        if [[ "$clipboard_only" == true ]]; then
            copy_to_clipboard "$temp_file"
            send_notification "Screenshot" "Window copied to clipboard" "camera-photo"
            rm -f "$temp_file"
        else
            mv "$temp_file" "$output_file"
            log_success "Screenshot saved: $output_file"
            send_notification "Screenshot" "Window screenshot saved" "camera-photo" "$output_file"
            
            if [[ "$copy_clipboard" == true ]]; then
                copy_to_clipboard "$output_file"
            fi
            
            if [[ "$open_editor_flag" == true ]]; then
                open_editor "$output_file"
            fi
        fi
        return 0
    else
        log_error "Failed to take window screenshot"
        rm -f "$temp_file"
        return 1
    fi
}

# =================================
# MAIN SCRIPT
# =================================

main() {
    # Default values
    local mode=""
    local custom_filename=""
    local delay=0
    local clipboard_only=false
    local copy_clipboard=false
    local open_editor_flag=false
    local silent_mode=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --full|-f)
                mode="full"
                shift
                ;;
            --area|-a)
                mode="area"
                shift
                ;;
            --window|-w)
                mode="window"
                shift
                ;;
            --output|-o)
                custom_filename="$2"
                shift 2
                ;;
            --clipboard|-c)
                clipboard_only=true
                copy_clipboard=true
                shift
                ;;
            --edit|-e)
                open_editor_flag=true
                shift
                ;;
            --delay|-d)
                delay="$2"
                shift 2
                ;;
            --silent|-s)
                silent_mode=true
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
    
    # Set default mode if none specified
    if [[ -z "$mode" ]]; then
        mode="full"
    fi
    
    # Check dependencies
    check_dependencies
    
    # Create screenshot directory
    create_screenshot_dir
    
    # Apply delay if specified
    apply_delay "$delay"
    
    # Determine output filename
    local output_file
    case "$mode" in
        full)
            output_file=$(get_output_filename "fullscreen" "$custom_filename")
            ;;
        area)
            output_file=$(get_output_filename "area" "$custom_filename")
            ;;
        window)
            output_file=$(get_output_filename "window" "$custom_filename")
            ;;
    esac
    
    # Take screenshot based on mode
    case "$mode" in
        full)
            take_fullscreen "$output_file"
            ;;
        area)
            take_area "$output_file"
            ;;
        window)
            take_window "$output_file"
            ;;
        *)
            log_error "Invalid mode: $mode"
            exit 1
            ;;
    esac
}

# Export variables for use in functions
export silent_mode clipboard_only copy_clipboard open_editor_flag

# Run main function
main "$@"