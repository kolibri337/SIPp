#!/bin/bash

# Проверка обязательных переменных окружения
if [ -z "$REMOTE_IP" ]; then
  echo "Ошибка: переменная окружения REMOTE_IP не задана."
  exit 1
fi

if [ -z "$LOCAL_IP" ]; then
  echo "Ошибка: переменная окружения LOCAL_IP не задана."
  exit 1
fi

# Параметры запуска sipP
REMOTE_IP=${REMOTE_IP}  # IP адрес сервера
REMOTE_PORT=${REMOTE_PORT:-"5060"}     # Порт на удалённом сервере
CALL_COUNT=${CALL_COUNT:-30}           # Количество вызовов
CALL_INTERVAL=${CALL_INTERVAL:-30}     # Интервал между вызовами (секунды)
# Минимальная и максимальная длительность вызова (минуты)
MIN_DURATION=${MIN_DURATION:-2}  # 2 минуты по умолчанию
MAX_DURATION=${MAX_DURATION:-6}  # 6 минут по умолчанию

# Преобразуем минуты в миллисекунды
MIN_DURATION_MS=$((MIN_DURATION * 60 * 1000))
MAX_DURATION_MS=$((MAX_DURATION * 60 * 1000))

# Диапазон времени для генерирования продолжительности звонков
RANGE=$((MAX_DURATION_MS - MIN_DURATION_MS))

for ((i=1; i<=CALL_COUNT; i++))
do
  # Генерация случайной длительности вызова
  CALL_DURATION=$(( (RANDOM % RANGE) + MIN_DURATION_MS ))

  # Запускаем SIPp с указанными параметрами
  sipp -sf scenario.xml -i $LOCAL_IP -p $LOCAL_PORT -m 1 -d $CALL_DURATION $REMOTE_IP:$REMOTE_PORT

  # Пауза между вызовами
  if [ $i -lt $CALL_COUNT ]; then
    sleep $CALL_INTERVAL
  fi
done
