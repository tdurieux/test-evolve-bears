#!/usr/bin/env bash

setUp()
{
    docker pull $DOCKER_TAG_BEARS
}

testWithBranchFailingPassingOk()
{
    EXPECTED_RESULT="$BRANCH_NAME [OK]"


    DOCKER_COMMAND="docker run -v ${pwd}:/var/app/pr $DOCKER_TAG_BEARS"
    DOCKER_ID=`$DOCKER_COMMAND`

    echo "The container is launching with the following command: $DOCKER_COMMAND and the following container id: $DOCKER_ID"
    echo docker logs -f $DOCKER_ID

    echo "$RESULT" | grep -qF "$EXPECTED_RESULT"
    RETURN_CODE=$?

    assertEquals "The expected result is [OK]" 0 $RETURN_CODE
}

. shunit2