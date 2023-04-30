#!/usr/bin/env bats

load test_helper

@test "Test Environment Variables" {
	assert_env GIT_EDITOR vim
	assert_env KUBE_EDITOR vim
	assert_env FZF_DEFAULT_COMMAND "find ."
}

@test "Test Aliases" {
 	assert_alias fdebug 'curl -svo /dev/null -H "Fastly-Debug: true"'
	assert_alias hurl "curl -sLD - -o /dev/null"
	assert_alias reload 'source ~/.zshrc'
	assert_alias ttfb 'curl -o /dev/null -H "Cache-Control: no-cache" -s -w "Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} \n"'
	assert_alias grep 'grep --color=auto '
 	assert_alias vi vim
}
