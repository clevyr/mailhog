#
# MailHog Dockerfile
#

FROM golang:alpine AS builder

# Install MailHog:
RUN apk --no-cache add --virtual build-dependencies \
    git \
  && mkdir -p /root/gocode \
  && export GOPATH=/root/gocode \
  && go get github.com/clevyr/mailhog


FROM alpine

COPY --from=builder /root/gocode/bin/mailhog /usr/local/bin/

# Add mailhog user/group with uid/gid 1000.
# This is a workaround for boot2docker issue #581, see
# https://github.com/boot2docker/boot2docker/issues/581
RUN adduser -D -u 1000 mailhog

USER mailhog

WORKDIR /home/mailhog

ENTRYPOINT ["sh", "-c", "mailhog 2>/dev/null"]

# Expose the SMTP and HTTP ports:
EXPOSE 25 80

ENV MH_API_BIND_ADDR=:80
ENV MH_UI_BIND_ADDR=:80
ENV MH_SMTP_BIND_ADDR=:25
