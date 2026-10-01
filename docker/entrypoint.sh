#!/bin/bash
set -e

ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow from 172.28.0.0/24 to any port 22 proto tcp

if [ "$ROLE" = "proxy" ]; then
  ufw allow 80/tcp
  ufw allow 443/tcp
fi

ufw --force enable || true

service ssh start
nginx -g "daemon off;" &
wait
