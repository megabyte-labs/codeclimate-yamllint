FROM alpine:3 AS codeclimate-yamllint

WORKDIR /work

COPY local/codeclimate-yamllint /usr/local/bin/codeclimate-yamllint
COPY local/engine.json ./engine.json
COPY test ./

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN adduser --uid 9000 --gecos "" --disabled-password app \
  && apk --no-cache add --virtual build-deps \
      jq~=1 \
      py3-pip~=20 \
  && apk --no-cache add \
      gawk~=5 \
      python3~=3 \
  && pip3 install --no-cache-dir \
      "yamllint==1.*" \
  && VERSION="$(yamllint --version | sed 's/.*\s//')" \
  && jq --arg version "$VERSION" '.version = $version' > /engine.json < ./engine.json \
  && apk del build-deps \
  && find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
  && find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf \
  && chown -R app:app ./

USER app

VOLUME ["/code"]
WORKDIR /code

CMD ["codeclimate-yamllint", "/code"]

ARG BUILD_DATE
ARG REVISION
ARG VERSION

LABEL maintainer="Megabyte Labs <help@megabyte.space>"
LABEL org.opencontainers.image.authors="Brian Zalewski <brian@megabyte.space>"
LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.description="Code climate engine for Yaml Lint"
LABEL org.opencontainers.image.documentation="https://gitlab.com/megabyte-labs/dockerfile/codeclimate/yamllint/-/blob/master/README.md"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.revision=$REVISION
LABEL org.opencontainers.image.source="https://gitlab.com/megabyte-labs/dockerfile/codeclimate/yamllint.git"
LABEL org.opencontainers.image.url="https://megabyte.space"
LABEL org.opencontainers.image.vendor="Megabyte Labs"
LABEL org.opencontainers.image.version=$VERSION
LABEL space.megabyte.type="code-climate"

FROM codeclimate-yamllint AS yamllint

WORKDIR /work

USER root

RUN rm /engine.json \
  && rm -rf * \
  && rm /usr/local/bin/codeclimate-yamllint

USER app

ENTRYPOINT ["yamllint"]
CMD ["--version"]

LABEL space.megabyte.type="code-climate-standalone"
