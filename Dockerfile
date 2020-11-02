FROM haproxy:2.2.4-alpine
RUN apk add --update curl && rm -rf /var/cache/apk/*
RUN mkdir -p /etc/confd/conf.d
RUN mkdir -p /etc/confd/templates
RUN mkdir -p /etc/haproxy/certs
COPY confd .
RUN chmod +x confd
COPY haproxy.toml /etc/confd/conf.d/
COPY haproxy.tmpl /etc/confd/templates/
COPY all.pem /etc/haproxy/certs/
COPY boot.sh .
COPY watcher.sh .
EXPOSE 443
EXPOSE 80
CMD ["./boot.sh"]
