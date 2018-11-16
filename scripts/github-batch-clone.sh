#!/bin/bash

# dependency: https://stedolan.github.io/jq/
# usage: ./github-batch-clone.sh vrachieru # all repos via ssh for user
#        ./github-batch-clone.sh vrachieru --connection clone --limit 1 # 1st repo (sorted alphabetically) via http

type='user' # user or org
connection='ssh' # git, ssh or clone (http)
limit=100

eval set -- `getopt -o tcl: --long type:,connection:,limit: -- "$@"`

while true; do
  case "${1}" in
    --type) type="${2}"; shift 2 ;;
    --connection) connection="${2}"; shift 2 ;;
    --limit) limit="${2}"; shift 2 ;;
    --) shift; break ;;
    *) break ;;
  esac
done

id="${1}"

repos=`curl -s "https://api.github.com/${type}s/${id}/repos?per_page=${limit}"`
repo_urls=(`echo "${repos}" | jq -r ".[].${connection}_url"`)

mkdir -p "${id}"
cd "${id}"

echo "Found ${#repo_urls[@]} projects"
for repo_url in "${repo_urls[@]}"; do
    git clone "${repo_url}"
done
