FROM ghcr.io/praetorian-inc/noseyparker:v0.16.0

RUN apt update && apt install -y jq

COPY /entrypoints/scanrepo_entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]