#!/bin/bash

set -eo pipefail

wget https://raw.githubusercontent.com/apptainer/apptainer/main/tools/install-unprivileged.sh

chmod +x install-unprivileged.sh

mkdir -p /opt/apptainer
mkdir -p ${HOME}/.apptainer/cache/images

./install-unprivileged.sh /opt/apptainer

echo "/opt/apptainer/bin" >> $GITHUB_PATH
