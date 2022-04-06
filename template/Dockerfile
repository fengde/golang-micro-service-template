FROM golang:1.15.14-alpine3.14 AS builder

WORKDIR /build
COPY . .

RUN CGO_ENABLED=0 GOARCH=amd64 GOOS=linux go build -mod vendor -o app template.go

FROM centos:7.9.2009

WORKDIR /runtime
COPY --from=builder /build/app /runtime/app
COPY --from=builder /build/etc /runtime/etc
COPY --from=builder /build/.env /runtime/.env

EXPOSE 8888

ENV TZ Asia/Shanghai
RUN ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone

ENTRYPOINT [ "sh", "-c", "/runtime/app" ]