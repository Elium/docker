#!/bin/bash
set -xe

echo "Start building and deploying JENKINS"

if [ -z $DEPLOY_JENKINS_VERSION ]; then
  echo "[Error] \$DEPLOY_JENKINS_VERSION must be set"
  exit 1
fi

tempFolder=".tmp-deploy"
jenkinsDownloadPath="$tempFolder/jenkins-war-$DEPLOY_JENKINS_VERSION.war"
jenkinsUrlWar="http://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/$DEPLOY_JENKINS_VERSION/jenkins-war-$DEPLOY_JENKINS_VERSION.war"

mkdir -p "$tempFolder"
curl "$jenkinsUrlWar" -o "$jenkinsDownloadPath"
sha256=$(echo $(shasum -a 256 "$jenkinsDownloadPath") | awk '{print $1}')

echo "$sha256"

sed -i '.backup' \
  -e 's/JENKINS_VERSION:-[0-9.]*/JENKINS_VERSION:-'"$DEPLOY_JENKINS_VERSION"'/' \
  -e 's/JENKINS_SHA:-[0-9a-f]*/JENKINS_SHA:-'"$sha256"'/' \
  ./Dockerfile

rm -Rf "$tempFolder"

git add Dockerfile
git commit -m "Bump Jenkins to $DEPLOY_JENKINS_VERSION"
git tag "$DEPLOY_JENKINS_VERSION"
git push --set-upstream origin alpine-elium
git push --tags