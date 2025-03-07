sudo blkid|grep LABEL\
| awk -F" " '{print "#",$3,"/" tolower($2),$5,"defaults 0 0"}'\
| sed -e 's/"//g' -e 's/TYPE=//g' -e 's/label=//g'\
 -e '/zram/d' -e 's/\/swap/none swap/g' -e 's/sys//g'


 #!/bin/bash

# Получаем список всех блочных устройств и их метки
sudo blkid | grep LABEL \
| awk -F" " '{print "#", $3, "/", tolower($2), $5, "defaults 0 0"}' \
| sed -e 's/"//g' -e 's/TYPE=//g' -e 's/label=//g' \
 -e '/zram/d' -e 's/\/swap/none swap/g' -e 's/sys//g' \
| while read -r line; do
    # Добавляем каждую строку в /etc/fstab
    echo "$line" | sudo tee -a /etc/fstab > /dev/null
done

echo "Обновление /etc/fstab завершено."