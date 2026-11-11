#!/usr/bin/env bash
#
# Установка Docker CE на AlmaLinux 9, добавление пользователя devops в группу docker
# и запуск MailCatcher (образ на базе Alpine) через docker compose с автозапуском.
#
# Запуск: sudo bash install_mailcatcher.sh
#
set -euo pipefail

# ---------- Параметры ----------
DOCKER_USER="devops"
APP_DIR="/opt/containers/mailcatcher"
IMAGE="stpaquet/alpinemailcatcher:latest"   # Alpine-based MailCatcher
MAIL_LIMIT="50"                       # сколько писем хранить (по умолчанию в образе 50)
SMTP_PORT="1025"                      # SMTP
HTTP_PORT="1080"                      # Web UI
OPEN_FIREWALL="yes"                   # yes/no — открыть порты в firewalld

log()  { echo -e "\e[32m[+]\e[0m $*"; }
warn() { echo -e "\e[33m[!]\e[0m $*"; }
die()  { echo -e "\e[31m[x]\e[0m $*" >&2; exit 1; }

# ---------- Проверки ----------
[[ $EUID -eq 0 ]] || die "Запустите скрипт от root (sudo)."

if ! grep -qiE 'almalinux' /etc/os-release || ! grep -qE 'VERSION_ID="?9' /etc/os-release; then
    warn "Скрипт рассчитан на AlmaLinux 9, текущая ОС может отличаться."
fi

# ---------- 1. Установка Docker ----------
if ! command -v docker &>/dev/null; then
    log "Удаляю конфликтующие пакеты (podman, buildah, runc), если они есть..."
    dnf -y remove docker docker-client docker-client-latest docker-common \
        docker-latest docker-latest-logrotate docker-logrotate docker-engine \
        podman buildah runc &>/dev/null || true

    log "Подключаю репозиторий Docker CE..."
    dnf -y install dnf-plugins-core
    dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    log "Устанавливаю Docker CE и плагин compose..."
    dnf -y install docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin
else
    log "Docker уже установлен: $(docker --version)"
fi

log "Включаю автозапуск docker и containerd..."
systemctl enable --now containerd
systemctl enable --now docker

docker compose version &>/dev/null || die "Плагин docker compose не найден."

# ---------- 2. Пользователь devops ----------
if ! id "$DOCKER_USER" &>/dev/null; then
    log "Пользователь $DOCKER_USER не найден — создаю..."
    useradd -m -s /bin/bash "$DOCKER_USER"
fi

log "Добавляю $DOCKER_USER в группу docker..."
usermod -aG docker "$DOCKER_USER"

# ---------- 3. Каталог и compose-файл ----------
log "Создаю каталог $APP_DIR..."
mkdir -p "$APP_DIR"

log "Записываю $APP_DIR/compose.yaml..."
cat > "$APP_DIR/compose.yaml" <<EOF
services:
  mailcatcher:
    image: ${IMAGE}
    container_name: mailcatcher
    restart: always
    environment:
      MAIL_LIMIT: "${MAIL_LIMIT}"
    ports:
      - "${SMTP_PORT}:1025"   # SMTP
      - "${HTTP_PORT}:1080"   # Web UI
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
EOF

chown -R "$DOCKER_USER":"$DOCKER_USER" "$APP_DIR"

# ---------- 4. Firewalld ----------
if [[ "$OPEN_FIREWALL" == "yes" ]] && systemctl is-active --quiet firewalld; then
    log "Открываю порты ${SMTP_PORT}/tcp и ${HTTP_PORT}/tcp в firewalld..."
    firewall-cmd --permanent --add-port="${SMTP_PORT}/tcp"
    firewall-cmd --permanent --add-port="${HTTP_PORT}/tcp"
    firewall-cmd --reload
fi

# ---------- 5. Запуск ----------
log "Скачиваю образ и запускаю контейнер..."
cd "$APP_DIR"
docker compose pull
docker compose up -d

sleep 3
docker compose ps

if [[ "$(docker inspect -f '{{.State.Running}}' mailcatcher 2>/dev/null)" == "true" ]]; then
    IP=$(hostname -I | awk '{print $1}')
    log "Готово!"
    echo "    Web UI : http://${IP}:${HTTP_PORT}"
    echo "    SMTP   : ${IP}:${SMTP_PORT}"
    echo "    Пользователю ${DOCKER_USER} нужно перелогиниться, чтобы права группы docker вступили в силу."
else
    die "Контейнер не запустился. Смотрите: docker compose -f $APP_DIR/compose.yaml logs"
fi
