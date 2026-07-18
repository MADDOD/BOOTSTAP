#!/usr/bin/env bash

install_list packages/docker.list

if ! command -v docker >/dev/null 2>&1
then

log_info "Installing Docker..."

curl -fsSL https://get.docker.com | sh

sudo usermod -aG docker "$USER"

log_success "Docker Installed"

fi

if ! docker compose version >/dev/null 2>&1
then

log_info "Installing Docker Compose Plugin"

sudo apt install -y docker-compose-plugin

fi