#!/bin/bash

# Kurzes Delay, um sporadische Timeouts zu vermeiden
sleep 5

# Beispiel-Prüfung, ob bitcoind noch läuft
if pgrep bitcoind > /dev/null
then
  exit 0
else
  exit 1
fi
