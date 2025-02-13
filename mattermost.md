```
apt update
apt install docker.io docker-compose curl
git clone https://github.com/mattermost/docker
cd docker/
cp env.example .env
hostnamectl #посмотреть hostname
nvim .env #вписать hostname в DOMAIN
mkdir -p ./volumes/app/mattermost/{config,data,logs,plugins,client/plugins,bleve-indexes}
sudo chown -R 2000:2000 ./volumes/app/mattermost
sudo docker-compose -f docker-compose.yml -f docker-compose.without-nginx.yml up -d
```

Deploy Mattermost via Docker
==============================
https://docs.mattermost.com/install/install-docker.html#deploy-mattermost-on-docker-for-production-use



**Чтобы создать бота в Mattermost и получить его токен, выполните следующие шаги:**

### 1. Включите поддержку ботов (если требуется)
Если у вас нет прав администратора, пропустите этот шаг. Если есть:
1. Перейдите в **System Console** → **Integrations** → **Bot Accounts**.
2. Убедитесь, что **Enable Bot Account Creation** включен.
3. Нажмите **Save**.

### 2. Создайте бота
1. В Mattermost откройте **Main Menu** (нажмите на свой аватар в левом верхнем углу).
2. Выберите **Integrations** → **Bot Accounts**.
3. Нажмите **Create Bot Account**.
4. Введите **Display Name**, **Username** и (по желанию) **Description**.
5. Если бот должен отправлять сообщения в каналы, включите **Allow this bot to post messages**.
6. Нажмите **Create Bot Account**.

### 3. Получите токен
1. После создания бота появится окно с его токеном.
2. Скопируйте токен и сохраните его в надежном месте (он отображается только один раз).
3. Если окно уже закрыто, вам нужно создать нового бота, так как Mattermost не позволяет повторно просмотреть токен.

### 4. Добавьте бота в канал
1. Введите команду в любом канале:  
   ```
   /invite @botname
   ```
2. Теперь бот сможет взаимодействовать с участниками канала.

Готово! Теперь вы можете использовать этот токен для аутентификации в API Mattermost. 🚀



