#!/usr/bin/bash

echo "Starting NGROK server using domain ${NGROK_DOMAIN}"

if [ -z ${NGROK_DOMAIN} ]; then
  echo "You need to provide domain in NGROK_DOMAIN"
  exit 1
fi

exec ngrokd -tlsKey=device.key -tlsCrt=device.crt -domain="${NGROK_DOMAIN}" -httpAddr=":8080" -httpsAddr=":8443" -tunnelAddr=":4443"