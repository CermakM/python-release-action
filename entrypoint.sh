#!/bin/bash
set -euo pipefail


[ ! -z "${PYPI}" ] && PYPI_RELEASE=true \
                   || PYPI_RELEASE=false


_prep() {
    >&2 echo -e "\n--- Found myself running in ${PWD} ...\n"
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

    >&2 echo -e "\n--- Setting git config ...\n" ; ls -calh

    wget -O /usr/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 &>/dev/null
    chmod +x /usr/bin/jq

    git config --global user.name "${GITHUB_ACTOR}"
    git config --global user.email $(
        curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/users/${GITHUB_ACTOR} |\
        jq -r '.email'
    )

    >&2 echo -e "\n--- Local directory content ...\n" ; ls -calh
}

main() {
    : "${GITHUB_ACTOR?Must set GITHUB_ACTOR env var}"
    : "${GITHUB_TOKEN?Must set GITHUB_TOKEN env var}"
    : "${GITHUB_WORKSPACE?Must set GITHUB_WORKSPACE env var}"

    export REPO_PATH=${GITHUB_WORKSPACE}; cd ${REPO_PATH}

    >&2 echo -e "\n--- Environment:\n" ; env
    _prep || exit 1

    # Run Release Bot
    >&2 echo -e "\n--- Running Release Bot ...\n"
    GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no' release-bot --debug -c conf.yaml
}

main "$@"
