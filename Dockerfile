FROM alpine:3.17

RUN apk add wget curl perl bash && \
    mkdir /pcap
RUN apk remove gnu-libiconv && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ gnu-libiconv=1.15-r2
COPY pcap2.sh /pcap2.sh

ENTRYPOINT ["bash", "/pcap2.sh"]
