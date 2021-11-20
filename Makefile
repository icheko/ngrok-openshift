tls_root_domain = openshiftapps.com
openshift_cluster = apps.sandbox.x8i5.p1.openshiftapps.com
tls_san_domain_wildcard = *.$(openshift_cluster)
ngrok_proxy_url = ngrok-openshift-proxy.$(openshift_cluster):443
local_server = host.docker.internal:3000

docker_image = ngrok-openshift

build:
	docker buildx build --build-arg TLS_ROOT_DOMAIN="$(tls_root_domain)" --build-arg TLS_SAN_DOMAIN="$(tls_san_domain_wildcard)" --build-arg NGROK_PROXY_URL="$(ngrok_proxy_url)" --progress plain -t $(docker_image) -f Dockerfile .

shell:
	docker run --rm -it --entrypoint=sh $(docker_image)

run-client:
	docker run --rm -it -p 8080:8080 -e NGROK_RUN_AS=client -e NGROK_HOSTNAME=ngrok-openshift.$(openshift_cluster) -e NGROK_SUBDOMAIN=ngrok-openshift -e NGROK_PROXY_TO=$(local_server) $(docker_image)

run-server:
	docker run --rm -it -p 8080:8080 -p 8443:8443 -e NGROK_RUN_AS=server -e NGROK_DOMAIN=$(openshift_cluster) $(docker_image)

publish-openshift:
	docker tag $(docker_image) default-route-openshift-image-registry.$(openshift_cluster)/icheko-dev/ngrok-openshift:latest
	docker push default-route-openshift-image-registry.$(openshift_cluster)/icheko-dev/ngrok-openshift:latest