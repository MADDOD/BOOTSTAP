#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_DIR/lib/colors.sh"
source "$PROJECT_DIR/lib/logger.sh"
source "$PROJECT_DIR/lib/utils.sh"

SUCCESS=0
FAILED=0
SKIPPED=0

ALL_MODULES=(
    system
    dev
    docker
    fonts
    network
    ai
    desktop
    embedded
)

install_package(){
    local PACKAGE="$1"

    if dpkg -s "$PACKAGE" >/dev/null 2>&1; then
        log_warning "$PACKAGE already installed"
        SKIPPED=$((SKIPPED + 1))
        return
    fi

    if ! apt-cache show "$PACKAGE" >/dev/null 2>&1; then
        log_warning "$PACKAGE not found in repos"
        SKIPPED=$((SKIPPED + 1))
        return
    fi

    log_info "Installing $PACKAGE"

    if sudo apt install -y "$PACKAGE"; then
        log_success "$PACKAGE installed"
        SUCCESS=$((SUCCESS + 1))
    else
        log_error "$PACKAGE failed to install"
        FAILED=$((FAILED + 1))
    fi
}

install_list(){
    local FILE="$1"

    if [[ ! -f "$FILE" ]]; then
        FILE="$PROJECT_DIR/$1"
    fi

    if [[ ! -f "$FILE" ]]; then
        log_warning "Package list not found: $1"
        return
    fi

    while IFS= read -r PACKAGE
    do
        [[ -z "$PACKAGE" ]] && continue
        [[ "$PACKAGE" =~ ^# ]] && continue
        install_package "$PACKAGE"
    done < "$FILE"
}

install_module(){
    local MODULE="$1"
    local MODULE_FILE="$PROJECT_DIR/module/${MODULE}.sh"

    log_info "Running module: $MODULE"

    if [[ ! -f "$MODULE_FILE" ]]; then
        log_error "Module file not found: $MODULE_FILE"
        return
    fi

    source "$MODULE_FILE"
}

summary(){
    echo
    echo "===================================="
    echo " Installed : $SUCCESS"
    echo " Skipped   : $SKIPPED"
    echo " Failed    : $FAILED"
    echo "===================================="
}

select_modules(){
    echo
    echo "Available modules:"
    echo
    for i in "${!ALL_MODULES[@]}"; do
        echo "  $((i+1)). ${ALL_MODULES[$i]}"
    done
    echo
    echo "  a. All modules"
    echo
    read -rp "Select modules (space-separated numbers, or 'a' for all): " SELECTION

    SELECTED=()

    if [[ "$SELECTION" == "a" || "$SELECTION" == "A" ]]; then
        SELECTED=("${ALL_MODULES[@]}")
    else
        for NUM in $SELECTION; do
            if [[ "$NUM" =~ ^[0-9]+$ ]] && (( NUM >= 1 && NUM <= ${#ALL_MODULES[@]} )); then
                SELECTED+=("${ALL_MODULES[$((NUM-1))]}")
            else
                log_warning "Invalid selection: $NUM"
            fi
        done
    fi

    if [[ ${#SELECTED[@]} -eq 0 ]]; then
        log_error "No valid modules selected. Exiting."
        exit 1
    fi
}

main(){
    banner

    if [[ $EUID -eq 0 ]]; then
        log_error "Do not run bootstrap as root. Use a regular user with sudo."
        exit 1
    fi

    sudo apt update

    select_modules

    echo
    log_info "Installing modules: ${SELECTED[*]}"
    echo

    for MODULE in "${SELECTED[@]}"; do
        install_module "$MODULE"
    done

    summary
}

main "$@"
