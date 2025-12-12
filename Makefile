.PHONY: help build up down restart logs shell test install migrate fresh seed

help: ## Показать эту справку
	@echo "Доступные команды:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Собрать Docker образы
	docker-compose build

up: ## Запустить контейнеры
	docker-compose up -d

up-dev: ## Запустить контейнеры для разработки (с hot-reload)
	docker-compose -f docker-compose.dev.yml up -d

down: ## Остановить контейнеры
	docker-compose down

down-v: ## Остановить контейнеры и удалить volumes
	docker-compose down -v

restart: ## Перезапустить контейнеры
	docker-compose restart

logs: ## Показать логи всех контейнеров
	docker-compose logs -f

logs-app: ## Показать логи приложения
	docker-compose logs -f app

logs-nginx: ## Показать логи nginx
	docker-compose logs -f nginx

logs-mysql: ## Показать логи MySQL
	docker-compose logs -f mysql

shell: ## Войти в контейнер приложения
	docker-compose exec app bash

shell-root: ## Войти в контейнер приложения как root
	docker-compose exec -u root app bash

install: ## Установить зависимости (composer + npm)
	docker-compose exec app composer install
	docker-compose exec app npm install

composer-install: ## Установить PHP зависимости
	docker-compose exec app composer install

composer-update: ## Обновить PHP зависимости
	docker-compose exec app composer update

npm-install: ## Установить npm зависимости
	docker-compose exec app npm install

npm-build: ## Собрать фронтенд
	docker-compose exec app npm run build

npm-dev: ## Запустить dev сервер для фронтенда
	docker-compose exec app npm run dev

key: ## Сгенерировать ключ приложения
	docker-compose exec app php artisan key:generate

migrate: ## Запустить миграции
	docker-compose exec app php artisan migrate

migrate-fresh: ## Пересоздать базу данных и запустить миграции
	docker-compose exec app php artisan migrate:fresh

migrate-seed: ## Запустить миграции с сидерами
	docker-compose exec app php artisan migrate --seed

fresh: ## Пересоздать базу данных с сидерами
	docker-compose exec app php artisan migrate:fresh --seed

seed: ## Запустить сидеры
	docker-compose exec app php artisan db:seed

test: ## Запустить тесты
	docker-compose exec app php artisan test

cache-clear: ## Очистить все кеши
	docker-compose exec app php artisan cache:clear
	docker-compose exec app php artisan config:clear
	docker-compose exec app php artisan route:clear
	docker-compose exec app php artisan view:clear

cache: ## Закешировать конфигурацию
	docker-compose exec app php artisan config:cache
	docker-compose exec app php artisan route:cache
	docker-compose exec app php artisan view:cache

optimize: ## Оптимизировать приложение
	docker-compose exec app php artisan optimize

permissions: ## Установить правильные права доступа
	docker-compose exec app chown -R www-data:www-data /var/www/html/storage
	docker-compose exec app chown -R www-data:www-data /var/www/html/bootstrap/cache
	docker-compose exec app chmod -R 775 /var/www/html/storage
	docker-compose exec app chmod -R 775 /var/www/html/bootstrap/cache

setup: install key migrate permissions ## Первоначальная настройка проекта

ps: ## Показать статус контейнеров
	docker-compose ps

