#!/bin/bash -l

set -euo pipefail

[ ! -z "${PYPI}" ] && export PYPI_RELEASE=true || PYPI_RELEASE=false

_prep() {
    >&2 echo -e "\nProcessing Jinja2 templates ...\n"

    find ${RELEASE_TEMPLATES} -type f ! -name '*.tpl' | while read fpath; do
    {
        local fname="$(basename ${fpath})"

        >&2 echo -e "\tTemplate: ${fname}"
        if test -f "${fname}"; then
            >&2 echo -e "\t\tFile '${fname}' already exists. Skipping."
        else
            jinja2 ${RELEASE_TEMPLATES}/${fname} -o "${fname}" || exit 1
            >&2 echo -e "\t\tDone."
        fi
    }
    done
}

main() {
    : "${GITHUB_TOKEN?Must set PYPI env var}"
    _prep || exit 1

    # Run Release Bot
    >&2 echo -e "\nRunning Release Bot ...\n"
    GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no' release-bot --debug -c conf.yaml
}

main "$@"
