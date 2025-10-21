#!/usr/bin/env bash

function command_exists() {
  if [ $# -lt 1 ]; then
    return 1
  fi

  if command -v "$1" >/dev/null 2>&1; then
    if [ "${VERBOSE:-false}" = "true" ]; then
      echo "🚀 ${1} has installed!"
    fi
    return 0
  else
    if [ "${VERBOSE:-false}" = "true" ]; then
      echo "⚠️ Command: ${1} has not installed!"
    fi
    return 1
  fi
}

function install() {
  command_exists "${1}"
  checked_result=$?
  echo "${checked_result}"
  if [ ${checked_result} != '0' ]; then
    echo 'Start to install' "${1}."
    brew install "${1}"
    echo 'Successfully installed' "${1}!"
  fi
}


function install_cask() {
  command_exists "${1}"
  if ! command_exists "${1}"; then
    echo "Start to install ${1}."
    brew install --cask "$1"
    echo "🚀 Successfully installed ${1}!"
  fi
}


check_folder_exist_or_create() {
  local folder_name="$1"
  if [ ! -d "${folder_name}" ];then
    mkdir -p "$folder_name"
  else
    echo "💡 Folder: ${folder_name} is existing!"
  fi
  echo "🚀 Successfully created ${folder_name}!"
}

todo() {
  echo "⭕⭕⭕⭕⭕⭕⭕⭕⭕⭕==Todo==⭕⭕⭕⭕⭕⭕⭕⭕⭕⭕"
  echo "${1}"
  echo "⭕⭕⭕⭕⭕⭕⭕⭕⭕⭕==Todo==⭕⭕⭕⭕⭕⭕⭕⭕⭕⭕"
}
