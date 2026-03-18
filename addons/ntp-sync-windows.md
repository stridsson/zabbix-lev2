В командной строке (cmd от администратора):

```cmd
w32tm /config /manualpeerlist:"pool.ntp.org" /syncfromflags:manual /reliable:YES /update
net stop w32tm && net start w32tm
w32tm /resync
```

Проверить синхронизацию:
```cmd
w32tm /query /status
```
