#!/bin/bash
# Google sign-in gate for flight-review.modalai.com. Caddy (ops/Caddyfile) asks this
# container whether a request carries a valid session before serving anything
# other than uploads. Only modalai.com accounts are accepted.
#
# Secrets are NOT in the repo. The VM has /etc/flight-review/oauth2-proxy.env with:
#   OAUTH2_PROXY_CLIENT_ID=...apps.googleusercontent.com
#   OAUTH2_PROXY_CLIENT_SECRET=...
#   OAUTH2_PROXY_COOKIE_SECRET=<32 random bytes, base64: python3 -c 'import os,base64;print(base64.urlsafe_b64encode(os.urandom(32)).decode())'>
# The OAuth client lives in the modalai-flight-review GCP project with redirect URI
# https://flight-review.modalai.com/oauth2/callback and an Internal consent screen.

set -e
ENV_FILE=/etc/flight-review/oauth2-proxy.env
DOMAIN=flight-review.modalai.com

sudo docker rm -f flight-review-auth 2>/dev/null || true

sudo docker run -d \
	--name=flight-review-auth \
	--restart=always \
	--network=host \
	--env-file $ENV_FILE \
	quay.io/oauth2-proxy/oauth2-proxy:v7.15.4 \
	--provider=google \
	--email-domain=modalai.com \
	--http-address=127.0.0.1:4180 \
	--reverse-proxy=true \
	--trusted-proxy-ip=127.0.0.1/32 \
	--redirect-url=https://$DOMAIN/oauth2/callback \
	--whitelist-domain=$DOMAIN \
	--cookie-secure=true \
	--cookie-samesite=lax \
	--cookie-expire=168h \
	--skip-provider-button=true \
	--set-xauthrequest=true \
	--upstream=static://202
