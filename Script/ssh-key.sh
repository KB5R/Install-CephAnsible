#!/bin/bash


SERVERS=(
  "10.0.0.0"
  
)

PASSWORD="pass"


SSH_KEY="$HOME/.ssh/id_rsa.pub"


if [[ ! -f "$SSH_KEY" ]]; then
  echo "SSH ключ не найден в $SSH_KEY. Сначала сгенерируй ключ с помощью ssh-keygen."
  exit 1
fi


for SERVER in "${SERVERS[@]}"; do
  echo "Копирование SSH ключа на $SERVER..."
  
  # Использование sshpass для ввода пароля
  sshpass -p "$PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no root@$SERVER
done

echo "SSH ключ успешно скопирован на все сервера."
