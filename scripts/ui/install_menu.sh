#!/usr/bin/env bash

#=======================================================================#
# Copyright (C) 2020 - 2023 Dominik Willner <th33xitus@gmail.com>       #
#                                                                       #
# This file is part of KIAUH - Klipper Installation And Update Helper   #
# https://github.com/th33xitus/kiauh                                    #
#                                                                       #
# This file may be distributed under the terms of the GNU GPLv3 license #
#=======================================================================#

set -e

TEST_PIP_INDEX_URL="false"
PIP_INSTALL_OPTIONS=""
PIP_INDEX_URL=""

function toggle_pip_index_url_test() {
  if [[ $TEST_PIP_INDEX_URL == "false" ]]; then
    TEST_PIP_INDEX_URL="true"
  else
    TEST_PIP_INDEX_URL="false"
  fi
}

function set_pip_index_url() {
  while true; do
    read -p "Enter a new pip index url (https://pypi.org/simple): " url

    if [[ $url =~ ^(http|https)://.*$ ]]; then
      PIP_INDEX_URL=$url
      PIP_INSTALL_OPTIONS=${PIP_INSTALL_OPTIONS}" -i ${PIP_INDEX_URL} "
      break
    else
      echo "Illegal pip index url!"
    fi
  done
}

function process_pip_index_url() {
  if [[ -z $PIP_INDEX_URL ]]; then
    PIP_INDEX_URL="https://pypi.org/simple"
  fi
  local domain=$(echo $PIP_INDEX_URL | sed -E -e 's_.*://([^/@]*@)?([^/:]+).*_\2_')
  if [[ $domain =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    if [[ $TEST_PIP_INDEX_URL == "true" ]]; then
      local delay=$(ping -c 4 -W 1 $domain | awk -F '/' 'END{if ($5 == "") {print "(Unreachable)"} else {print $5"ms"}}')
      echo "$PIP_INDEX_URL $delay"
    else
      echo "$PIP_INDEX_URL"
    fi
  else
    echo "Illegal pip index url"
  fi
}

function install_ui() {
  top_border
  echo -e "|     ${green}~~~~~~~~~ [ Installation Settings ] ~~~~~~~~~${white}     |"
  hr
  echo -e "|                                                       |"
  echo -e "| Offline root:                                         |"
  printf "|     %-50s|\n" "${OFFLINE_DIR}"
  echo -e "|  1) [Reset]                                           |"
  echo -e "|                                                       |"
  hr
  echo -e "|                                                       |"
  echo -e "| pip index:                                            |"
  printf "|     %-50s|\n" "$(process_pip_index_url)"
  printf "|     %-50s|\n" "$([[ -f "/etc/pip.conf" ]] && printf $(grep -E "^extra-index-url=" "/etc/pip.conf" | sed "s/extra-index-url=//")" (extra)" || printf "empty")"
  printf "|  %-53s|\n" "2) [Test $([[ $TEST_PIP_INDEX_URL == "false" ]] && printf "On" || printf "Off")]"
  echo -e "|  3) [Reset]                                           |"
  echo -e "|                                                       |"
  hr
  echo -e "|     ${green}~~~~~~~~~~ [ Available packages ] ~~~~~~~~~~~${white}     |"
  hr
  echo -e "|                          |                            |"
  echo -e "| Firmware & API:          | 3rd Party Webinterface:    |"
  echo -e "|  4) [Klipper]            |  9) [OctoPrint]            |"
  echo -e "|  5) [Moonraker]          |                            |"
  echo -e "|                          | Other:                     |"
  echo -e "| Klipper Webinterface:    | 10) [PrettyGCode]          |"
  echo -e "|  6) [Mainsail]           | 11) [Telegram Bot]         |"
  echo -e "|  7) [Fluidd]             | 12) $(obico_install_title) |"
  echo -e "|                          | 13) [OctoEverywhere]       |"
  echo -e "| Touchscreen GUI:         | 14) [Mobileraker]          |"
  echo -e "|  8) [KlipperScreen]      |                            |"
  echo -e "|                          | Webcam Streamer:           |"
  echo -e "|                          | 15) [Crowsnest]            |"
  echo -e "|                          | 16) [MJPG-Streamer]        |"
  echo -e "|                          |                            |"
  back_footer
}

function set_offline_dir() {
  read -p "Enter a new offline directory: " path
  if [[ -n $path ]]; then
    OFFLINE_DIR=$path
  fi
}

function install_menu() {
  clear -x && sudo -v && clear -x # (re)cache sudo credentials so password prompt doesn't bork ui
  print_header
  install_ui

  ### save all installed webinterface ports to the ini file
  fetch_webui_ports

  ### save all klipper multi-instance names to the ini file
  set_multi_instance_names

  local action
  while true; do
    read -p "${cyan}####### Perform action:${white} " action
    case "${action}" in
      1)
	do_action "set_offline_dir" "install_ui";;
      2)
	do_action "toggle_pip_index_url_test" "install_ui";;
      3)
	do_action "set_pip_index_url" "install_ui";;
      4)
        do_action "start_klipper_setup" "install_ui";;
      5)
        do_action "moonraker_setup_dialog" "install_ui";;
      6)
        do_action "install_mainsail" "install_ui";;
      7)
        do_action "install_fluidd" "install_ui";;
      8)
        do_action "install_klipperscreen" "install_ui";;
      9)
        do_action "octoprint_setup_dialog" "install_ui";;
      10)
        do_action "install_pgc_for_klipper" "install_ui";;
      11)
        do_action "telegram_bot_setup_dialog" "install_ui";;
      12)
        do_action "moonraker_obico_setup_dialog" "install_ui";;
      13)
        do_action "octoeverywhere_setup_dialog" "install_ui";;
      14)
        do_action "install_mobileraker" "install_ui";;
      15)
        do_action "install_crowsnest" "install_ui";;
      16)
	do_action "install_mjpg-streamer" "install_ui";;
      B|b)
        clear; main_menu; break;;
      *)
        deny_action "install_ui";;
    esac
  done
  install_menu
}
