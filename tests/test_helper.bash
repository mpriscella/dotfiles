#!/usr/bin/env bash

#######################################
# Assert two values are equal.
# Arguments:
#   The actual value.
#   The expected value.
#######################################
assert_equal() {
  if [ "$1" != "$2" ]; then
    echo "Actual:     $1"
    echo "Expected:   $2"
    return 1
  fi
}

#######################################
# Assert an environment variable value is correct.
# Arguments:
#   The environment variable name.
#   The expected value.
#######################################
assert_env() {
	result=$(zsh -f -c "source .zshrc; echo \$$1")
	echo "The value of variable $1 is $result"
	assert_equal "$2" "$result"
}

#######################################
# Assert an alias value is correct.
# Arguments:
#   The alias.
#   The aliased command.
#######################################
assert_alias() {
	result=$(zsh -f -c "source .zshrc; alias $1")
	result=$(eval echo "$result")
	echo "The alias for $1 is $result"
	assert_equal "$1=$2" "$result"
}
