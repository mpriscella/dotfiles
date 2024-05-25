#!/bin/bash

context=$(kubectl config view --minify -o jsonpath='{.current-context}')
namespace=$(kubectl config view --minify -o jsonpath='{.contexts[0].context.namespace}')

echo "$context/$namespace"
