# FritzPCAP-docker
[![docker-hub Actions Status](https://github.com/dachack/fritzpcap-docker/workflows/docker-hub/badge.svg)](https://github.com/dachack/fritzpcap-docker/actions)

Self-hosted home network traffic monitoring with ntopng and a Fritz!Box

Thanks to Davide Quaranta for coming up with the idea and basically preparing all scripts ready to use.
I only provided the docker container.

## Image on Docker Hub
https://hub.docker.com/r/dachack/fritzpcap

## Sources in Github
https://github.com/DaCHack/fritzpcap-docker

## Docker-compose
Either use the container standalone or together with ntopng as in the example below:
```
services:
  ntopng:
    container_name: ntopng
    image: ntop/ntopng
    volumes:
      - /opt/appdata/ntopng/data:/var/lib/ntopng
      - /opt/appdata/ntopng/pcap:/pcap
      - /opt/appdata/ntopng/ntopng.conf:/ntopng.conf:ro
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    environment:
      - TZ=Europe/Berlin
    command:
      - "/ntopng.conf"
    ports:
      - 3000
    restart: unless-stopped

  fritzpcap:
    build: ./fritzpcap
    environment:
      - FRITZIP=http://fritz.box
      - FRITZUSER={{ fritz.username }}
      - FRITZPWD={{ fritz.password }}
    volumes:
      - /opt/appdata/ntopng/pcap:/pcap
    restart: unless-stopped
```
