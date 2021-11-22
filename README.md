# ngrok-openshift

Deploy a private ngrok service on [Openshift Developer Sandbox (free to use)](https://developers.redhat.com/developer-sandbox/get-started) using self-signed certificates. This builds both the server and client components suitable only for this deployment. The public ngrok client will not work since the client performs a TLS check before establishing a connection.

## Production use

[inconshreveable/ngrok](https://github.com/inconshreveable/ngrok) is v1 of ngrok.com and is not suitable for production use. See [inconshreveable/ngrok](https://github.com/inconshreveable/ngrok) for more information.
