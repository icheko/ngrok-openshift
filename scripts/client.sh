#!/usr/bin/bash

echo "Starting client"

CONFIG_SUBDOMAIN=""
if [ "${NGROK_SUBDOMAIN}" != "" ]; then
  CONFIG_SUBDOMAIN="-subdomain ${NGROK_SUBDOMAIN}"
fi

if [ "${NGROK_HOSTNAME}" != "" ]; then
  NGROK_HOSTNAME="-hostname=${NGROK_HOSTNAME}"
fi

if [ -z ${NGROK_PROXY_TO} ]; then
  echo "You need to provide destination host for tunneling in NGROK_PROXY_TO"
  exit 1
fi

CONFIG=""
if [ -z ${NGROK_USE_DEFAULT} ] || [ ${NGROK_USE_DEFAULT} == "false" ]; then
  CONFIG="-config ngrok-config.yaml"
fi

exec ngrok ${CONFIG} ${CONFIG_SUBDOMAIN} ${NGROK_HOSTNAME} ${NGROK_PROXY_TO}