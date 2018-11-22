FROM alpine:latest
ENV APPLICATION_VERSION 0.1.0

RUN apk add --no-cache jq bash git

ADD ./build-tags.sh /bin

CMD [ "build-tags.sh" ]
