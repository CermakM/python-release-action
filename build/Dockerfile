FROM registry.access.redhat.com/ubi8/python-36

LABEL "com.github.actions.name"="Python Release"
LABEL "com.github.actions.description"="Action to take care of releasing and publishing."
LABEL "com.github.actions.icon"="user-check"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="http://github.com/cermakm/python-release-action"
LABEL "homepage"="http://github.com/cermakm/python-release-action"
LABEL "maintainer"="Marek Cermak <macermak@redhat.com>"

USER root

ARG GITHUB_REVISION=master
ENV USER=release-bot \
    RELEASE_TEMPLATES=/opt/app-root/data

COPY LICENSE README.md /
COPY templates ${RELEASE_TEMPLATES}

COPY entrypoint.sh /usr/bin/release

RUN pip install --upgrade pip setuptools && pip install \
    "git+https://github.com/cermakm/release-bot@${GITHUB_REVISION}" \
    jinja2 \
    jinja2-cli

ENTRYPOINT [ "release" ]
