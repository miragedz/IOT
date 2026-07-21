#!/bin/bash

GPIO_CHIP="gpiochip0"
GPIO_LINE=21
SCRIPT1="/home/pi/gpio/script1.sh"
SCRIPT2="/home/pi/gpio/script2.sh"

DEBOUNCE=0.25
LOCKFILE="/tmp/gpio_switch.lock"

exec 9>"$LOCKFILE"

if ! flock -n 9; then
    echo "Le script est déjà en cours d'exécution."
    exit 1
fi

command -v gpiomon >/dev/null || {
    echo "Erreur : gpiomon n'est pas installé."
    exit 1
}

chmod +x "$SCRIPT1" "$SCRIPT2"

STATE=0
LAST_EVENT=0

echo "En attente des appuis sur le bouton..."

while true
do
    # Attend un front descendant (bouton relié à GND avec pull-up)
    gpiomon --silent --num-events=1 --edges=falling \
        "$GPIO_CHIP" "$GPIO_LINE"

    NOW=$(date +%s.%N)

    # Anti-rebond
    if awk "BEGIN {exit !(($NOW - $LAST_EVENT) < $DEBOUNCE)}"; then
        continue
    fi

    LAST_EVENT=$NOW

    if [ "$STATE" -eq 0 ]; then
        echo "$(date '+%F %T') -> Lancement Script 1"
        "$SCRIPT1"
        STATE=1
    else
        echo "$(date '+%F %T') -> Lancement Script 2"
        "$SCRIPT2"
        STATE=0
    fi
done
