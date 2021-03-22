#!/usr/bin/env zsh
. ~/.zshrc

for ENVIRONMENT in 'delius-core-dev'; do
  ENVIRONMENT=$ENVIRONMENT CMD=bash tg utility_scripts/import-log-groups.sh
done
