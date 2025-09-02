## Задание предварительное zabbix

1. На хосте **gw**. Создайте ssh-ключ c именем id_lab (тип ed_25519) для пользователя student. Файл должен называться `/home/student/.ssh/id_lab`

2. Скопируйте содержимое `/home/student/.ssh/id_lab.pub` в файл `/home/devops/.ssh/authorized_keys` 

3. Разместите публичную часть созданного ключа на хостах **ws**, **infra**, **proxy**, **server**, **db**, **gw** в учетной записи пользователя student для подключения без пароля.

4. На хосте gw. Внесите изменения в файл `/etc/hosts`, добавьте следующие строки:

```ini
10.0.10.220 ws
10.0.10.100 infra
10.0.10.50 proxy
10.0.20.10 server
10.0.20.3 db
10.0.20.1 gw
```

5. На хосте gw. Установите пакет `https://repo.zabbix.com/zabbix/7.0/rhel/9/x86_64/zabbix-release-latest-7.0.el9.noarch.rpm`

6. На хосте **gw**. Добавьте правило для firewalld, разрешающее входящие пакеты 80/tcp

7. На хосте **gw**. Установите сервис httpd и добавьте его в автозагрузку 

8. На хосте **gw**. Скопируйте из журнала `/var/log/messages` все строки, принадлежащие сервису httpd в файл `/home/student/check/httpd.otchet`
