#!/usr/bin/env bash
# نصب Docker روی Ubuntu
# اجرا: sudo ./install-docker.sh

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "❌ این اسکریپت باید با sudo یا root اجرا شود."
  exit 1
fi

echo "🔄 بروزرسانی پکیج‌ها..."
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release

echo "🔑 اضافه کردن کلید GPG و مخزن Docker..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

DIST_CODENAME=$(lsb_release -cs)
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${DIST_CODENAME} stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "📦 نصب Docker..."
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "⚙️ فعال‌سازی سرویس Docker..."
systemctl enable --now docker

if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
  echo "👤 اضافه کردن کاربر $SUDO_USER به گروه docker..."
  usermod -aG docker "$SUDO_USER"
  echo "ℹ️ لطفاً از سیستم خارج و دوباره وارد شوید یا دستور زیر را بزنید:"
  echo "   newgrp docker"
fi

echo "✅ نصب Docker کامل شد!"
docker --version
