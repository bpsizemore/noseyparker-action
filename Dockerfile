FROM ghcr.io/praetorian-inc/noseyparker:v0.16.0

RUN apt update && apt install -y jq

COPY /entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]