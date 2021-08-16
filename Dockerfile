FROM golang:alpine AS builder
WORKDIR /app

COPY go.mod go.sum .
RUN go mod download

ARG GOOS=linux
ARG GOARCH=amd64
COPY . .
RUN go build -ldflags='-w -s'

FROM alpine
WORKDIR /app

COPY --from=builder /app/MailHog /usr/local/bin/mailhog

EXPOSE 25 80

ENV MH_API_BIND_ADDR=:80
ENV MH_UI_BIND_ADDR=:80
ENV MH_SMTP_BIND_ADDR=:25

CMD mailhog 2>&1 | grep -Fv ' [SMTP '
