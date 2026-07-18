#!/usr/bin/env bash

banner(){
    echo
    echo "====================================="
    echo "     Linux Bootstrap v1.0"
    echo "====================================="
    echo
}

require_root(){
    if [[ $EUID -ne 0 ]]; then
        log_error "This function requires root. Run with sudo."
        exit 1
    fi
}
