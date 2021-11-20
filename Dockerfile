# syntax=docker/dockerfile:1.3-labs
FROM centos:7 as builder

ARG TLS_ROOT_DOMAIN
ARG TLS_SAN_DOMAIN

ENV GOROOT /usr/lib/golang
ENV GOPATH /opt/golang

# Install EPEL
RUN curl https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 -O && rpm --import RPM-GPG-KEY-EPEL-7
RUN curl https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -O && rpm --checksig -v epel-release-latest-7.noarch.rpm
RUN yum install -y epel-release-latest-7.noarch.rpm

RUN yum -y install golang git make openssl
RUN echo $GOPATH $GOROOT

WORKDIR /opt/golang

COPY tls/*.cnf .

RUN openssl genrsa -out rootCA.key 2048
RUN openssl req -new -x509 -nodes -key rootCA.key -days 5000 -out rootCA.pem -config root.cnf -extensions v3_ca
RUN openssl x509 -text -noout -in rootCA.pem

RUN openssl genrsa -out device.key 2048
RUN openssl req -new -key device.key -out device.csr -config san.cnf -extensions v3_req
RUN openssl req -text -noout -in device.csr
RUN openssl x509 -req -in device.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out device.crt -days 2500 -extfile san.cnf -extensions v3_req
RUN openssl x509 -text -noout -in device.crt

RUN git clone https://github.com/inconshreveable/ngrok && \
  cp rootCA.pem ngrok/assets/client/tls/ngrokroot.crt && \
  cd ngrok && make release-server release-client


FROM centos:7

ARG NGROK_PROXY_URL

# ENV GODEBUG="x509ignoreCN=0"
WORKDIR /opt/ngrok
ENTRYPOINT ["./scripts/entrypoint.sh"]

COPY --from=builder /opt/golang/ngrok/bin/ngrok*  /usr/local/bin/
COPY --from=builder /opt/golang/ngrok/assets      /opt/golang/ngrok/assets
COPY --from=builder /opt/golang/device.*          /opt/ngrok/

COPY ngrok-config.yaml .
RUN sed -i "s/server_addr:.*/server_addr: ${NGROK_PROXY_URL}/g" ngrok-config.yaml
COPY scripts/* /opt/ngrok/scripts/
RUN chmod +x /opt/ngrok/scripts/*.sh