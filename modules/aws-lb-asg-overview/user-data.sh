#!/bin/bash

if command -v yum &> /dev/null; then
    echo "Sistema baseado em YUM/DNF detectado. Instalando git..."
    yum update -y
    yum install -y git stress-ng
    yum install -y stress-ng
elif command -v apt-get &> /dev/null; then
    echo "Sistema baseado em APT detectado. Instalando git..."
    apt-get update -y
    apt-get install -y git 
    apt-get install -y stress-ng
else
    echo "ERRO: Gerenciador de pacotes nao suportado (nem yum nem apt-get encontrado)." >&2
    exit 1
fi

CLONE_DIR="/opt/aws-web-infra-monitoring0"
REPO_URL="https://github.com/Nertonm/aws-web-infra-monitoring"
if [ -d "$CLONE_DIR" ]; then
    rm -rf "$CLONE_DIR"
fi
git clone "${REPO_URL}" "${CLONE_DIR}"

cd "${CLONE_DIR}"
chmod +x instalar_nginx.sh
./instalar_nginx.sh -y 
