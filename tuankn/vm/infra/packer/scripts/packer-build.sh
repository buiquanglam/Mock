#!/usr/bin/env bash

set -o errexit
set -o pipefail
function build_image() {
    export role_name=$1
    echo ${role_name}
    #Show info script
    packer inspect packer.json
    #Check error script
    packer validate -var-file variables.json packer.json
    #Create ami
    packer build -debug -var-file variables.json packer.json
}
echo $1
build_image $1