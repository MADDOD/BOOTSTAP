install_module() {

    local module="$1"

    info "Installing ${module}..."

    if bash "modules/${module}.sh"
    then
        success "${module} installed."
    else
        warning "${module} failed."
    fi
}