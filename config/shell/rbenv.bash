#!/usr/bin/env bash

if [[ $currentShell == "bash" ]]; then
  rbin="${HOME}/xfiles/config/rbenv/bin"
  if [ -d $rbin ]; then
    export RBENV_ROOT=${HOME}/xfiles/config/rbenv
    export RBENV_SHELL=bash
    export BUNDLE_PATH=${HOME}/.Gemfile
    source ${HOME}/xfiles/config/rbenv/completions/rbenv.bash
  fi
fi