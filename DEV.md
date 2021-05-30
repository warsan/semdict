# Develop and Quck Start Guide


Сначала нужно установить переменную
 `.env` from `.env.example`

```bash
# запустить сразу после начала работы

make setup

# Запускать каждый раз, когда изменяются перемещения?

make up

# запустить локальный сервер (вне docker) для разработки
# make run-local

# запуск сервера в docker infra
# команду для перезапуска сервера после изменений
make run-docker

# запустить один раз при настройке SSL для домена
make initial-setup-ssl
# Должен быть `Exit 0` для контейнера certbot - означает, что сертификат был успешно установлен
#
# MacBook-Pro-George:semdict gebv$ docker-compose ps | grep certbot
# certbot               certbot certonly --webroot ...   Exit 0
# MacBook-Pro-George:semdict gebv$

# запуск обратного прокси с настроенным ssl
make run-proxy
```


Просмотр логов:

docker logs -f semdict-server

Подключение к postgresq нужно делать через докер, но я делаю его прямо в локальной машине, 
```
psql -h localhost -p 5432 -U semdict sduser_db
```
