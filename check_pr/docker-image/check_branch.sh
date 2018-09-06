#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "Usage: ./check_branches.sh <branch name>"
    exit 2
fi

function checkCommit {
    echo "$1"
    if grep -q "$2" "$1"; then
        echo "The commit is OK."
    else
        RESULT="$BRANCH_NAME [FAILURE] (the commits are not in the correct sequence or some commit is missing)"
        >&2 echo -e "$RED $RESULT $NC"
        exit 1
    fi
}

BRANCH_NAME=$1

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

command -v ajv >/dev/null 2>&1 || { echo >&2 "I require ajv (https://github.com/jessedc/ajv-cli) but it's not installed.  Aborting."; exit 1; }

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
JSON_SCHEMA="$SCRIPT_DIR/bears-schema.json"
if [ ! -f $JSON_SCHEMA ]; then
    echo "The json schema ($JSON_SCHEMA) cannot be found."
    exit 2
else
    echo "JSON schema path: $JSON_SCHEMA"
fi

MAVEN_TEST_ARGS="-Denforcer.skip=true -Dcheckstyle.skip=true -Dcobertura.skip=true -DskipITs=true -Drat.skip=true -Dlicense.skip=true -Dfindbugs.skip=true -Dgpg.skip=true -Dskip.npm=true -Dskip.gulp=true -Dskip.bower=true"

echo "Treating branch $BRANCH_NAME"

echo "---CHECKING ORDER---\n"
echo "Existence of bears.json"
echo "Validity of bears.json"
echo "Number of commits"
echo "Maven test on buggy commit"
echo "Maven test on patched commit"

cd pr

if [ -e "bears.json" ]; then
    if ajv test -s $JSON_SCHEMA -d bears.json --valid ; then
        echo "bears.json is valid in $BRANCH_NAME"
    else
        RESULT="$BRANCH_NAME [FAILURE] (bears.json is invalid)"
        >&2 echo -e "$RED $RESULT $NC"
        exit 1
    fi
else
    RESULT="$BRANCH_NAME [FAILURE] (bears.json does not exist)"
    >&2 echo -e "$RED $RESULT $NC"
    exit 1
fi

numberOfCommits=`git rev-list --count HEAD`
if [ "$numberOfCommits" -lt 4 ] ; then
    RESULT="$BRANCH_NAME [FAILURE] (the number of commits is less than 4)"
    >&2 echo -e "$RED $RESULT $NC"
    exit 1
fi

bugCommitId=""

case=$(cat bears.json | sed 's/.*"type": "\(.*\)".*/\1/;t;d')
echo "Branch from case $case"
if [ "$case" == "failing_passing" ]; then
    echo "3 commits must exist."

    echo "Checking commits..."

    firstCommitMessage=`git log --format=format:%B --skip 2 -n 1`
    checkCommit "$firstCommitMessage" "Bug commit"

    secondCommitMessage=`git log --format=format:%B --skip 1 -n 1`
    checkCommit "$secondCommitMessage" "Human patch"

    thirdCommitMessage=`git log --format=format:%B -n 1`
    checkCommit "$thirdCommitMessage" "End of the bug and patch reproduction process"

    bugCommitId=`git log --format=format:%H --grep="Bug commit"`
else
    echo "4 commits must exist."

    echo "Checking commits..."

    firstCommitMessage=`git log --format=format:%B --skip 3 -n 1`
    checkCommit "$firstCommitMessage" "Bug commit"

    secondCommitMessage=`git log --format=format:%B --skip 2 -n 1`
    checkCommit "$secondCommitMessage" "Changes in the tests"

    thirdCommitMessage=`git log --format=format:%B --skip 1 -n 1`
    checkCommit "$thirdCommitMessage" "Human patch"

    fourthCommitMessage=`git log --format=format:%B -n 1`
    checkCommit "$fourthCommitMessage" "End of the bug and patch reproduction process"

    bugCommitId=`git log --format=format:%H --grep="Changes in the tests"`
fi

patchCommitId=`git log --format=format:%H --grep="Human patch"`

echo "Checking out the bug commit: $bugCommitId"
git log --format=%B -n 1 $bugCommitId

git checkout -q $bugCommitId

timeout 1800s mvn -q -B test -Dsurefire.printSummary=false $MAVEN_TEST_ARGS

status=$?
if [ "$status" -eq 0 ]; then
    RESULT="$BRANCH_NAME [FAILURE] (bug reproduction - status = $status)"
    >&2 echo -e "$RED $RESULT $NC"
    exit 1
elif [ "$status" -eq 124 ]; then
    RESULT="$BRANCH_NAME [FAILURE] (bug reproduction timeout)"
    >&2 echo -e "$RED $RESULT $NC"
    exit 1
fi

echo "Checking out the patch commit: $patchCommitId"
git log --format=%B -n 1 $patchCommitId

git checkout -q $patchCommitId

timeout 1800s mvn -q -B test -Dsurefire.printSummary=false $MAVEN_TEST_ARGS

status=$?
if [ "$status" -eq 0 ]; then
    RESULT="$BRANCH_NAME [FAILURE] (patch reproduction - status = $status)"
    >&2 echo -e "$RED $RESULT $NC"
    exit 1
elif [ "$status" -eq 124 ]; then
    RESULT="$BRANCH_NAME [FAILURE] (patch reproduction timeout)"
    >&2 echo -e "$RED $RESULT $NC"
    exit 1
fi

RESULT="$BRANCH_NAME [OK]"
echo -e "$GREEN $RESULT $NC"