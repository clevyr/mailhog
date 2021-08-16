FROM golang:alpine AS builder
RUN go get github.com/clevyr/mailhog


FROM alpine
WORKDIR /app

COPY --from=builder /go/bin/mailhog /usr/local/bin/

EXPOSE 25 80

ENV MH_API_BIND_ADDR=:80
ENV MH_UI_BIND_ADDR=:80
ENV MH_SMTP_BIND_ADDR=:25

CMD mailhog 2>&1 | grep -Fv ' [SMTP '
