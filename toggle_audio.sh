#!/bin/bash

# 1. Получаем список всех доступных выходов (Sinks) по их именам
SINKS=($(pactl list short sinks | awk '{print $2}'))

# Если устройств меньше двух, переключать нечего
if [ ${#SINKS[@]} -lt 2 ]; then
    notify-send -i dialog-warning "Аудио" "Найдено только одно устройство вывода"
    exit 0
fi

# 2. Определяем текущий Sink по умолчанию
CURRENT_SINK=$(pactl get-default-sink)

# 3. Находим следующий Sink по кругу
NEXT_SINK=${SINKS[0]}
for i in "${!SINKS[@]}"; do
    if [[ "${SINKS[$i]}" == "$CURRENT_SINK" ]]; then
        NEXT_INDEX=$(( (i + 1) % ${#SINKS[@]} ))
        NEXT_SINK=${SINKS[$NEXT_INDEX]}
        break
    fi
done

# 4. Устанавливаем новое устройство по умолчанию
pactl set-default-sink "$NEXT_SINK"

# 5. Переносим все УЖЕ ИГРАЮЩИЕ аудиопотоки на новое устройство
pactl list short sink-inputs | awk '{print $1}' | while read -r stream; do
    pactl move-sink-input "$stream" "$NEXT_SINK"
done

# 6. Получаем понятное (описание) имя устройства для уведомления
DESCRIPTION=$(pactl list sinks | grep -A 20 "Name: $NEXT_SINK" | grep "Description:" | head -n1 | cut -d ':' -f 2- | xargs)

# 7. Отправляем уведомление
notify-send -i audio-speakers -h string:x-canonical-private-synchronous:audio-switch "Аудиовыход изменен" "$DESCRIPTION"
