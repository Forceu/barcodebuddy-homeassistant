# BarcodeBuddy on Docker

BarcodeBuddy- now containerized! This is the docker repo of [BarcodeBuddy](https://github.com/Forceu/barcodebuddy).

[![Docker Pulls](https://img.shields.io/docker/pulls/f0rc3/barcodebuddy-docker.svg)](https://hub.docker.com/r/f0rc3/barcodebuddy-docker/)
[![Docker Stars](https://img.shields.io/docker/stars/f0rc3/barcodebuddy-docker.svg)](https://hub.docker.com/r/f0rc3/barcodebuddy-docker/)

## Install Docker

Follow [these instructions](https://docs.docker.com/engine/installation/) to get Docker running on your server.

## Available on Docker Hub (prebuilt) or built from source

### To pull the latest images to your machine:

```
docker pull f0rc3/barcodebuddy-docker:latest
docker run -d -v bbconfig:/config -p 80:80 -p 443:443 f0rc3/barcodebuddy-docker:latest
```

BarcodeBuddy should be accessible via `http(s)://DOCKER_HOST_IP/`. The https option will work. However, since the certificate is self-signed, most browsers will complain.

The volume "bbconfig" is used, in order to store the database between instances/images.

If you are already running a webserver on the docker hosts, you need to set ports 80 and 443 to different values in the run command, eg:

```
docker run -d -v bbconfig:/config -p 8080:80 -p 9443:443 f0rc3/barcodebuddy-docker:latest
```


### To build from scratch

```
docker build --no-cache --pull -t forceu/barcodebuddy-docker .
```

## Additional Information

### Websockets

In the current version, the websockets are only used for internal communication. Everything will work out of the box.

### Exposed Ports

 - 80:    HTTP
 - 443:   HTTPS

### Misc

The docker images build are based on [Alpine](https://hub.docker.com/_/alpine/), with an extremely low footprint (about 70MB in total).

## License
The MIT License (MIT)

Based on: https://github.com/linuxserver/docker-grocy
