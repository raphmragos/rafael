FROM openresty/openresty:alpine

RUN apk add --no-cache ca-certificates wget unzip tini

# I-download ang Xray
RUN wget --timeout=60 -qO /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip -q /tmp/xray.zip -d /tmp/xray/ && \
    mv /tmp/xray/xray /usr/local/bin/ && \
    mkdir -p /usr/local/share/xray/ && \
    mv /tmp/xray/geoip.dat /usr/local/share/xray/ && \
    mv /tmp/xray/geosite.dat /usr/local/share/xray/ && \
    chmod +x /usr/local/bin/xray && \
    rm -rf /tmp/xray /tmp/xray.zip

COPY config.json /etc/xray.json
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY index.html /usr/local/openresty/nginx/html/index.html

ENV XRAY_LOCATION_ASSET=/usr/local/share/xray/
EXPOSE 8080

ENTRYPOINT ["/sbin/tini", "--"]
# Mas maayos na pagpapatakbo: parehong serbisyo na naka-monitor
CMD ["sh", "-c", "xray run -c /etc/xray.json & openresty -g 'daemon off;'"]
