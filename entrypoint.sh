#!/bin/bash -l

set -euo pipefail

[ ! -z "${PYPI}" ] && export PYPI_RELEASE=true

_prep() {
    >&2 echo -E "\nProcessing Jinja2 templates ...\n"

    find ${RELEASE_CONFIG_DIRECTORY}/templates/ -type f | while read fname; do
    {
        >&2 echo -E "\tTemplate: ${fname}"
        if test -f "${fname}"; then
            >&2 echo -E "\t\tFile '${fname}' already exists. Skipping."
        else
            jinja2 ${RELEASE_CONFIG_DIRECTORY}/templates/${fname} -o "${fname}"
            >&2 echo -E "\t\tDone."
        fi
    }
    done

    # copy rest of the configuration files
    find ${RELEASE_CONFIG_DIRECTORY} -type f -exec cp -n {} . \;
}

main() {
    : "${GITHUB_TOKEN?Must set PYPI env var}"
    _prep || exit 1

    # Run Kebechet
    >&2 echo -E "\nRunning Release Bot ...\n"
    GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no' release-bot --debug -c conf.yaml
}

main "$@"
