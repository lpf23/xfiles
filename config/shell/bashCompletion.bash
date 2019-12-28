#!/usr/bin/env bash

if [[ $currentShell == "bash" ]]; then

  lbc="${HOME}/xfiles/config/bash-completion/etc/profile.d/bash_completion.sh"
  [ -f $lbc ] && source $lbc 2> /dev/null

fi