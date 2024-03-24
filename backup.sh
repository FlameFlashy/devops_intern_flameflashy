#!/bin/bash
# Загрузка переменных окружения из файла .env
# if [ -f .env ]; then
#     source .env
# else
#     echo "Файл .env не найден."
#     exit 1
# fi

# eval $(ssh-agent -s)
# ssh-add ${SSH_FILE}

#задаю переменные
REPO_DIR="repo_dir"
BACKUP_DIR="${HOME}/backup"
MAX_BACKUPS=""
BASE_BACKUP_NAME="devops_internship"
VERSIONS_FILE="${BACKUP_DIR}/versions.json"
DEFAULT_VERSION="1.0.0"
BACKUP_NAME="${BASE_BACKUP_NAME}_${DEFAULT_VERSION}"
CURRENT_VER=""
NEW_VERSION=""
TOTAL_BACKUPS=""
BACKUPS_TO_DELETE=""
FILENAME=""


#клонирую репозиторий через тпм папку
#git clone "${PRIVATE_REPO_SSH_URL}" "${REPO_DIR}" || {
git clone git@github.com:FlameFlashy/devops_intern_flameflashy.git "${REPO_DIR}" || {
    echo "Failed to clone private repo"
    rm -rf ${REPO_DIR}
    echo "Deleted temp repo directory ${REPO_DIR}"
    exit 1
}
#создаю ~/backup, если не создано
if [ ! -e "${BACKUP_DIR}" ]; then
    mkdir -p "${BACKUP_DIR}"
fi
#проверяю создан ли файл json
if [ ! -e "${VERSIONS_FILE}" ]; then
    #создаю первый архив
    tar -czvf "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" "${REPO_DIR}" || {
        echo "Failed to create backup archive"
        exit 1
    }
#создаю первый файл json
    echo "[
            {
            \"version\": \"${DEFAULT_VERSION}\",
            \"date\": \"$(date +'%d.%m.%Y')\",
            \"size\": \"$(stat -c '%s' "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz")\",
            \"filename\": \"${BASE_BACKUP_NAME}_${DEFAULT_VERSION}\"
            }
        ]" >"${VERSIONS_FILE}"
else
    #обновляю версию
    CURRENT_VER=$(jq -r '.[-1].version' "${VERSIONS_FILE}")
    IFS='.' read -ra version_parts <<<"$CURRENT_VER"
    ((version_parts[${#version_parts[@]} - 1]++))
    NEW_VERSION=$(
        IFS='.'
        echo "${version_parts[*]}"
    )

    #создаю новий архив с обновленним именем
    BACKUP_NAME="${BASE_BACKUP_NAME}_${NEW_VERSION}"
    tar -czvf "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" "${REPO_DIR}" || {
        echo "Failed to create backup archive"
        exit 1
    }

    #записываю новые данные в json
    jq --arg version "${NEW_VERSION}" --arg date "$(date +'%d.%m.%Y')" --arg size "$(stat -c %s "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz")" --arg filename "${BACKUP_NAME}" '. += [{"version": $version, "date": $date, "size": $size, "filename": $filename}]' "${VERSIONS_FILE}" >"${VERSIONS_FILE}.tmp" && mv "${VERSIONS_FILE}.tmp" "${VERSIONS_FILE}"
fi

#проверка аргумента max-backups
if [ "${1}" == "--max-backups" ]; then
    if [ -n "${2}" ]; then
        MAX_BACKUPS="${2}"
    fi
# #проверяем и удаляем старые бекапы
    if [ "${MAX_BACKUPS}" -ge 0 ]; then
        TOTAL_BACKUPS=$(find "${BACKUP_DIR}" -type f -name '*.tar.gz' | wc -l)
        if [ "${TOTAL_BACKUPS}" -gt "${MAX_BACKUPS}" ]; then
            BACKUPS_TO_DELETE=$((TOTAL_BACKUPS - MAX_BACKUPS))
            # Находим и удаляем старшие архивы
            files_to_delete=$(find "${BACKUP_DIR}" -type f -name '*.tar.gz' -printf '%T+ %p\n' | sort | head -n $((TOTAL_BACKUPS - MAX_BACKUPS)) | awk '{print $2}')
            rm -rf ${files_to_delete}
            
            ls -ll ${BACKUP_DIR}
        fi
    fi
fi

rm -rf ${REPO_DIR}
echo "Deleted temp repo directory ${REPO_DIR}"
echo "Backup completed successfully"
