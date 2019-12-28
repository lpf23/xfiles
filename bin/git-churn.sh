#!/usr/bin/env bash

git --no-pager log --all --find-renames --find-copies --name-only --format='format:' "$@" \
  | grep -v '^$' \
  | sort \
  | uniq -c \
  | sort -nr \
  | head