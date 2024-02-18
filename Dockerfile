FROM ghcr.io/praetorian-inc/noseyparker:v0.16.0

apt update && apt install -y jq

COPY /entrypoints/scanuser_entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]