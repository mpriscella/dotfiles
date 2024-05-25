#!/bin/bash

account_id=$(aws sts get-caller-identity --query 'Account' --output text)
aws organizations describe-account --account-id "$account_id" --query 'Account.Name' --output text
