#!/bin/bash

scriptPath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

if [ -n "$REPO_LIST_URL" ]; then
    echo "Retrieving the list of repositories"
    curl $REPO_LIST_URL | jq -r '.[] | .label + " https://github.com/" + .full_name + ".git"' > flat_list.txt
elif [ -n "$REPO_LIST_PATH" ]; then
    echo "Reading list of repositories"
    jq -r '.[] | .label + " https://github.com/" + .full_name + ".git"' $REPO_LIST_PATH > flat_list.txt
else
    echo -e "Need to set either REPO_LIST_URL or REPO_LIST_PATH"
    exit 1
fi

resultsPath="$scriptPath/results"
mkdir -p $resultsPath

while read line
do
    label=$(echo $line | cut -f1 -d' ')
    url=$(echo $line | cut -f2 -d' ')
    echo "Creating statistics for repository $label at URL: $url"

    if [[ "$label" == *\/* ]]; then
      echo -e "ERROR: Repository label [$label] contains invalid character /"
      exit 1
    fi

    repoPath="/tmp/$label"
    outputPath="$resultsPath/$label.json"
    git clone $url $repoPath
    pushd $repoPath &>/dev/null
    git log --all --no-merges --pretty=format:'"%H": {"email": "%ae", "date": "%aI", "name": "%an"},' | sed '1s/^/{/' | sed '$s/,$/}/' > $repoPath/git_log.json
    git log --all --no-merges --shortstat --format='%H' | ${scriptPath}/stream.py | sed '1s/^/{/' | sed '$s/,$/}/' > $repoPath/git_stat.json
    jq -s '.[0] * .[1] | map(select(has("files"))) | map(select(.email | contains("@roames.com")))' $repoPath/git_log.json $repoPath/git_stat.json > $outputPath
    popd &>/dev/null
done <flat_list.txt

if [ -n "$RESULTS_S3_PATH" ]; then
  : ${AWS_ACCESS_KEY_ID:?"Need to set AWS_ACCESS_KEY_ID"}
  : ${AWS_SECRET_ACCESS_KEY:?"Need to set AWS_SECRET_ACCESS_KEY"}
  echo "Uploading results to S3 path $RESULTS_S3_PATH"
  aws s3 cp $resultsPath/ $RESULTS_S3_PATH --recursive --acl public-read
elif [ -n "$RESULTS_LOCAL_PATH" ]; then
  echo "Copy results to $RESULTS_LOCAL_PATH"
  cp $resultsPath/* $RESULTS_LOCAL_PATH
fi
