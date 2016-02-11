#!/bin/bash

repos=('repo1' 'repo2')

function displayRepository() {
  cd "$1"
  echo -e "\n[$1]"
  getBranches
  displayBranches
  cd - &>/dev/null
}

function getBranches() {
  git pull --all &>/dev/null
  git checkout master &>/dev/null
  branches=($(git branch -r | grep -v master))
  mergedBranches=($(git branch -r --merged master | grep -v master))
}

function isMerged() {
  local branch
  for branch in "${mergedBranches[@]}"; do
    [[ "$branch" == "$1" ]] && return 0;
  done
  return 1
}

function displayBranches() {
  local branch
  for branch in "${branches[@]}"; do
	displayBranch "$branch"
  done
}

function displayBranch() {
  displayBranchName "$1"
  displayMergeStatus "$1"
  displayLastCommit "$1"
}

function displayBranchName() {
  echo -e "\n = $1 ="
}

function displayMergeStatus() {
  local status; isMerged "$1" && status="true" || status="false"
  echo " Merged: ${status}"
}

function displayLastCommit() {
  git log -1 --pretty=format:" Author: %an%n   Date: %aD (%ar)%nMessage: %s" "$1"
}

function deleteBranch() {
# git branch -r --merged | grep -v master | sed 's/origin\///' | xargs -n 1 git push --delete origin
  git branch -d $1
  git push delete origin $1
}

function main() {
  local repo
  for repo in "${repos[@]}"; do
    displayRepository "$repo"
  done
}

main
