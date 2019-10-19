#!/bin/bash

set -euo pipefail

[ ! -z "${PYPI}" ] && PYPI_RELEASE=true \
                   || PYPI_RELEASE=false

_prep() {
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
}

main() {
    : "${GITHUB_TOKEN?Must set GITHUB_TOKEN env var}"
    >&2 echo -e "\n--- Environment:\n" ; env

    _prep || exit 1

    # Run Release Bot
    >&2 echo -e "\n--- Running Release Bot ...\n"
    GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no' release-bot --debug -c conf.yaml
}

main "$@"
