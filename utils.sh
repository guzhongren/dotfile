#!/usr/bin/env bash

function command_exists() {
  if type "${1}"; then
      echo "🚀 ${1} has installed!"
      return 0;
  else
      echo "⚠️ Command: ${1} has not installed!"
      return 1;
  fi
}

function install() {
  command_exists "${1}"
  checked_result=$?
  echo ${checked_result}
  if [ ${checked_result} != '0' ]; then
    echo 'Start to install' "${1}"
    brew install "${1}"
    echo 'Successfully installed' "${1}"
  fi
}


function install_cask() {
  command_exists "${1}"
  if [ $? -ne 0 ]; then
    echo "Start to install ${1}"
    brew install --cask $1
    echo "🚀 Successfully installed ${1}"
  fi
}
