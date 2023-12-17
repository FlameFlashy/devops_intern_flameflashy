# Используем базовый образ с поддержкой Bash
FROM bash

# Копируем скрипт и файл .env в контейнер
COPY backup.sh /
COPY .env /
COPY file_ssh

# Создаем общий том для записи вывода работы скрипта
VOLUME /output

# Устанавливаем рабочий каталог
WORKDIR /

# Выполняем команду при запуске контейнера
CMD ["bash", "backup.sh", "--max-backups", "5"]  # Пример, можно изменить аргументы по умолчанию