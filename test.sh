#!/bin/bash

. ./scripts/lib/utils.sh

list=("ll" "find")

for tool in "${list[@]}"; do
  install "${tool}"
done
