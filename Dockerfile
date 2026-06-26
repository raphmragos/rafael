FROM openresty/openresty:alpine

# Mag-install ng mga kailangang gamit
RUN apk add --no-cache ca-certificates wget unzip tini

# I-download at i-install ang Xray kasama ang mga database
RUN wget --timeout=30 -qO /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip -q /tmp/xray.zip -d /tmp/xray/ && \
    mv /tmp/xray/xray /usr/local/bin/ && \
    mkdir -p /usr/local/share/xray/ && \
    mv /tmp/xray/geoip.dat /usr/local/share/xray/ && \
    mv /tmp/xray/geosite.dat /usr/local/share/xray/ && \
    chmod +x /usr/local/bin/xray && \
    # I-check kung gumagana ang Xray
    xray --version && \
    # Linisin ang mga hindi kailangan
    rm -rf /tmp/xray /tmp/xray.zip

# Kopyahin ang mga config
COPY config.json /etc/xray.json
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY index.html /usr/local/openresty/nginx/html/index.html

ENV XRAY_LOCATION_ASSET=/usr/local/share/xray/
EXPOSE 8080

# Gamitin ang tini para pamahalaan nang tama ang dalawang serbisyo
ENTRYPOINT ["/sbin/tini", "--"]
CMD sh -c "xray run -c /etc/xray.json & exec openresty -g 'daemon off;'"
