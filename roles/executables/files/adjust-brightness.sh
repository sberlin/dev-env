#!/bin/bash

BLIGHT_PATH=$(find /sys -type d -name intel_backlight 2> /dev/null)

MAX_BRIGHTNESS=$(cat $BLIGHT_PATH/max_brightness)

echo "${MAX_BRIGHTNESS}*$(fswebcam --png -1 - | convert - -colorspace gray -format "%[fx:mean]" info:)"  | \
  bc -l | \
  sed 's/^\./1./' | \
  cut -d '.' -f 1 | \
  sudo tee "${BLIGHT_PATH}/brightness"

