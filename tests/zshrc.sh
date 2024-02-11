#!/usr/bin/env zunit
# shellcheck shell=bash

@test 'Testing aliases' {
  load ../.zshrc

  assert "$(alias fdebug)" same_as 'curl -svo /dev/null -H "Fastly-Debug: true"'
}
