#!/usr/bin/env bash

set -euo pipefail

# Used for coloring text in the script

red_start="\033[31m"
green_start="\033[32m"
yellow_start="\033[1;33m"
blue_start="\033[34m"
color_end="\033[0m"

green_text() {
  text=$1
  echo -e "${green_start}$text${color_end}"
}

blue_text() {
  text=$1
  echo -e "${blue_start}$text${color_end}"
}

red_text() {
  text=$1
  echo -e "${red_start}$text${color_end}"
}

yellow_text() {
  text=$1
  echo -e "${yellow_start}$text${color_end}"
}

# Logging function
LOGNAME="hardener_script.log" # Should be changed by script using this function

logger() {
  text=$1
  echo "$1" >> ${LOGNAME}
}

