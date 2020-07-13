#!/bin/bash

echo "Running test for Debian image."
docker run -v $(pwd):/home/workspace -w /home/workspace --entrypoint="/bin/sh" debian "/home/workspace/install.sh" > /dev/null 2>&1
status=$?

if [ $status -eq 1 ]; then
  echo "Debian image failed"
  exit 1
fi

echo "Running test for Ubuntu image."
docker run -v $(pwd):/home/workspace -w /home/workspace --entrypoint="/bin/sh" ubuntu "/home/workspace/install.sh" > /dev/null 2>&1
status=$?

if [ $status -eq 1 ]; then
  echo "Debian image failed"
  exit 1
fi

echo "Running test for Alpine image."
docker run -v $(pwd):/home/workspace -w /home/workspace --entrypoint="/bin/sh" alpine "/home/workspace/install.sh" > /dev/null 2>&1
status=$?

if [ $status -eq 1 ]; then
  echo "Debian image failed"
  exit 1
fi

echo "Running test for AmazonLinux image."
docker run -v $(pwd):/home/workspace -w /home/workspace --entrypoint="/bin/sh" amazonlinux "/home/workspace/install.sh" > /dev/null 2>&1
status=$?

if [ $status -eq 1 ]; then
  echo "Debian image failed"
  exit 1
fi
