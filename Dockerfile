FROM alpine:latest
ENV APPLICATION_VERSION 0.0.1

RUN apk add --no-cache jq bash git

ADD ./build-tags.sh /bin

CMD [ "build-tags.sh" ]