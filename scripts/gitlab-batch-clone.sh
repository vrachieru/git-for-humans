#!/bin/bash

# dependency: https://stedolan.github.io/jq/
# usage: ./gitlab-batch-clone.sh vrachieru # all repos via ssh for user
#        ./gitlab-batch-clone.sh vrachieru --token abc123 # all repos via ssh for user with authentication
#        ./gitlab-batch-clone.sh vrachieru --connection http --limit 1 # 1st repo (sorted alphabetically) via http

domain='' # optional, for private hosted instances
token='' # optional, get one at: settings > access tokens

type='user' # user or org
connection='ssh' # http or ssh
limit=100

eval set -- `getopt -o dtcl: --long domain:,token:,type:,connection:,limit: -- "$@"`

while true; do
  case "${1}" in
    --domain) domain="${2}"; shift 2 ;;
    --token) token="${2}"; shift 2 ;;
    --type) type="${2}"; shift 2 ;;
    --connection) connection="${2}"; shift 2 ;;
    --limit) limit="${2}"; shift 2 ;;
    --) shift; break ;;
    *) break ;;
  esac
done

id="${1}"
url="https://gitlab.com/api/v4/${type}s/${id}/projects?per_page=${limit}"

if ! [ -z "${domain}" ]; then
    url="${url/gitlab.com/$domain}"
fi
if ! [ -z "${token}" ]; then
    url="${url}&private_token=${token}"
fi

repos=`curl -s "${url}"`
repo_urls=(`echo "${repos}" | jq -r ".[].${connection}_url_to_repo"`)

mkdir -p "${id}"
cd "${id}"

echo "Found ${#repo_urls[@]} projects"
for repo_url in "${repo_urls[@]}"; do
    git clone "${repo_url}"
done
