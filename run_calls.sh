#!/bin/bash

# Параметры запуска sipP
REMOTE_IP=${REMOTE_IP:-"192.168.1.1"}  # IP адрес сервера
REMOTE_PORT=${REMOTE_PORT:-"5060"}     # Порт на удалённом сервере
LOCAL_IP=${LOCAL_IP:-"192.168.1.2"}    # IP адрес клиента
LOCAL_PORT=${LOCAL_PORT:-"5060"}       # Порт на клиенте
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
