#!/bin/bash

AUTHOR="$(git config user.name)"

WEEKSTART="1:Monday"
WEEKEND="5:Friday"

SINCE="yesterday"

if [[ ${WEEKSTART%%:*} == $(date +%u) ]]; then 
  SINCE="last ${WEEKEND#*:}";
fi

git log --since "$SINCE" --all --abbrev-commit --no-merges --oneline --committer="$AUTHOR" --pretty=format:'%Cred%h%Creset - %s %Cgreen(%cr)%Creset'
