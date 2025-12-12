# Docker Setup для Laravel проекта

## Быстрый старт

### 1. Создайте файл .env

```bash
cp .env.example .env
```

Отредактируйте `.env` и установите следующие переменные:

```env
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=password

REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379

CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis
```

### 2. Запустите контейнеры

Для разработки (с hot-reload для фронтенда):
```bash
docker-compose -f docker-compose.dev.yml up -d
```

Для production:
```bash
docker-compose up -d
```

### 3. Установите зависимости и настройте приложение

```bash
# Войдите в контейнер приложения
docker-compose exec app bash

# Или выполните команды напрямую
docker-compose exec app composer install
docker-compose exec app php artisan key:generate
docker-compose exec app php artisan migrate
docker-compose exec app php artisan storage:link
```

### 4. Установите npm зависимости и соберите фронтенд

```bash
# Если используете docker-compose.dev.yml, Node контейнер уже запущен
# Иначе:
docker-compose exec app npm install
docker-compose exec app npm run build
```

## Доступ к приложению

- **Веб-приложение**: http://localhost:8080
- **MySQL**: localhost:3306
- **Redis**: localhost:6379
- **Vite Dev Server** (только dev): http://localhost:5173

## Полезные команды

### Просмотр логов
```bash
docker-compose logs -f app
docker-compose logs -f nginx
docker-compose logs -f mysql
```

### Выполнение Artisan команд
```bash
docker-compose exec app php artisan migrate
docker-compose exec app php artisan tinker
docker-compose exec app php artisan queue:work
```

### Выполнение Composer команд
```bash
docker-compose exec app composer install
docker-compose exec app composer update
```

### Выполнение npm команд
```bash
docker-compose exec app npm install
docker-compose exec app npm run build
docker-compose exec app npm run dev
```

### Остановка контейнеров
```bash
docker-compose down
```

### Остановка с удалением volumes (удалит данные БД!)
```bash
docker-compose down -v
```

### Пересборка контейнеров
```bash
docker-compose build --no-cache
docker-compose up -d
```

## Структура сервисов

### app (PHP-FPM)
- PHP 8.4 с необходимыми расширениями
- Composer установлен
- Node.js 20 для сборки фронтенда
- Рабочая директория: `/var/www/html`

### nginx
- Веб-сервер
- Проксирует запросы к PHP-FPM
- Порт: `8080`

### mysql
- MySQL 8.0
- Порт: `3306`
- База данных: `laravel`
- Пользователь: `laravel` / Пароль: `password`
- Root пароль: `root`

### redis
- Redis 7 для кеширования и очередей
- Порт: `6379`

### node (только dev)
- Node.js 20 для разработки фронтенда
- Запускает Vite dev server
- Порт: `5173`

## Настройка прав доступа

Если возникают проблемы с правами доступа:

```bash
docker-compose exec app chown -R www-data:www-data /var/www/html/storage
docker-compose exec app chown -R www-data:www-data /var/www/html/bootstrap/cache
docker-compose exec app chmod -R 775 /var/www/html/storage
docker-compose exec app chmod -R 775 /var/www/html/bootstrap/cache
```

## Troubleshooting

### Проблема: Permission denied
```bash
docker-compose exec app chmod -R 775 storage bootstrap/cache
```

### Проблема: База данных не подключается
- Проверьте, что контейнер MySQL запущен: `docker-compose ps`
- Проверьте переменные окружения в `.env`
- Убедитесь, что `DB_HOST=mysql` (имя сервиса в docker-compose)

### Проблема: Composer не найден
- Пересоберите контейнер: `docker-compose build --no-cache app`

### Проблема: npm команды не работают
- Убедитесь, что Node.js установлен в контейнере (проверьте Dockerfile)
- Или используйте отдельный контейнер `node` из `docker-compose.dev.yml`

### Очистка кеша Laravel
```bash
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan route:clear
docker-compose exec app php artisan view:clear
```

## Production настройки

Для production рекомендуется:

1. Использовать отдельный Dockerfile для production
2. Настроить правильные переменные окружения
3. Использовать SSL/TLS сертификаты
4. Настроить бэкапы базы данных
5. Использовать volumes для persistent storage
6. Настроить мониторинг и логирование

## Интеграция с CI/CD

Docker образы можно использовать в GitHub Actions для тестирования:

```yaml
- name: Run tests in Docker
  run: |
    docker-compose -f docker-compose.test.yml up -d
    docker-compose exec -T app php artisan test
```

