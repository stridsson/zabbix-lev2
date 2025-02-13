На **AlmaLinux** можно установить и запустить **PostgreSQL Server** следующим образом:

---

### **1. Установка PostgreSQL**
AlmaLinux использует **dnf** для управления пакетами.

#### **Шаг 1: Обновите систему**
```bash
sudo dnf update -y
```

#### **Шаг 2: Установите репозиторий PostgreSQL**
AlmaLinux 8/9 не содержит последние версии PostgreSQL в основных репозиториях, поэтому добавьте официальный репозиторий:

```bash
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-$(rpm -E %rhel)-x86_64/pgdg-redhat-repo-latest.noarch.rpm
```

#### **Шаг 3: Установите PostgreSQL**
Узнайте доступные версии PostgreSQL:
```bash
dnf list postgresql*
```
Например, чтобы установить PostgreSQL **15**:
```bash
sudo dnf install -y postgresql15-server postgresql15-contrib
```

---

### **2. Инициализация базы данных**
Перед запуском PostgreSQL нужно выполнить инициализацию:
```bash
sudo /usr/pgsql-15/bin/postgresql-15-setup initdb
```

---

### **3. Запуск и включение автозапуска**
```bash
sudo systemctl enable --now postgresql-15
```

Проверка статуса:
```bash
sudo systemctl status postgresql-15
```

---

### **4. Настройка пароля для пользователя postgres**
```bash
sudo -u postgres psql
```
Внутри консоли PostgreSQL задайте пароль:
```sql
ALTER USER postgres WITH PASSWORD 'новый_пароль';
```
Выйдите из консоли:
```sql
\q
```

---

### **5. Разрешение удалённого доступа (если требуется)**
1. Откройте файл конфигурации:
   ```bash
   sudo vim /var/lib/pgsql/15/data/postgresql.conf
   ```
2. Найдите строку:
   ```
   listen_addresses = 'localhost'
   ```
   И измените на:
   ```
   listen_addresses = '*'
   ```

3. Разрешите подключение в файле **pg_hba.conf**:
   ```bash
   sudo vim /var/lib/pgsql/15/data/pg_hba.conf
   ```
   Добавьте строку (замените `0.0.0.0/0` на нужную сеть):
   ```
   host    all             all             0.0.0.0/0            md5
   ```

4. Перезапустите сервер:
   ```bash
   sudo systemctl restart postgresql-15
   ```

---

### **6. Открытие порта в firewalld (если требуется)**
```bash
sudo firewall-cmd --permanent --add-service=postgresql
sudo firewall-cmd --reload
```

---

Теперь **PostgreSQL** успешно установлен и запущен на AlmaLinux! 🎉  
Можно подключаться через `psql` или внешние клиенты. 🚀