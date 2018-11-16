#!/bin/bash

RETRY=true
JOB_NUM=$CIRCLE_PREVIOUS_BUILD_NUM

while [[ $(echo $RETRY) == true ]]
do
  JOB_OUTPUT=\
    $(curl --user $CIRCLE_TOKEN: \
    https://circleci.com/api/v1.1/project/github/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/$JOB_NUM)

  if [[ $(echo $JOB_OUTPUT | \
    grep '"retry_of" : null') && $(echo $JOB_OUTPUT | \
    grep -v '"workflow_id" : "${CIRCLE_WORKFLOW_ID}"')]]; then

    RETRY=false
  else
    echo "$JOB_NUM was a retry of a previous job, or part of the current workflow"
    JOB_NUM=$(( $JOB_NUM - 1 ))
  fi
done

LAST_PUSHED_COMMIT=$(curl --user $CIRCLE_TOKEN: \
  https://circleci.com/api/v1.1/project/github/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/$JOB_NUM | \
  grep '"commit" : ' | sed -E 's/"commit" ://' | sed -E 's/[[:punct:]]//g' | sed -E 's/ //g')

CIRCLE_COMPARE_URL=\
  "https://github.com/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/compare/${LAST_PUSHED_COMMIT:0:12}...${CIRCLE_SHA1:0:12}"

echo "last pushed commit hash is:" $LAST_PUSHED_COMMIT

echo "- - - - - - - - - - - - - - - - - - - - - - - -"

echo "this job's commit hash is:" $CIRCLE_SHA1

echo "- - - - - - - - - - - - - - - - - - - - - - - -"

echo "recreated CIRCLE_COMPARE_URL:" $CIRCLE_COMPARE_URL

echo "- - - - - - - - - - - - - - - - - - - - - - - -"

echo "outputting CIRCLE_COMPARE_URL to a file in your working directory, called CIRCLE_COMPARE_URL"

echo $CIRCLE_COMPARE_URL > CIRCLE_COMPARE_URL