# syntax=docker/dockerfile:1-labs

FROM fedora:42

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TZ=Hongkong

COPY ./customize.bash /tmp/customize.bash
RUN --security=insecure \
    --mount=type=secret,id=gdfuse_service_account_data \
    bash /tmp/customize.bash

CMD ["/usr/bin/zsh", "--login"]
WORKDIR /root
