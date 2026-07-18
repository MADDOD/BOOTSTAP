#!/usr/bin/env bash

banner(){

echo

echo "====================================="
echo "     Linux Bootstrap v1.0"
echo "====================================="

echo

}

require_root(){

if [[ $EUID -eq 0 ]]
then
    log_error "Do not run bootstrap as root."
    exit 1
fi

}