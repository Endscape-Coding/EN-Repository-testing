#!/bin/bash

set -e

# Настраиваем кэширование учетных данных (если еще не настроено)
if ! git config --global credential.helper > /dev/null; then
    echo "Настраиваем кэширование git учетных данных..."
    git config --global credential.helper 'cache --timeout=86400'
fi

# Переходим в папку repo
echo "Переходим в папку repo..."
cd ./repo || { echo "Ошибка: папка repo не существует"; exit 1; }

# 1. Добавляем пакеты в репозиторий
echo "Добавляем пакеты в репозиторий..."
repo-add enrepo-testing.db.tar.gz *.pkg.tar.zst

# 2. Заменяем симлинки на копии архивов
echo "Обновляем файлы репозитория..."

# Удаляем старые файлы и копируем архивы
if [ -f "enrepo-testing.db.tar.gz" ]; then
    rm -f enrepo-testing.db
    cp enrepo-testing.db.tar.gz enrepo-testing.db
    echo "✓ Обновлен enrepo-testing.db"
else
    echo "⚠ Файл enrepo-testing.db.tar.gz не найден"
fi

if [ -f "enrepo-testing.files.tar.gz" ]; then
    rm -f enrepo-testing.files
    cp enrepo-testing.files.tar.gz enrepo-testing.files
    echo "✓ Обновлен enrepo-testing.files"
else
    echo "⚠ Файл enrepo-testing.files.tar.gz не найден"
fi

# Возвращаемся на уровень выше
cd ..


# 6. Добавляем все файлы в git
echo "Добавляем файлы в git..."
git add .

# 7. Запрашиваем сообщение коммита у пользователя
echo "Введите сообщение коммита:"
read commit_message

# Проверяем, что сообщение не пустое
if [ -z "$commit_message" ]; then
    echo "Сообщение коммита не может быть пустым!"
    exit 1
fi

# 8. Создаем коммит
echo "Создаем коммит..."
git commit -m "$commit_message"

# 9. Пушим изменения
echo "Отправляем изменения в удаленный репозиторий..."
git push

echo "✅ Все операции завершены успешно!"
