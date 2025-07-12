#!/bin/bash

# Wallpaper Management Script for Hyprland
# Ultimate Ricing Setup for Arch Linux
# Manages wallpapers with swww and provides various display modes

# =================================
# CONFIGURATION
# =================================

WALLPAPER_DIR="$HOME/.local/share/wallpapers"
CONFIG_DIR="$HOME/.config/hypr"
CURRENT_WALLPAPER_FILE="$CONFIG_DIR/current_wallpaper"
FAVORITES_FILE="$CONFIG_DIR/favorite_wallpapers"

# Supported image formats
SUPPORTED_FORMATS="*.jpg *.jpeg *.png *.bmp *.gif *.webp"

# Default transition settings
DEFAULT_TRANSITION="wipe"
DEFAULT_DURATION="2"
DEFAULT_FPS="60"
DEFAULT_ANGLE="45"

# =================================
# COLORS
# =================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# =================================
# LOGGING FUNCTIONS
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

log_step() {
    echo -e "${PURPLE}[→]${NC} $1"
}

# =================================
# UTILITY FUNCTIONS
# =================================

show_help() {
    cat << EOF
Wallpaper Management Script for Hyprland

Usage: $0 [OPTIONS] [COMMAND]

COMMANDS:
    set FILE              Set specific wallpaper
    random                Set random wallpaper
    next                  Next wallpaper in directory
    prev                  Previous wallpaper in directory
    current               Show current wallpaper
    list                  List all wallpapers
    favorite [FILE]       Add/remove from favorites
    slideshow [INTERVAL]  Start slideshow (default: 300s)
    download URL [NAME]   Download wallpaper from URL
    init                  Initialize swww daemon
    kill                  Kill swww daemon

OPTIONS:
    --transition TYPE     Transition type (fade, wipe, grow, etc.)
    --duration SECONDS    Transition duration (default: 2)
    --fps FPS            Transition FPS (default: 60)
    --angle DEGREES      Transition angle (default: 45)
    --dir DIRECTORY      Wallpaper directory (default: ~/.local/share/wallpapers)
    --monitor MONITOR    Specific monitor (default: all)
    --help, -h           Show this help message

TRANSITION TYPES:
    none, fade, wipe, grow, outer, random, top, bottom, left, right,
    top-left, top-right, bottom-left, bottom-right, center

EXAMPLES:
    $0 set ~/Pictures/wallpaper.jpg    # Set specific wallpaper
    $0 random --transition fade        # Random wallpaper with fade
    $0 slideshow 600                   # Slideshow every 10 minutes
    $0 download "https://example.com/wall.jpg" "tokyo-night"
    $0 favorite                        # List favorites
    $0 favorite ~/wall.jpg             # Add to favorites

KEYBINDINGS (add to Hyprland config):
    bind = SUPER, W, exec, ~/.config/hypr/scripts/wallpaper.sh random
    bind = SUPER_SHIFT, W, exec, ~/.config/hypr/scripts/wallpaper.sh slideshow

FILES:
    Wallpapers: $WALLPAPER_DIR
    Current: $CURRENT_WALLPAPER_FILE
    Favorites: $FAVORITES_FILE
EOF
}

check_dependencies() {
    local missing_deps=()
    
    command -v swww >/dev/null 2>&1 || missing_deps+=("swww")
    command -v notify-send >/dev/null 2>&1 || missing_deps+=("libnotify")
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_info "Install with: yay -S ${missing_deps[*]}"
        exit 1
    fi
}

init_directories() {
    # Create wallpaper directory if it doesn't exist
    if [[ ! -d "$WALLPAPER_DIR" ]]; then
        mkdir -p "$WALLPAPER_DIR"
        log_info "Created wallpaper directory: $WALLPAPER_DIR"
    fi
    
    # Create config directory if it doesn't exist
    if [[ ! -d "$CONFIG_DIR" ]]; then
        mkdir -p "$CONFIG_DIR"
        log_info "Created config directory: $CONFIG_DIR"
    fi
    
    # Initialize favorites file
    if [[ ! -f "$FAVORITES_FILE" ]]; then
        touch "$FAVORITES_FILE"
        log_info "Created favorites file: $FAVORITES_FILE"
    fi
}

init_swww() {
    if ! pgrep -x "swww-daemon" > /dev/null; then
        log_step "Starting swww daemon..."
        swww init
        sleep 2
        log_success "swww daemon started"
    else
        log_success "swww daemon already running"
    fi
}

kill_swww() {
    if pgrep -x "swww-daemon" > /dev/null; then
        log_step "Stopping swww daemon..."
        swww kill
        log_success "swww daemon stopped"
    else
        log_warning "swww daemon not running"
    fi
}

get_wallpapers() {
    local dir="$1"
    find "$dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.gif" -o -iname "*.webp" \) 2>/dev/null | sort
}

send_notification() {
    local title="$1"
    local message="$2"
    local image="$3"
    
    if command -v notify-send >/dev/null 2>&1; then
        if [[ -n "$image" ]] && [[ -f "$image" ]]; then
            notify-send "$title" "$message" -i "$image" -t 3000
        else
            notify-send "$title" "$message" -i "image-x-generic" -t 3000
        fi
    fi
}

set_wallpaper() {
    local wallpaper="$1"
    local transition="${2:-$DEFAULT_TRANSITION}"
    local duration="${3:-$DEFAULT_DURATION}"
    local fps="${4:-$DEFAULT_FPS}"
    local angle="${5:-$DEFAULT_ANGLE}"
    local monitor="$6"
    
    # Check if wallpaper file exists
    if [[ ! -f "$wallpaper" ]]; then
        log_error "Wallpaper file not found: $wallpaper"
        return 1
    fi
    
    # Initialize swww if not running
    init_swww
    
    # Build swww command
    local cmd="swww img \"$wallpaper\" --transition-type $transition --transition-duration $duration --transition-fps $fps"
    
    if [[ "$transition" == "wipe" ]] || [[ "$transition" == "grow" ]]; then
        cmd="$cmd --transition-angle $angle"
    fi
    
    if [[ -n "$monitor" ]]; then
        cmd="$cmd --output $monitor"
    fi
    
    # Execute command
    log_step "Setting wallpaper: $(basename "$wallpaper")"
    if eval "$cmd"; then
        # Save current wallpaper
        echo "$wallpaper" > "$CURRENT_WALLPAPER_FILE"
        log_success "Wallpaper set successfully"
        send_notification "Wallpaper Changed" "$(basename "$wallpaper")" "$wallpaper"
        return 0
    else
        log_error "Failed to set wallpaper"
        return 1
    fi
}

get_current_wallpaper() {
    if [[ -f "$CURRENT_WALLPAPER_FILE" ]]; then
        cat "$CURRENT_WALLPAPER_FILE"
    else
        echo ""
    fi
}

set_random_wallpaper() {
    local dir="${1:-$WALLPAPER_DIR}"
    local wallpapers
    mapfile -t wallpapers < <(get_wallpapers "$dir")
    
    if [[ ${#wallpapers[@]} -eq 0 ]]; then
        log_error "No wallpapers found in $dir"
        return 1
    fi
    
    local random_wallpaper="${wallpapers[RANDOM % ${#wallpapers[@]}]}"
    set_wallpaper "$random_wallpaper" "$@"
}

get_wallpaper_index() {
    local current="$1"
    local dir="${2:-$WALLPAPER_DIR}"
    local wallpapers
    mapfile -t wallpapers < <(get_wallpapers "$dir")
    
    for i in "${!wallpapers[@]}"; do
        if [[ "${wallpapers[$i]}" == "$current" ]]; then
            echo "$i"
            return 0
        fi
    done
    echo "-1"
}

set_next_wallpaper() {
    local dir="${1:-$WALLPAPER_DIR}"
    local current
    current=$(get_current_wallpaper)
    local wallpapers
    mapfile -t wallpapers < <(get_wallpapers "$dir")
    
    if [[ ${#wallpapers[@]} -eq 0 ]]; then
        log_error "No wallpapers found in $dir"
        return 1
    fi
    
    local current_index
    current_index=$(get_wallpaper_index "$current" "$dir")
    
    local next_index=$(( (current_index + 1) % ${#wallpapers[@]} ))
    set_wallpaper "${wallpapers[$next_index]}" "$@"
}

set_previous_wallpaper() {
    local dir="${1:-$WALLPAPER_DIR}"
    local current
    current=$(get_current_wallpaper)
    local wallpapers
    mapfile -t wallpapers < <(get_wallpapers "$dir")
    
    if [[ ${#wallpapers[@]} -eq 0 ]]; then
        log_error "No wallpapers found in $dir"
        return 1
    fi
    
    local current_index
    current_index=$(get_wallpaper_index "$current" "$dir")
    
    local prev_index=$(( (current_index - 1 + ${#wallpapers[@]}) % ${#wallpapers[@]} ))
    set_wallpaper "${wallpapers[$prev_index]}" "$@"
}

list_wallpapers() {
    local dir="${1:-$WALLPAPER_DIR}"
    local wallpapers
    mapfile -t wallpapers < <(get_wallpapers "$dir")
    
    if [[ ${#wallpapers[@]} -eq 0 ]]; then
        log_warning "No wallpapers found in $dir"
        return 1
    fi
    
    log_info "Found ${#wallpapers[@]} wallpapers in $dir:"
    local current
    current=$(get_current_wallpaper)
    
    for wallpaper in "${wallpapers[@]}"; do
        local basename_wp
        basename_wp=$(basename "$wallpaper")
        if [[ "$wallpaper" == "$current" ]]; then
            echo -e "  ${GREEN}→ $basename_wp${NC} (current)"
        else
            echo "    $basename_wp"
        fi
    done
}

manage_favorites() {
    local action="$1"
    local wallpaper="$2"
    
    case "$action" in
        list)
            if [[ -f "$FAVORITES_FILE" ]] && [[ -s "$FAVORITES_FILE" ]]; then
                log_info "Favorite wallpapers:"
                while IFS= read -r fav; do
                    if [[ -f "$fav" ]]; then
                        echo "  $(basename "$fav")"
                    fi
                done < "$FAVORITES_FILE"
            else
                log_warning "No favorite wallpapers found"
            fi
            ;;
        add)
            if [[ -z "$wallpaper" ]]; then
                wallpaper=$(get_current_wallpaper)
            fi
            
            if [[ ! -f "$wallpaper" ]]; then
                log_error "Wallpaper file not found: $wallpaper"
                return 1
            fi
            
            if grep -Fxq "$wallpaper" "$FAVORITES_FILE" 2>/dev/null; then
                log_warning "Already in favorites: $(basename "$wallpaper")"
            else
                echo "$wallpaper" >> "$FAVORITES_FILE"
                log_success "Added to favorites: $(basename "$wallpaper")"
            fi
            ;;
        remove)
            if [[ -z "$wallpaper" ]]; then
                wallpaper=$(get_current_wallpaper)
            fi
            
            if grep -Fxq "$wallpaper" "$FAVORITES_FILE" 2>/dev/null; then
                grep -Fxv "$wallpaper" "$FAVORITES_FILE" > "${FAVORITES_FILE}.tmp" && mv "${FAVORITES_FILE}.tmp" "$FAVORITES_FILE"
                log_success "Removed from favorites: $(basename "$wallpaper")"
            else
                log_warning "Not in favorites: $(basename "$wallpaper")"
            fi
            ;;
        *)
            # Default to list if no action specified
            manage_favorites "list"
            ;;
    esac
}

download_wallpaper() {
    local url="$1"
    local name="$2"
    
    if [[ -z "$url" ]]; then
        log_error "URL required"
        return 1
    fi
    
    # Determine filename
    local filename
    if [[ -n "$name" ]]; then
        # Get file extension from URL
        local ext="${url##*.}"
        case "$ext" in
            jpg|jpeg|png|bmp|gif|webp)
                filename="$name.$ext"
                ;;
            *)
                filename="$name.jpg"
                ;;
        esac
    else
        filename=$(basename "$url")
    fi
    
    local output_path="$WALLPAPER_DIR/$filename"
    
    log_step "Downloading wallpaper: $filename"
    if command -v curl >/dev/null 2>&1; then
        if curl -L "$url" -o "$output_path"; then
            log_success "Downloaded: $output_path"
            
            # Ask if user wants to set it immediately
            if command -v rofi >/dev/null 2>&1; then
                local choice
                choice=$(echo -e "Yes\nNo" | rofi -dmenu -p "Set as wallpaper?")
                if [[ "$choice" == "Yes" ]]; then
                    set_wallpaper "$output_path"
                fi
            fi
        else
            log_error "Failed to download wallpaper"
            return 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget "$url" -O "$output_path"; then
            log_success "Downloaded: $output_path"
        else
            log_error "Failed to download wallpaper"
            return 1
        fi
    else
        log_error "curl or wget required for downloading"
        return 1
    fi
}

start_slideshow() {
    local interval="${1:-300}"  # Default 5 minutes
    local dir="${2:-$WALLPAPER_DIR}"
    
    log_info "Starting slideshow (interval: ${interval}s, directory: $dir)"
    send_notification "Wallpaper Slideshow" "Started with ${interval}s interval" 
    
    # Create PID file to track slideshow
    local pid_file="/tmp/wallpaper_slideshow.pid"
    echo $$ > "$pid_file"
    
    # Trap to clean up on exit
    trap 'rm -f "$pid_file"; exit' INT TERM EXIT
    
    while [[ -f "$pid_file" ]]; do
        set_random_wallpaper "$dir"
        sleep "$interval"
    done
}

stop_slideshow() {
    local pid_file="/tmp/wallpaper_slideshow.pid"
    
    if [[ -f "$pid_file" ]]; then
        local pid
        pid=$(cat "$pid_file")
        if kill "$pid" 2>/dev/null; then
            log_success "Slideshow stopped"
            send_notification "Wallpaper Slideshow" "Stopped"
        else
            log_warning "Failed to stop slideshow (PID: $pid)"
        fi
        rm -f "$pid_file"
    else
        log_warning "No slideshow running"
    fi
}

# =================================
# MAIN SCRIPT
# =================================

main() {
    # Default values
    local transition="$DEFAULT_TRANSITION"
    local duration="$DEFAULT_DURATION"
    local fps="$DEFAULT_FPS"
    local angle="$DEFAULT_ANGLE"
    local monitor=""
    local wallpaper_dir="$WALLPAPER_DIR"
    local command=""
    local args=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --transition)
                transition="$2"
                shift 2
                ;;
            --duration)
                duration="$2"
                shift 2
                ;;
            --fps)
                fps="$2"
                shift 2
                ;;
            --angle)
                angle="$2"
                shift 2
                ;;
            --dir)
                wallpaper_dir="$2"
                shift 2
                ;;
            --monitor)
                monitor="$2"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            set|random|next|prev|current|list|favorite|slideshow|download|init|kill|stop)
                command="$1"
                shift
                args=("$@")
                break
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Check dependencies
    check_dependencies
    
    # Initialize directories
    init_directories
    
    # Execute command
    case "$command" in
        set)
            if [[ ${#args[@]} -eq 0 ]]; then
                log_error "Wallpaper file required"
                exit 1
            fi
            set_wallpaper "${args[0]}" "$transition" "$duration" "$fps" "$angle" "$monitor"
            ;;
        random)
            set_random_wallpaper "$wallpaper_dir" "$transition" "$duration" "$fps" "$angle" "$monitor"
            ;;
        next)
            set_next_wallpaper "$wallpaper_dir" "$transition" "$duration" "$fps" "$angle" "$monitor"
            ;;
        prev)
            set_previous_wallpaper "$wallpaper_dir" "$transition" "$duration" "$fps" "$angle" "$monitor"
            ;;
        current)
            local current
            current=$(get_current_wallpaper)
            if [[ -n "$current" ]]; then
                echo "Current wallpaper: $(basename "$current")"
                echo "Full path: $current"
            else
                echo "No current wallpaper set"
            fi
            ;;
        list)
            list_wallpapers "$wallpaper_dir"
            ;;
        favorite)
            if [[ ${#args[@]} -eq 0 ]]; then
                manage_favorites "list"
            else
                manage_favorites "add" "${args[0]}"
            fi
            ;;
        slideshow)
            start_slideshow "${args[0]}" "$wallpaper_dir"
            ;;
        download)
            if [[ ${#args[@]} -eq 0 ]]; then
                log_error "URL required"
                exit 1
            fi
            download_wallpaper "${args[0]}" "${args[1]}"
            ;;
        init)
            init_swww
            ;;
        kill)
            kill_swww
            ;;
        stop)
            stop_slideshow
            ;;
        "")
            log_error "Command required"
            show_help
            exit 1
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"