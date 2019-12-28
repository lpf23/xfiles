#!/usr/bin/env bash

if [[ "$OSTYPE" == "linux-gnu"* ]]; then

  if [[ "$linuxFlavor" == "centos" ]]; then
    alias yum='sudo yum'
    yup() {
      sudo yum update
    }
  elif [[ "$linuxFlavor" == "ubuntu" ]]; then
    alias apt-get='sudo apt-get'
    aup() {
      sudo apt-get update
      sudo apt-get upgrade -y
    }
  fi

fi