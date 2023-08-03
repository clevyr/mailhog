FROM --platform=$BUILDPLATFORM golang:1.20-alpine AS builder
WORKDIR /app

COPY go.mod go.sum .
RUN go mod download

ARG GOOS=linux
ARG GOARCH=amd64
COPY . .

# Set Golang build envs based on Docker platform string
ARG TARGETPLATFORM
RUN set -x \
    && case "$TARGETPLATFORM" in \
        'linux/amd64') export GOARCH=amd64 ;; \
        'linux/arm/v6') export GOARCH=arm GOARM=6 ;; \
        'linux/arm/v7') export GOARCH=arm GOARM=7 ;; \
        'linux/arm64') export GOARCH=arm64 ;; \
        *) echo "Unsupported target: $TARGETPLATFORM" && exit 1 ;; \
    esac \
    && go build -ldflags='-w -s'

FROM alpine:3.18
WORKDIR /app

COPY --from=builder /app/MailHog /usr/local/bin/mailhog

EXPOSE 25 80

ENV MH_API_BIND_ADDR=:80
ENV MH_UI_BIND_ADDR=:80
ENV MH_SMTP_BIND_ADDR=:25

CMD mailhog 2>&1 | grep -Fv ' [SMTP '
