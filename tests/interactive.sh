#!/bin/bash

docker run -it -v "$(pwd):/workspace" -w /workspace ubuntu bash -c "apt-get update && apt-get install -y git zsh; zsh -c './install.sh'"
