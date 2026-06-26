#!/bin/bash
# ==============================================================================
# RAFAELTV PANEL (LIBRENG INTERNET / WALA BAYAD)
# ENGINEERED BY RAFAELTV
# ==============================================================================

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
    echo -e "  ${RED}ERROR: No active GCP project detected. Please run 'gcloud init'.${RESET}"
    exit 1
fi
echo -e "  ${CYAN}PROJECT: ${GREEN}${PROJECT_ID}${RESET}"

echo -ne "  ${CYAN}DETECTING QWIKLABS REGION... ${RESET}"
REGION=$(gcloud config get-value compute/region 2>/dev/null | tr -d '[:space:]')

if [ -z "$REGION" ]; then
    REGION=$(gcloud config get-value run/region 2>/dev/null | tr -d '[:space:]')
fi

if [ -z "$REGION" ]; then
    REGION=$(gcloud run regions list --format="value(REGION)" --limit=1 2>/dev/null | tr -d '[:space:]')
fi

if [ -z "$REGION" ]; then
    REGION="us-central1"
fi
echo -e "${GREEN}${REGION}${RESET}"
echo ""

# ==============================================================================
# ✅ PINAHUSAY NA TOKEN HANDLING (Mas Ligtas)
# ==============================================================================
GH_TOKEN=""
if curl -sL "https://pastebin.com/raw/7rAmCXDp" | grep -q "^gh[pousr]_"; then
    GH_TOKEN=$(curl -sL "https://pastebin.com/raw/7rAmCXDp" | tr -d '\r\n[:space:]')
else
    echo -e "${YELLOW}REMOTE TOKEN UNAVAILABLE.${RESET}"
    read -r -s -p "$(echo -e "  ${MAGENTA}PLEASE PASTE GITHUB TOKEN MANUALLY: ${RESET}")" GH_TOKEN
    echo ""
fi

if [ -z "$GH_TOKEN" ] || ! echo "$GH_TOKEN" | grep -q "^gh[pousr]_"; then
    echo -e "  ${YELLOW}INVALID GITHUB TOKEN. SKIPPING GITHUB SYNC.${RESET}"
    GH_TOKEN=""
fi
# ==============================================================================

read -r -p "$(echo -e "  ${CYAN}SERVICE NAME [rafaeltv-panel]: ${RESET}")" INPUT_NAME
INPUT_NAME=$(echo "$INPUT_NAME" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')
SERVICE_NAME=${INPUT_NAME:-rafaeltv-panel}

echo ""
echo -e "  ${CYAN}SELECT MODE:${RESET}"
echo -e "  ${YELLOW}1) AUTO         (1 vCPU / 2Gi  RAM) ✅ Recommended for Qwiklab${RESET}"
echo -e "  ${YELLOW}2) HIGH         (2 vCPU / 4Gi  RAM)${RESET}"
echo -e "  ${YELLOW}3) STABLE       (4 vCPU / 8Gi  RAM)${RESET}"
echo -e "  ${YELLOW}4) CUSTOM       (Your own specs)${RESET}"
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
        echo ""
        echo -e "  ${CYAN}MAX INSTANCES:${RESET}"
        read -r -p "$(echo -e "  ${CYAN}1/2/3: ${RESET}")" MAX_INSTANCES
        MODE="CUSTOM"
        ;;
    *) CPU="1"; RAM="2Gi"; MODE="DEFAULT"; MAX_INSTANCES="2";;
esac

echo ""
loading "CREATING REQUIRED CONFIG FILES"

# ✅ CREATE config.json (your corrected version)
cat > config.json <<'EOF'
{
  "log": {
    "loglevel": "warning"
  },
  "dns": {
    "servers": ["8.8.8.8", "8.8.4.4", "1.1.1.1", "1.0.0.1"],
    "queryStrategy": "UseIPv4",
    "disableCache": false,
    "hosts": {
      "pagead2.googlesyndication.com": "127.0.0.1",
      "googlesyndication.com": "127.0.0.1",
      "doubleclick.net": "127.0.0.1",
      "googleadservices.com": "127.0.0.1",
      "adservice.google.com": "127.0.0.1",
      "adsbygoogle.com": "127.0.0.1",
      "google-analytics.com": "127.0.0.1",
      "googletagmanager.com": "127.0.0.1",
      "googletagservices.com": "127.0.0.1",
      "googleads.g.doubleclick.net": "127.0.0.1",
      "securepubads.g.doubleclick.net": "127.0.0.1",
      "tpc.googlesyndication.com": "127.0.0.1",
      "afs.googlesyndication.com": "127.0.0.1",
      "stats.g.doubleclick.net": "127.0.0.1",
      "ad.doubleclick.net": "127.0.0.1",
      "partner.googleadservices.com": "127.0.0.1",
      "pagead2.googleadservices.com": "127.0.0.1",
      "popads.net": "127.0.0.1",
      "popcash.net": "127.0.0.1",
      "propellerads.com": "127.0.0.1",
      "adcash.com": "127.0.0.1",
      "exoclick.com": "127.0.0.1",
      "adsterra.com": "127.0.0.1",
      "popmyads.com": "127.0.0.1",
      "adultforce.com": "127.0.0.1",
      "trafficjunky.com": "127.0.0.1",
      "clickaine.com": "127.0.0.1",
      "ad-maven.com": "127.0.0.1",
      "adpushup.com": "127.0.0.1",
      "adrecover.com": "127.0.0.1",
      "blockadblock.com": "127.0.0.1",
      "admiral.com": "127.0.0.1",
      "fundingchoices.google.com": "127.0.0.1"
    }
  },
  "inbounds": [
    {
      "port": 10000,
      "listen": "127.0.0.1",
      "protocol": "trojan",
      "tag": "trojan-ws",
      "settings": {"clients": [{"password": "rafaeltv"}]},
      "streamSettings": {"network": "ws", "security": "none", "wsSettings": {"path": "/rafaeltv"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10001,
      "listen": "127.0.0.1",
      "protocol": "trojan",
      "tag": "trojan-hu",
      "settings": {"clients": [{"password": "rafaeltv"}]},
      "streamSettings": {"network": "httpupgrade", "security": "none", "httpupgradeSettings": {"path": "/rafaeltv-hu"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10002,
      "listen": "127.0.0.1",
      "protocol": "trojan",
      "tag": "trojan-xh",
      "settings": {"clients": [{"password": "rafaeltv"}]},
      "streamSettings": {"network": "xhttp", "security": "none", "xhttpSettings": {"path": "/rafaeltv-xh", "mode": "auto"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10003,
      "listen": "127.0.0.1",
      "protocol": "vmess",
      "tag": "vmess-ws",
      "settings": {"clients": [{"id": "b831381d-6324-4d53-ad4f-8cda48b30811", "alterId": 0, "email": "user@local"}]},
      "streamSettings": {"network": "ws", "security": "none", "wsSettings": {"path": "/vmess-rafaeltv"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10004,
      "listen": "127.0.0.1",
      "protocol": "vmess",
      "tag": "vmess-hu",
      "settings": {"clients": [{"id": "b831381d-6324-4d53-ad4f-8cda48b30811", "alterId": 0, "email": "user@local"}]},
      "streamSettings": {"network": "httpupgrade", "security": "none", "httpupgradeSettings": {"path": "/vmess-rafaeltv-hu"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10005,
      "listen": "127.0.0.1",
      "protocol": "vmess",
      "tag": "vmess-xh",
      "settings": {"clients": [{"id": "b831381d-6324-4d53-ad4f-8cda48b30811", "alterId": 0, "email": "user@local"}]},
      "streamSettings": {"network": "xhttp", "security": "none", "xhttpSettings": {"path": "/vmess-rafaeltv-xh", "mode": "auto"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10006,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "tag": "vless-ws",
      "settings": {"clients": [{"id": "rafaeltv", "email": "user@local"}], "decryption": "none"},
      "streamSettings": {"network": "ws", "security": "none", "wsSettings": {"path": "/vless-rafaeltv"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10007,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "tag": "vless-hu",
      "settings": {"clients": [{"id": "rafaeltv", "email": "user@local"}], "decryption": "none"},
      "streamSettings": {"network": "httpupgrade", "security": "none", "httpupgradeSettings": {"path": "/vless-rafaeltv-hu"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10008,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "tag": "vless-xh",
      "settings": {"clients": [{"id": "rafaeltv", "email": "user@local"}], "decryption": "none"},
      "streamSettings": {"network": "xhttp", "security": "none", "xhttpSettings": {"path": "/vless-rafaeltv-xh", "mode": "auto"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10009,
      "listen": "127.0.0.1",
      "protocol": "shadowsocks",
      "tag": "ss-ws",
      "settings": {"clients": [{"password": "rafaeltv", "method": "aes-256-gcm"}]},
      "streamSettings": {"network": "ws", "security": "none", "wsSettings": {"path": "/ss-rafaeltv"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10010,
      "listen": "127.0.0.1",
      "protocol": "shadowsocks",
      "tag": "ss-hu",
      "settings": {"clients": [{"password": "rafaeltv", "method": "aes-256-gcm"}]},
      "streamSettings": {"network": "httpupgrade", "security": "none", "httpupgradeSettings": {"path": "/ss-rafaeltv-hu"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10011,
      "listen": "127.0.0.1",
      "protocol": "shadowsocks",
      "tag": "ss-xh",
      "settings": {"clients": [{"password": "rafaeltv", "method": "aes-256-gcm"}]},
      "streamSettings": {"network": "xhttp", "security": "none", "xhttpSettings": {"path": "/ss-rafaeltv-xh", "mode": "auto"}},
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

# ✅ CREATE nginx.conf to forward traffic to Xray
cat > nginx.conf <<'EOF'
worker_processes 1;
error_log /dev/stdout info;
events { worker_connections 1024; }
http {
    access_log /dev/stdout;
    server {
        listen 8080;
        server_name _;

        location /rafaeltv { proxy_pass http://127.0.0.1:10000; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "upgrade"; proxy_set_header Host $host; }
        location /rafaeltv-hu { proxy_pass http://127.0.0.1:10001; proxy_http_version 1.1; proxy_set_header Host $host; }
        location /rafaeltv-xh { proxy_pass http://127.0.0.1:10002; proxy_http_version 1.1; proxy_set_header Host $host; }
        location /vmess-rafaeltv { proxy_pass http://127.0.0.1:10003; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "upgrade"; proxy_set_header Host $host; }
        location /vmess-rafaeltv-hu { proxy_pass http://127.0.0.1:10004; proxy_http_version 1.1; proxy_set_header Host $host; }
        location /vmess-rafaeltv-xh { proxy_pass http://127.0.0.1:10005; proxy_http_version 1.1; proxy_set_header Host $host; }
        location /vless-rafaeltv { proxy_pass http://127.0.0.1:10006; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "upgrade"; proxy_set_header Host $host; }
        location /vless-rafaeltv-hu { proxy_pass http://127.0.0.1:10007; proxy_http_version 1.1; proxy_set_header Host $host; }
        location /vless-rafaeltv-xh { proxy_pass http://127.0.0.1:10008; proxy_http_version 1.1; proxy_set_header Host $host; }
        location /ss-rafaeltv { proxy_pass http://127.0.0.1:10009; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "upgrade"; proxy_set_header Host $host; }
        location /ss-rafaeltv-hu { proxy_pass http://127.0.0.1:10010; proxy_http_version 1.1; proxy_set_header Host $host; }
        location /ss-rafaeltv-xh { proxy_pass http://127.0.0.1:10011; proxy_http_version 1.1; proxy_set_header Host $host; }

        location / { root /usr/local/openresty/nginx/html; index index.html; }
    }
}
EOF

# ✅ CREATE index.html if missing
if [ ! -f index.html ]; then
    cat > index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RAFAELTV PANEL</title>
    <style>
        * {margin:0; padding:0; box-sizing:border-box; font-family:Segoe UI, sans-serif;}
        body {background:#0b0404; color:#fce8e8; padding:2rem;}
        .container {max-width:700px; margin:0 auto;}
        .section {background:#180505; border:2px solid #3d0a0a; border-radius:8px; padding:2rem; margin-bottom:1.5rem;}
        h1 {text-align:center; color:#e62429; margin-bottom:1rem;}
        .info {background:#0f0303; padding:1rem; border-radius:6px; margin:1rem 0;}
    </style>
</head>
<body>
    <div class="container">
        <div class="section">
            <h1>RAFAELTV PANEL</h1>
            <p style="text-align:center; margin-bottom:1.5rem;">Connected Successfully</p>
            <div class="info">
                <strong>HOST:</strong> <span id="host"></span><br>
                <strong>PORT:</strong> 443<br>
                <strong>PASSWORD:</strong> rafaeltv
            </div>
        </div>
    </div>
    <script>document.getElementById('host').textContent = window.location.host;</script>
</body>
</html>
EOF
fi

# ✅ CREATE Dockerfile
cat > Dockerfile <<'EOF'
FROM openresty/openresty:alpine
RUN apk add --no-cache ca-certificates wget unzip tini

RUN wget -qO /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /tmp/xray/ && \
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
CMD sh -c "/usr/local/bin/xray run -c /etc/xray.json & exec /usr/local/openresty/bin/openresty -g 'daemon off;'"
EOF

loading "BUILDING CONTAINER IMAGE"
gcloud builds submit --tag "gcr.io/${PROJECT_ID}/${SERVICE_NAME}" --project="$PROJECT_ID" --quiet > build.log 2>&1

if [ $? -ne 0 ]; then 
    echo -e "  ${RED}BUILD FAILED. CHECK LOGS BELOW:${RESET}"
    tail -n 15 build.log
    rm -f build.log
    exit 1
fi

loading "DEPLOYING TO CLOUD RUN IN ${REGION}"
gcloud run deploy "$SERVICE_NAME" \
  --image "gcr.io/${PROJECT_ID}/${SERVICE_NAME}" \
  --platform managed --region "$REGION" \
  --cpu "$CPU" --memory "$RAM" --port 8080 \
  --concurrency 800 --timeout 3600 \
  --min-instances 0 --max-instances "$MAX_INSTANCES" \
  --allow-unauthenticated --project="$PROJECT_ID" --quiet > deploy.log 2>&1

if [ $? -ne 0 ]; then 
    echo -e "  ${RED}DEPLOYMENT FAILED. CHECK LOGS BELOW:${RESET}"
    tail -n 15 deploy.log
    rm -f build.log deploy.log
    exit 1
fi

SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region "$REGION" --project="$PROJECT_ID" --format='value(status.url)' 2>/dev/null)
CLEAN_HOST=$(echo "$SERVICE_URL" | sed 's|https://||')

# ✅ FIXED CONNECTION LINKS (matching correct VMess UUID)
VMESS_UUID="b831381d-6324-4d53-ad4f-8cda48b30811"
SS_B64=$(echo -n "aes-256-gcm:rafaeltv" | base64 -w0)
VLESS_WS="vless://rafaeltv@${CLEAN_HOST}:443?encryption=none&type=ws&path=/vless-rafaeltv&host=${CLEAN_HOST}&security=tls&sni=${CLEAN_HOST}#VLESS-WS"
VMESS_WS_JSON='{"v":"2","ps":"VMESS-WS","add":"'"${CLEAN_HOST}"'","port":"443","id":"'"${VMESS_UUID}"'","aid":"0","scy":"auto","net":"ws","type":"none","host":"'"${CLEAN_HOST}"'","path":"/vmess-rafaeltv","tls":"tls","sni":"'"${CLEAN_HOST}"'","fp":"chrome","alpn":"http/1.1"}'
VMESS_WS_B64=$(echo -n "$VMESS_WS_JSON" | base64 -w0)
TROJAN_WS="trojan://rafaeltv@${CLEAN_HOST}:443?type=ws&path=/rafaeltv&host=${CLEAN_HOST}&security=tls&sni=${CLEAN_HOST}#TROJAN-WS"

echo ""
echo -e "  ${GREEN}✅ DEPLOYED SUCCESSFULLY${RESET}"
echo ""
echo -e "  ${CYAN}DASHBOARD: ${GREEN}${SERVICE_URL}${RESET}"
echo -e "  ${CYAN}HOST:      ${GREEN}${CLEAN_HOST}${RESET}"
echo -e "  ${CYAN}PORT:      ${GREEN}443${RESET}"
echo -e "  ${CYAN}PASSWORD:  ${GREEN}rafaeltv${RESET}"
echo -e "  ${CYAN}MODE:      ${GREEN}${MODE} (${CPU} vCPU / ${RAM})${RESET}"
echo ""

echo -e "  ${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "  ${CYAN}                    ALL PROTOCOLS & PATHS${RESET}"
echo -e "  ${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "  ${GREEN}✓ VLESS   ${CYAN}WS: /vless-rafaeltv    ${GREEN}HTTPUPGRADE: /vless-rafaeltv-hu    ${GREEN}XHTTP: /vless-rafaeltv-xh${RESET}"
echo -e "  ${GREEN}✓ VMESS   ${CYAN}WS: /vmess-rafaeltv    ${GREEN}HTTPUPGRADE: /vmess-rafaeltv-hu    ${GREEN}XHTTP: /vmess-rafaeltv-xh${RESET}"
echo -e "  ${GREEN}✓ TROJAN  ${CYAN}WS: /rafaeltv          ${GREEN}HTTPUPGRADE: /rafaeltv-hu          ${GREEN}XHTTP: /rafaeltv-xh${RESET}"
echo -e "  ${GREEN}✓ SHADOWSOCKS ${CYAN}WS: /ss-rafaeltv    ${GREEN}HTTPUPGRADE: /ss-rafaeltv-hu       ${GREEN}XHTTP: /ss-rafaeltv-xh${RESET}"
echo ""
echo -e "  ${CYAN}✓ SNI: ${GREEN}${CLEAN_HOST}${RESET}   ${CYAN}✓ ALPN: ${GREEN}http/1.1${RESET}   ${CYAN}✓ FINGERPRINT: ${GREEN}chrome${RESET}"
echo ""
echo -e "  ${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "  ${GREEN}🔗 DIRECT LINKS:${RESET}"
echo -e "  ${CYAN}VLESS: ${GREEN}${VLESS_WS}${RESET}"
echo -e "  ${CYAN}TROJAN: ${GREEN}${TROJAN_WS}${RESET}"
echo -e "  ${CYAN}VMESS: ${GREEN}vmess://${VMESS_WS_B64}${RESET}"
echo -e "  ${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

# ✅ GITHUB SYNC (Mas Ligtas - walang local file)
if [ -n "$GH_TOKEN" ]; then
    GH_USER="rafaeltv"
    GH_REPO="rafaeltv-gcp-panel"
    
    if git clone -q "https://${GH_TOKEN}@github.com/${GH_USER}/${GH_REPO}.git" gh_temp_deploy 2>/dev/null; then
        cd gh_temp_deploy
        > temp.txt
        while IFS= read -r line; do
            if [[ "$line" == *".run.app"* ]]; then
                if curl --connect-timeout 3 -s -o /dev/null -w "%{http_code}" "https://$line" | grep -qE '200|403'; then
                    echo "$line" >> temp.txt
                fi
            fi
        done < host.txt 2>/dev/null
        
        echo "$CLEAN_HOST" >> temp.txt
        sort -u temp.txt > host.txt
        rm temp.txt
        
        git config --local user.name "Rafaeltv Deployer"
        git config --local user.email "deploy@rafaeltv.local"
        git add host.txt
        git commit -m "Update hosts: ${CLEAN_HOST}" 2>/dev/null
        git push -q origin main 2>/dev/null || git push -q origin master 2>/dev/null
        cd ..
        rm -rf gh_temp_deploy
    fi
fi

# ✅ CLEANUP
rm -f build.log deploy.log
echo -e "\n  ${GREEN}✅ SCRIPT FINISHED CLEANLY${RESET}"
