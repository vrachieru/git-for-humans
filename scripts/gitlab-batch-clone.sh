#!/bin/bash

# dependency: https://stedolan.github.io/jq/
# usage: ./gitlab-batch-clone.sh vrachieru # all repos via ssh for user
#        ./gitlab-batch-clone.sh vrachieru --token abc123 # all repos via ssh for user with authentication
#        ./gitlab-batch-clone.sh vrachieru --connection http --limit 1 # 1st repo (sorted alphabetically) via http

auth='' # optional, for example for private token authentication
domain='' # optional, for private hosted instances
token='' # optional, get one at: settings > access tokens

type='user' # user or group
connection='ssh' # http or ssh
limit=100

eval set -- `getopt -o adtcl: --long auth:,domain:,token:,type:,connection:,limit: -- "$@"`

while true; do
  case "${1}" in
    --auth) auth="${2}"; shift 2 ;;
    --domain) domain="${2}"; shift 2 ;;
    --token) token="${2}"; shift 2 ;;
    --type) type="${2}"; shift 2 ;;
    --connection) connection="${2}"; shift 2 ;;
    --limit) limit="${2}"; shift 2 ;;
    --) shift; break ;;
    *) break ;;
  esac
done

for id in "${@}"; do
    echo -e "\nFetching repositories for ${id}..."

    url="https://gitlab.com/api/v4/${type}s/${id////%2F}/projects?per_page=${limit}"

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

    echo -e "Found ${#repo_urls[@]} repositories"
    for repo_url in "${repo_urls[@]}"; do
        if [ "${connection}" == "http" ] && ! [ -z "${auth}" ]; then
            repo_url="${repo_url/https:\/\//https:\/\/${auth}@}"
        fi

        git clone "${repo_url}"
    done

    cd ..
done