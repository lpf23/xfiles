#!/usr/bin/env bash

nvimDir="~/xfiles/nvim/bin/nvim"

if [[ -f "${nvimDir}" ]]; then
  export EDITOR="${nvimDir}"
  alias nvim=$EDITOR
  alias vim=$EDITOR
  alias vi=$EDITOR
  alias oldvi='/bin/vi'
  alias svi="sudo ${EDITOR}"
  alias svim="sudo ${EDITOR}"
  alias nvm=$EDITOR
  alias nv=$EDITOR
else
  export EDITOR="/usr/bin/vi"
fi