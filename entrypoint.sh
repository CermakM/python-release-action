#!/bin/bash
set -euo pipefail


[ ! -z "${PYPI}" ] && export PYPI_RELEASE=true \
                   || export PYPI_RELEASE=false


_prep() {
    >&2 echo -e "\n--- Found myself running in ${PWD} ...\n"
    >&2 echo -e "\n--- Setting git config ...\n" ; ls -calh

    cd ${REPO_PATH}

    git config user.name  "$(git --no-pager log --format=format:'%an' -n 1)"
    git config user.email "$(git --no-pager log --format=format:'%ae' -n 1)"

    git clone https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git . 

    >&2 echo -e "\n--- Processing templates ...\n"

    local templates=$(find ${RELEASE_TEMPLATES} -type f ! -name '*.tpl' -exec basename {} \;)

    for fname in ${templates}; do
    {
        >&2 echo -e "\tTemplate: ${fname}"

        if [ -f "${fname}" ] ; then
            >&2 echo -e "\t\tFile '${fname}' already exists. Skipping."
        else
            jinja2 ${RELEASE_TEMPLATES}/${fname} -o ${fname} \
                -D CHANGELOG=${CHANGELOG} \
                -D PYPI=${PYPI} \
                -D PYPI_RELEASE=${PYPI_RELEASE} || exit 1
            >&2 echo -e "\t\tDone."
        fi
    }
    done

    >&2 echo -e "\n--- Local directory content ...\n" ; ls -calh
}

main() {
    : "${GITHUB_ACTOR?Must set GITHUB_ACTOR env var}"
    : "${GITHUB_TOKEN?Must set GITHUB_TOKEN env var}"
    : "${GITHUB_WORKSPACE?Must set GITHUB_WORKSPACE env var}"

    export REPO_PATH=${PWD};

    >&2 echo -e "\n--- Environment:\n" ; env
    _prep || exit 1

    # Run Release Bot
    >&2 echo -e "\n--- Running Release Bot ...\n"
    GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no' release-bot --debug -c conf.yaml
}

main "$@"
