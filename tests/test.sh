#!/bin/bash

images=(
	# alpine
	ubuntu
)

for image in "${images[@]}"; do
	# Install bats
	docker run -v "$(pwd):/workspace" -w /workspace "$image" bash -c "apt-get update && apt-get install -y bats git zsh; bats tests/tests.bats"
done
