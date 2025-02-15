#!/bin/bash

# Проверка обязательных переменных окружения
for var in REMOTE_IP LOCAL_IP; do
  if [ -z "${!var}" ]; then
    echo "Ошибка: переменная окружения $var не задана."
    exit 1
  fi
done

# Параметры запуска SIPp
REMOTE_PORT=${REMOTE_PORT:-"5060"}     # Порт на удалённом сервере
LOCAL_PORT=${LOCAL_PORT:-"5060"}       # Порт на клиенте
CALL_COUNT=${CALL_COUNT:-30}           # Количество вызовов
CALL_INTERVAL=${CALL_INTERVAL:-30}     # Интервал между вызовами (секунды)
MIN_DURATION=${MIN_DURATION:-2}        # Минимальная длительность вызова (минуты)
MAX_DURATION=${MAX_DURATION:-6}        # Максимальная длительность вызова (минуты)

# Преобразуем минуты в миллисекунды
MIN_DURATION_MS=$((MIN_DURATION * 60 * 1000))
MAX_DURATION_MS=$((MAX_DURATION * 60 * 1000))

# Диапазон времени для генерирования продолжительности звонков
RANGE=$((MAX_DURATION_MS - MIN_DURATION_MS))

# Создаем копию оригинального scenario.xml
cp scenario.xml scenario_template.xml

for ((i=1; i<=CALL_COUNT; i++))
do
  # Генерация случайной длительности вызова
  CALL_DURATION=$(( (RANDOM % RANGE) + MIN_DURATION_MS ))

  # Восстанавливаем оригинальный scenario.xml из копии
  cp scenario_template.xml scenario.xml

  # Заменяем плейсхолдеры в scenario.xml
  sed -i "s/\[REMOTE_IP\]/$REMOTE_IP/g" scenario.xml
  sed -i "s/\[REMOTE_PORT\]/$REMOTE_PORT/g" scenario.xml
  sed -i "s/\[LOCAL_IP\]/$LOCAL_IP/g" scenario.xml
  sed -i "s/\[LOCAL_PORT\]/$LOCAL_PORT/g" scenario.xml
  sed -i "s/\[call_duration\]/$CALL_DURATION/g" scenario.xml

  # Запускаем SIPp с указанными параметрами
  sipp -sf scenario.xml -i $LOCAL_IP -p $LOCAL_PORT -m 1 -d $CALL_DURATION $REMOTE_IP:$REMOTE_PORT

  # Пауза между вызовами
  if [ $i -lt $CALL_COUNT ]; then
    sleep $CALL_INTERVAL
  fi
done

# Удаляем временный файл
rm scenario_template.xml
