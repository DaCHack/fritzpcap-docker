FROM alpine:3.17

RUN apk add wget curl perl bash gnu-libiconv=1.15-r2 && \
    mkdir /pcap
COPY pcap2.sh /pcap2.sh

ENTRYPOINT ["bash", "/pcap2.sh"]
