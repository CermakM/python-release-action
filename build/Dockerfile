FROM registry.access.redhat.com/ubi8/python-36

LABEL "com.github.actions.name"="Python Release"
LABEL "com.github.actions.description"="Action to take care of releasing and publishing."
LABEL "com.github.actions.icon"="user-check"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="http://github.com/cermakm/python-release-action"
LABEL "homepage"="http://github.com/cermakm/python-release-action"
LABEL "maintainer"="Marek Cermak <macermak@redhat.com>"

ARG GITHUB_REVISION=master
ENV USER=release-bot

COPY . /
COPY entrypoint.sh /entrypoint.sh

RUN pip install \
    "git+https://github.com/user-cont/release-bot@${GITHUB_REVISION}" \
    jinja2 \
    jinja2-cli

USER root
ENTRYPOINT [ "/entrypoint.sh" ]
