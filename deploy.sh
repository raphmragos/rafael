#!/bin/bash
# ==============================================================================
# RAFAELTV PANEL (QWIKLABS / GCP CLOUD RUN OPTIMIZED)
# ENGINEERED BY RAFAELTV
# ==============================================================================

set -euo pipefail

BOLD='\033[1m'; RESET='\033[0m'
GREEN='\033[1;32m'; RED='\033[1;31m'; CYAN='\033[1;36m'
YELLOW='\033[1;33m'; MAGENTA='\033[1;35m'; WHITE='\033[1;37m'

loading() {
    local t="$1"
    local s="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    for ((i=0;i<5;i++)); do 
        for ((j=0;j<${#s};j++)); do 
            echo -ne "\r  ${CYAN}${s:$j:1} ${t}...${RESET}"
            sleep 0.05
        done
    done
    echo -ne "\r  ${GREEN}DONE: ${t}${RESET}\n"
}

clear
echo ""
echo -e "  ${BOLD}${WHITE}RAFAELTV PANEL (QWIKLABS OPTIMIZED)${RESET}"
echo -e "  ${MAGENTA}MADE BY RAFAELTV${RESET}"
echo -e "  ${GREEN}youtube.com/rafaeltv${RESET}"
echo ""

PROJECT_ID=$(gcloud config get-value project 2>/dev/null | tr -d '[:space:]')
if [ -z "$PROJECT_ID" ]; then
    echo -e "  ${RED}ERROR: No active GCP project detected. Run 'gcloud init' first.${RESET}"
    exit 1
fi
echo -e "  ${CYAN}PROJECT: ${GREEN}${PROJECT_ID}${RESET}"

# ✅ Pilit na itakda ang rehiyon para iwas error
DEFAULT_REGION="us-central1"
echo -ne "  ${CYAN}SETTING REGION: ${RESET}"
gcloud config set run/region ${DEFAULT_REGION} --quiet >/dev/null 2>&1
gcloud config set run/platform managed --quiet >/dev/null 2>&1
REGION=${DEFAULT_REGION}
echo -e "${GREEN}${REGION}${RESET}"
echo ""

# ==============================================================================
# SERVICE NAME & RESOURCE SETUP
# ==============================================================================
read -r -p "$(echo -e "  ${CYAN}SERVICE NAME [rafaeltv-panel]: ${RESET}")" INPUT_NAME
INPUT_NAME=$(echo "$INPUT_NAME" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')
SERVICE_NAME=${INPUT_NAME:-rafaeltv-panel}

echo ""
echo -e "  ${CYAN}SELECT MODE:${RESET}"
echo -e "  ${YELLOW}1) AUTO     (1 vCPU / 2Gi RAM) ✅ Recommended${RESET}"
echo -e "  ${YELLOW}2) HIGH     (2 vCPU / 4Gi RAM)${RESET}"
echo -e "  ${YELLOW}3) STABLE   (4 vCPU / 8Gi RAM)${RESET}"
echo -e "  ${YELLOW}4) CUSTOM   (Your own specs)${RESET}"
echo ""
read -r -p "$(echo -e "  ${CYAN}CHOICE: ${RESET}")" MODE_CHOICE

case "$MODE_CHOICE" in
    1) CPU="1"; RAM="2Gi"; MODE="AUTO"     ; MAX_INSTANCES="2";;
    2) CPU="2"; RAM="4Gi"; MODE="HIGH"     ; MAX_INSTANCES="2";;
    3) CPU="4"; RAM="8Gi"; MODE="STABLE"   ; MAX_INSTANCES="1";;
    4)
        echo ""
        read -r -p "$(echo -e "  ${CYAN}CPU (1/2/4): ${RESET}")" CPU
        read -r -p "$(echo -e "  ${CYAN}RAM (2Gi/4Gi/8Gi): ${RESET}")" RAM
        read -r -p "$(echo -e "  ${CYAN}MAX INSTANCES (1-3): ${RESET}")" MAX_INSTANCES
        MODE="CUSTOM"
        ;;
    *) CPU="1"; RAM="2Gi"; MODE="DEFAULT"; MAX_INSTANCES="2";;
esac

echo ""
loading "CREATING CONFIG FILES"

# ==============================================================================
# ✅ FIXED XRAY CONFIG (Tamang ID, XHTTP/HTTPUpgrade ready)
# ==============================================================================
cat > config.json <<'EOF'
{
  "log": { "loglevel": "warning" },
  "dns": {
    "servers": ["8.8.8.8", "8.8.4.4", "1.1.1.1", "1.0.0.1"],
    "queryStrategy": "UseIPv4",
    "disableCache": false
  },
  "inbounds": [
    {
      "port": 10000, "listen": "127.0.0.1", "protocol": "trojan", "tag": "trojan-ws",
      "settings": {"clients": [{"password": "rafaeltv"}]},
      "streamSettings": {"network": "ws", "security": "none", "wsSettings": {"path": "/rafaeltv", "headers": {}}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10001, "listen": "127.0.0.1", "protocol": "trojan", "tag": "trojan-hu",
      "settings": {"clients": [{"password": "rafaeltv"}]},
      "streamSettings": {"network": "httpupgrade", "security": "none", "httpupgradeSettings": {"path": "/rafaeltv-hu", "host": "#{Host}"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10002, "listen": "127.0.0.1", "protocol": "trojan", "tag": "trojan-xh",
      "settings": {"clients": [{"password": "rafaeltv"}]},
      "streamSettings": {"network": "xhttp", "security": "none", "xhttpSettings": {"path": "/rafaeltv-xh", "mode": "stream-up", "host": "#{Host}"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10003, "listen": "127.0.0.1", "protocol": "vmess", "tag": "vmess-ws",
      "settings": {"clients": [{"id": "b831381d-6324-4d53-ad4f-8cda48b30811", "alterId": 0, "security": "auto"}]},
      "streamSettings": {"network": "ws", "security": "none", "wsSettings": {"path": "/vmess-rafaeltv", "headers": {}}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10004, "listen": "127.0.0.1", "protocol": "vmess", "tag": "vmess-hu",
      "settings": {"clients": [{"id": "b831381d-6324-4d53-ad4f-8cda48b30811", "alterId": 0, "security": "auto"}]},
      "streamSettings": {"network": "httpupgrade", "security": "none", "httpupgradeSettings": {"path": "/vmess-rafaeltv-hu", "host": "#{Host}"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10005, "listen": "127.0.0.1", "protocol": "vmess", "tag": "vmess-xh",
      "settings": {"clients": [{"id": "b831381d-6324-4d53-ad4f-8cda48b30811", "alterId": 0, "security": "auto"}]},
      "streamSettings": {"network": "xhttp", "security": "none", "xhttpSettings": {"path": "/vmess-rafaeltv-xh", "mode": "stream-up", "host": "#{Host}"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10006, "listen": "127.0.0.1", "protocol": "vless", "tag": "vless-ws",
      "settings": {"clients": [{"id": "b831381d-6324-4d53-ad4f-8cda48b30811"}], "decryption": "none"},
      "streamSettings": {"network": "ws", "security": "none", "wsSettings": {"path": "/vless-rafaeltv", "headers": {}}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10007, "listen": "127.0.0.1", "protocol": "vless", "tag": "vless-hu",
      "settings": {"clients": [{"id": "b831381d-6324-4d53-ad4f-8cda48b30811"}], "decryption": "none"},
      "streamSettings": {"network": "httpupgrade", "security": "none", "httpupgradeSettings": {"path": "/vless-rafaeltv-hu", "host": "#{Host}"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10008, "listen": "127.0.0.1", "protocol": "vless", "tag": "vless-xh",
      "settings": {"clients": [{"id": "b831381d-6324-4d53-ad4f-8cda48b30811"}], "decryption": "none"},
      "streamSettings": {"network": "xhttp", "security": "none", "xhttpSettings": {"path": "/vless-rafaeltv-xh", "mode": "stream-up", "host": "#{Host}"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10009, "listen": "127.0.0.1", "protocol": "shadowsocks", "tag": "ss-ws",
      "settings": {"password": "rafaeltv", "method": "aes-256-gcm"},
      "streamSettings": {"network": "ws", "security": "none", "wsSettings": {"path": "/ss-rafaeltv", "headers": {}}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10010, "listen": "127.0.0.1", "protocol": "shadowsocks", "tag": "ss-hu",
      "settings": {"password": "rafaeltv", "method": "aes-256-gcm"},
      "streamSettings": {"network": "httpupgrade", "security": "none", "httpupgradeSettings": {"path": "/ss-rafaeltv-hu", "host": "#{Host}"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10011, "listen": "127.0.0.1", "protocol": "shadowsocks", "tag": "ss-xh",
      "settings": {"password": "rafaeltv", "method": "aes-256-gcm"},
      "streamSettings": {"network": "xhttp", "security": "none", "xhttpSettings": {"path": "/ss-rafaeltv-xh", "mode": "stream-up", "host": "#{Host}"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    }
  ],
  "outbounds": [{"protocol": "freedom", "tag": "direct"}, {"protocol": "blackhole", "tag": "block"}],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {"type": "field", "domain": ["geosite:category-ads-all"], "outboundTag": "block"},
      {"type": "field", "inboundTag": ["trojan-ws","trojan-hu","trojan-xh","vmess-ws","vmess-hu","vmess-xh","vless-ws","vless-hu","vless-xh","ss-ws","ss-hu","ss-xh"], "outboundTag": "direct"}
    ]
  }
}
EOF

# ==============================================================================
# ✅ FIXED NGINX CONF (Cloud Run compatible)
# ==============================================================================
cat > nginx.conf <<'EOF'
worker_processes auto;
error_log /dev/stdout info;
pid /run/nginx.pid;

events { worker_connections 8192; multi_accept on; }

http {
    include mime.types;
    default_type application/octet-stream;
    sendfile on; tcp_nopush on; tcp_nodelay on;
    keepalive_timeout 65; keepalive_requests 10000;
    client_max_body_size 100M;

    map $http_upgrade $connection_upgrade {
        default upgrade;
        ''      "";
    }

    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    server {
        listen 8080;
        server_name _;

        location = /health { return 200 "OK"; add_header Content-Type text/plain; access_log off; }

        location /rafaeltv         { proxy_pass http://127.0.0.1:10000; }
        location /rafaeltv-hu      { proxy_pass http://127.0.0.1:10001; }
        location /rafaeltv-xh      { proxy_pass http://127.0.0.1:10002; }
        location /vmess-rafaeltv   { proxy_pass http://127.0.0.1:10003; }
        location /vmess-rafaeltv-hu{ proxy_pass http://127.0.0.1:10004; }
        location /vmess-rafaeltv-xh{ proxy_pass http://127.0.0.1:10005; }
        location /vless-rafaeltv   { proxy_pass http://127.0.0.1:10006; }
        location /vless-rafaeltv-hu{ proxy_pass http://127.0.0.1:10007; }
        location /vless-rafaeltv-xh{ proxy_pass http://127.0.0.1:10008; }
        location /ss-rafaeltv      { proxy_pass http://127.0.0.1:10009; }
        location /ss-rafaeltv-hu   { proxy_pass http://127.0.0.1:10010; }
        location /ss-rafaeltv-xh   { proxy_pass http://127.0.0.1:10011; }

        location / {
            root /usr/local/openresty/nginx/html;
            index index.html index.htm;
        }
    }
}
EOF

# ==============================================================================
# ✅ FULLY FUNCTIONAL INDEX PANEL
# ==============================================================================
cat > index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>RAFAELTV PANEL - Akatsuki Edition</title>
    <style>
        :root {
            --bg-main: #0b0404;
            --bg-dark: #120404;
            --surface: #180505;
            --surface-dark: #0f0303;
            --border: #3d0a0a;
            --border-bright: #e62429;
            --text: #fce8e8;
            --text-dim: #b87070;
            --accent: #e62429;
            --glow: #ff3333;
            --green: #32e055;
        }
        * {margin:0; padding:0; box-sizing:border-box; font-family:Segoe UI, sans-serif;}
        body {background: linear-gradient(180deg, #050202 0%, #120404 100%); color: var(--text); min-height: 100vh; padding: 20px;}
        .container {max-width:750px; margin:0 auto;}
        .section {background: var(--surface); border: 2px solid var(--border); border-radius:8px; padding:24px; margin-bottom:20px;}
        h1 {text-align:center; color: var(--accent); font-size: 32px; margin-bottom:10px; text-shadow: 0 0 12px var(--glow);}
        .subtitle {text-align:center; color: var(--text-dim); margin-bottom:20px;}
        .info-row {display:flex; justify-content:space-between; padding:10px 0; border-bottom:1px solid #2a0808;}
        .info-label {color: var(--text-dim);}
        .info-value {color: var(--accent); font-weight: bold; font-family: monospace;}
    </style>
</head>
<body>
    <div class="container">
        <div class="section">
            <h1>✅ RAFAELTV PANEL ACTIVE</h1>
            <p class="subtitle">All protocols running • Cloud Run Optimized</p>
            <div class="info-row"><span class="info-label">HOST:</span><span class="info-value" id="host"></span></div>
            <div class="info-row"><span class="info-label">PORT:</span><span class="info-value">443 (TLS)</span></div>
            <div class="info-row"><span class="info-label">VMESS UUID:</span><span class="info-value">b831381d-6324-4d53-ad4f-8cda48b30811</span></div>
            <div class="info-row"><span class="info-label">VLESS/Trojan/SS Pass:</span><span class="info-value">rafaeltv</span></div>
        </div>
    </div>
    <script>
        document.getElementById('host').textContent = window.location.hostname;
    </script>
</body>
</html>
EOF

# ==============================================================================
# ✅ FIXED DOCKERFILE (Correct Xray version)
# ==============================================================================
cat > Dockerfile <<'EOF'
FROM openresty/openresty:alpine
RUN apk add --no-cache ca-certificates wget unzip tini

# Install Xray v24.12.15 (Minimum version for XHTTP/HTTPUpgrade)
RUN wget --timeout=60 -qO /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/v24.12.15/Xray-linux-64.zip && \
    unzip -q /tmp/xray.zip -d /tmp/xray/ && \
    mv /tmp/xray/xray /usr/local/bin/ && \
    mkdir -p /usr/local/share/xray/ && \
    mv /tmp/xray/geoip.dat /usr/local/share/xray/ && \
    mv /tmp/xray/geosite.dat /usr/local/share/xray/ && \
    chmod +x /usr/local/bin/xray && \
    xray --version && \
    rm -rf /tmp/xray /tmp/xray.zip

COPY config.json /etc/xray.json
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY index.html /usr/local/openresty/nginx/html/index.html

ENV XRAY_LOCATION_ASSET=/usr/local/share/xray/
ENV TZ=Asia/Singapore

EXPOSE 8080

ENTRYPOINT ["/sbin/tini", "--"]
CMD sh -c "xray run -c /etc/xray.json & exec openresty -g 'daemon off;'"
EOF

# ==============================================================================
# BUILD & DEPLOY
# ==============================================================================
loading "BUILDING DOCKER IMAGE"
gcloud builds submit --tag "gcr.io/${PROJECT_ID}/${SERVICE_NAME}" --project="$PROJECT_ID" --quiet > build.log 2>&1 || {
    echo -e "  ${RED}BUILD FAILED${RESET}"; tail -n 20 build.log; exit 1;
}

loading "DEPLOYING TO CLOUD RUN"
gcloud run deploy "$SERVICE_NAME" \
  --image "gcr.io/${PROJECT_ID}/${SERVICE_NAME}" \
  --platform managed --region "$REGION" \
  --cpu "$CPU" --memory "$RAM" --port 8080 \
  --concurrency 1000 --timeout 3600 \
  --min-instances 0 --max-instances "$MAX_INSTANCES" \
  --allow-unauthenticated --project="$PROJECT_ID" --quiet > deploy.log 2>&1 || {
    echo -e "  ${RED}DEPLOY FAILED${RESET}"; tail -n 20 deploy.log; exit 1;
}

# ==============================================================================
# GENERATE CONNECTION DETAILS
# ==============================================================================
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region "$REGION" --format='value(status.url)' 2>/dev/null || echo "")
CLEAN_HOST=$(echo "$SERVICE_URL" | sed 's|https://||; s|/$||')
VMESS_UUID="b831381d-6324-4d53-ad4f-8cda48b30811"

# Generate links
VLESS_WS="vless://b831381d-6324-4d53-ad4f-8cda48b30811@${CLEAN_HOST}:443?encryption=none&security=tls&sni=${CLEAN_HOST}&type=ws&path=/vless-rafaeltv&host=${CLEAN_HOST}#VLESS-WS"
VLESS_HU="vless://b831381d-6324-4d53-ad4f-8cda48b30811@${CLEAN_HOST}:443?encryption=none&security=tls&sni=${CLEAN_HOST}&type=httpupgrade&path=/vless-rafaeltv-hu&host=${CLEAN_HOST}#VLESS-HTTPUPGRADE"
VLESS_XH="vless://b831381d-6324-4d53-ad4f-8cda48b30811@${CLEAN_HOST}:443?encryption=none&security=tls&sni=${CLEAN_HOST}&type=xhttp&path=/vless-rafaeltv-xh&host=${CLEAN_HOST}&mode=stream-up#VLESS-XHTTP"

VMESS_WS_JSON='{"v":"2","ps":"VMESS-WS","add":"'"${CLEAN_HOST}"'","port":"443","id":"'"${VMESS_UUID}"'","aid":"0","scy":"auto","net":"ws","type":"none","host":"'"${CLEAN_HOST}"'","path":"/vmess-rafaeltv","tls":"tls","sni":"'"${CLEAN_HOST}"'"}'
VMESS_WS_B64=$(echo -n "$VMESS_WS_JSON" | base64 -w0)

TROJAN_WS="trojan://rafaeltv@${CLEAN_HOST}:443?security=tls&sni=${CLEAN_HOST}&type=ws&path=/rafaeltv&host=${CLEAN_HOST}#TROJAN-WS"
TROJAN_HU="trojan://rafaeltv@${CLEAN_HOST}:443?security=tls&sni=${CLEAN_HOST}&type=httpupgrade&path=/rafaeltv-hu&host=${CLEAN_HOST}#TROJAN-HTTPUPGRADE"
TROJAN_XH="trojan://rafaeltv@${CLEAN_HOST}:443?security=tls&sni=${CLEAN_HOST}&type=xhttp&path=/rafaeltv-xh&host=${CLEAN_HOST}&mode=stream-up#TROJAN-XHTTP"

# ==============================================================================
# FINAL OUTPUT
# ==============================================================================
echo ""
echo -e "  ${GREEN}✅ DEPLOYMENT SUCCESSFUL${RESET}"
echo -e "  ${CYAN}PANEL URL: ${GREEN}${SERVICE_URL}${RESET}"
echo -e "  ${CYAN}HOST:      ${GREEN}${CLEAN_HOST}${RESET}"
echo -e "  ${CYAN}PORT:      ${GREEN}443 (TLS)${RESET}"
echo -e "  ${CYAN}MODE:      ${GREEN}${MODE} (${CPU} vCPU / ${RAM})${RESET}"
echo ""

echo -e "  ${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "  ${GREEN}🔗 CONNECTION LINKS${RESET}"
echo -e "  ${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "  ${CYAN}VLESS WS:          ${GREEN}${VLESS_WS}${RESET}"
echo -e "  ${CYAN}VLESS HTTPUPGRADE: ${GREEN}${VLESS_HU}${RESET}"
echo -e "  ${CYAN}VLESS XHTTP:       ${GREEN}${VLESS_XH}${RESET}"
echo -e "  ${CYAN}VMESS WS:          ${GREEN}vmess://${VMESS_WS_B64}${RESET}"
echo -e "  ${CYAN}TROJAN WS:         ${GREEN}${TROJAN_WS}${RESET}"
echo -e "  ${CYAN}TROJAN HTTPUPGRADE:${GREEN}${TROJAN_HU}${RESET}"
echo -e "  ${CYAN}TROJAN XHTTP:      ${GREEN}${TROJAN_XH}${RESET}"
echo ""

rm -f build.log deploy.log
echo -e "\n  ${GREEN}✅ ALL DONE!${RESET}"
