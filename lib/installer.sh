#!/usr/bin/env bash

install_module() {
    local module="$1"
    local module_file
    module_file="$(dirname "${BASH_SOURCE[0]}")/../module/${module}.sh"

    log_info "Installing ${module}..."

    if [[ ! -f "$module_file" ]]; then
        log_error "Module not found: ${module}"
        return 1
    fi

    if source "$module_file"; then
        log_success "${module} installed."
    else
        log_warning "${module} failed."
    fi
}
