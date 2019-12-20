#!/bin/bash -e
shopt -s dotglob
shopt -s nullglob

rm -rf DCAT-AP
if [ ! -d DCAT-AP-original ]; then
	git clone https://github.com/SEMICeu/DCAT-AP.git DCAT-AP-original
fi
git clone DCAT-AP-original DCAT-AP
cd DCAT-AP

# Delete all branches and tags
#  (everything is merged in master anyway)
git checkout master
git branch | grep -v '^*' | xargs git branch -d || true
git tag --list | xargs git tag -d || true

# Turn the release folders into branches
releases=(releases/*)
for release in "${releases[@]}"
do
  releaseNr="${release#*/}"
  echo $releaseNr
  git checkout master
  git checkout -b "$releaseNr"
  git filter-branch --subdirectory-filter "$release/" --
  git update-ref -d "refs/original/refs/heads/$releaseNr"
done

# Only keep the README in master
git checkout master
git filter-branch --tree-filter "rm -rf releases" --prune-empty HEAD
