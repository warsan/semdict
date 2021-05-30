#!/bin/bash

pgconn="postgres://$PG_USERNAME:$PG_PWD@$PG_ADDR/$PG_DB?sslmode=disable"

PSQL=psql
PSQL_ARGS="-h $PG_HOST -d $PG_DB -U $PG_USERNAME -p $PG_PORT -q -A -X"


case "$1" in
  "migrate-pg-new" )
    echo "Postgres выбран"
    echo "Пожалуйста, введите имя нового файла миграции:"
    read name
    echo "Введённое имя: $name"

    migrate create -ext sql -dir ./migrations/postgres -seq $name
  ;;

  "migrate-pg-up" )
    echo
    echo "Перенести postgres"
    echo "Текущая версия:"
    migrate -database $pgconn -path ./migrations/postgres version
    echo "Up:"
    migrate -database $pgconn -path ./migrations/postgres up
    echo "Миграция Postgres ЗАВЕРШЕНА."
  ;;

  * | "--help" )

    if [ "$1" != "--help" ]; then
      echo "Команда '$1' не существует."
      echo
    fi
    echo "Commands:"
    echo "- [migrate-pg-new] - Создание нового файла миграций для Postgres."
    echo "- [migrate-pg-up] - Выполнение обновления миграций для Postgres"
  ;;
esac
