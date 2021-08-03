ARG GOLANG_VERSION=1.16
ARG ALPINE_VERSION=3.14
ARG PROJECT_NAME=go-template-repo

FROM golang:${GOLANG_VERSION}-alpine${ALPINE_VERSION} AS builder

LABEL maintainer="zhilyaev.dmitriy+${PROJECT_NAME}@gmail.com"
LABEL name="go-template-repo"

# enable Go modules support
ENV GO111MODULE=on
ENV CGO_ENABLED=0

WORKDIR ${PROJECT_NAME}

COPY go.mod go.sum ./
RUN go mod download

# Copy src code from the host and compile it
COPY cmd cmd
COPY pkg pkg
RUN go build -a -o /${PROJECT_NAME} .

###
FROM alpine:${ALPINE_VERSION} as base-release
RUN apk --no-cache add ca-certificates
ENTRYPOINT ["/bin/go-template-repo"]

###
FROM base-release as goreleaser
COPY ${PROJECT_NAME} /bin/

###
FROM base-release
COPY --from=builder /${PROJECT_NAME} /bin/
