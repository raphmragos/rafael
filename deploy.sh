#!/bin/bash
# ==============================================================================
# VIRGOZKI PANEL (LIBRENG INTERNET / WALA BAYAD)
# ENGINEERED BY VIRGOZKI
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
echo -e "  ${BOLD}${WHITE}VIRGOZKI PANEL (QWIKLABS OPTIMIZED)${RESET}"
echo -e "  ${MAGENTA}MADE BY VIRGOZKI${RESET}"
echo -e "  ${GREEN}NO XHTTP • CLEAN & ERROR FREE${RESET}"
echo ""

PROJECT_ID=$(gcloud config get-value project 2>/dev/null | tr -d '[:space:]')
if [ -z "$PROJECT_ID" ]; then
    echo -e "  ${RED}ERROR: No active GCP project detected. Please run 'gcloud init'.${RESET}"
    exit 1
fi
echo -e "  ${CYAN}PROJECT: ${GREEN}${PROJECT_ID}${RESET}"

echo -ne "  ${CYAN}DETECTING QWIKLABS REGION... ${RESET}"
REGION=$(gcloud config get-value compute/region 2>/dev/null | tr -d '[:space:]')
[ -z "$REGION" ] && REGION=$(gcloud config get-value run/region 2>/dev/null | tr -d '[:space:]')
[ -z "$REGION" ] && REGION=$(gcloud run regions list --format="value(REGION)" --limit=1 2>/dev/null | tr -d '[:space:]')
[ -z "$REGION" ] && REGION="us-central1"
echo -e "${GREEN}${REGION}${RESET}"
echo ""

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

read -r -p "$(echo -e "  ${CYAN}SERVICE NAME [virgozki-panel]: ${RESET}")" INPUT_NAME
INPUT_NAME=$(echo "$INPUT_NAME" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')
SERVICE_NAME=${INPUT_NAME:-virgozki-panel}

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
        read -r -p "$(echo -e "  ${CYAN}MAX INSTANCES (1-3): ${RESET}")" MAX_INSTANCES
        MODE="CUSTOM"
        ;;
    *) CPU="1"; RAM="2Gi"; MODE="DEFAULT"; MAX_INSTANCES="2";;
esac

echo ""
loading "CREATING CONFIG FILES"

cat > config.json <<'EOF'
{
  "log": { "loglevel": "warning" },
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
      "settings": {"clients": [{"password": "virgozki"}]},
      "streamSettings": {"network": "ws", "security": "none", "wsSettings": {"path": "/virgozki"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10001,
      "listen": "127.0.0.1",
      "protocol": "trojan",
      "tag": "trojan-hu",
      "settings": {"clients": [{"password": "virgozki"}]},
      "streamSettings": {"network": "httpupgrade", "security": "none", "httpupgradeSettings": {"path": "/virgozki-hu"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10003,
      "listen": "127.0.0.1",
      "protocol": "vmess",
      "tag": "vmess-ws",
      "settings": {"clients": [{"id": "b831381d-6324-4d53-ad4f-8cda48b30811", "alterId": 0, "email": "user@local"}]},
      "streamSettings": {"network": "ws", "security": "none", "wsSettings": {"path": "/vmess-virgozki"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10004,
      "listen": "127.0.0.1",
      "protocol": "vmess",
      "tag": "vmess-hu",
      "settings": {"clients": [{"id": "b831381d-6324-4d53-ad4f-8cda48b30811", "alterId": 0, "email": "user@local"}]},
      "streamSettings": {"network": "httpupgrade", "security": "none", "httpupgradeSettings": {"path": "/vmess-virgozki-hu"}},
      "sniffing": {"enabled": true, "destOverride": ["http", "tls"]}
    },
    {
      "port": 10006,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "tag": "vless-ws",
      "settings": {"clients": [{"id": "b831381d-6324-4d53-ad4f-8cda48b30811", "email": "user@local"}], "decryption": "none"},
      "streamSettings": {"network": "ws", "security": "none", "wsSettings": {"path": "/vless-virgozki"
