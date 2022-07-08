FROM golang:1.18 as build-deps

ENV GO111MODULE=on

WORKDIR /usr/src/backend
COPY . .
RUN go mod download
RUN go build workers/server/main.go

FROM ubuntu:18.04

RUN apt-get -y update && apt-get -y install ca-certificates

WORKDIR /usr/src/app

COPY --from=build-deps /usr/src/backend/run.sh run.sh
COPY --from=build-deps /usr/src/backend/main main
COPY --from=build-deps /usr/src/backend/configs/$env/ config/

ENV LOG_PATH=/logs/server.log

ENTRYPOINT ["./run.sh"]