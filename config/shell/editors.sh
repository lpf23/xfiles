#!/usr/bin/env bash

if [[ -f "${HOME}/xfiles/nvim/bin/nvim" ]]; then
  export EDITOR="${HOME}/xfiles/nvim/bin/nvim"
  alias vim='nvim'
  alias vi='nvim'
  alias svi='sudo nvim'
  alias svim='sudo nvim'
  alias nvm='nvim'
else
  export EDITOR="/usr/bin/vi"
fi