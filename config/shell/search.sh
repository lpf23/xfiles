#!/usr/bin/env bash

alias qfind="find . -name "     # qfind:  Quickly search for file
alias findPid="prs"             # findPid:  Legacy command mapped to 'prs'
ff() { find . -name "$1"; }     # ff:     Find file under the current directory
ffs() { find . -name "$1"'*'; } # ffs:    Find file whose name starts with a given string
ffe() { find . -name '*'"$1"; } # ffe:    Find file whose name ends with a given string
ftext ()												# ftext:	Search for text in all files in the current folder
{
  # -i case-insensitive
  # -I ignore binary files
  # -H causes filename to be printed
  # -r recursive search
  # -n causes line number to be printed
  # optional: -F treat search term as a literal, not a regular expression
  # optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
  grep -iIHrn --color=always "$1" . | less -r
}