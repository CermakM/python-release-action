#!/bin/bash -l

set -euo pipefail

[ ! -z ${PYPI} ] && export PYPI_RELEASE=true

_prep() {
    >&2 echo -E "\nProcessing Jinja2 templates ...\n"

    find templates/ -type f | while read fname; do
    {
        >&2 echo -E "\tTemplate: ${fname}"
        jinja2 templates/${fname} -o ${fname}
    }
    done
}

main() {
    _prep || exit 1

    local config=$1

    # Run Kebechet
    >&2 echo -E "\nRunning Release Bot ...\n"
    GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no' release-bot -c $config
}

main "$@"