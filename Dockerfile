# Используем базовый образ
FROM ubuntu:22.04

# Копируем скрипт и файл .env в контейнер
COPY backup.sh /
COPY .env /
COPY ssh_key /
COPY ssh_key.pub /

# Создаем общий том для записи вывода работы скрипта
VOLUME /output

# Устанавливаем рабочий каталог
WORKDIR /

# устанавливаем зависимости
RUN apt-get update && apt-get install -y \
    openssh-client \
    git

RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN chmod 600 ssh_key ssh_key.pub

# Выполняем команду при запуске контейнера
CMD ["bash", "backup.sh", "--max-backups", "5"]  # Пример, можно изменить аргументы по умолчанию