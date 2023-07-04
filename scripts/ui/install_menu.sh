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

function install_ui() {
  top_border
  echo -e "|     ${green}~~~~~~~~~~~ [ Installation Menu ] ~~~~~~~~~~~${white}     |"
  hr
  echo -e "|  You need this menu usually only for installing       |"
  echo -e "|  all necessary dependencies for the various           |"
  echo -e "|  functions on a completely fresh system.              |"
  hr
  echo -e "|                                                       |"
  echo -e "| Installation:                                         |"
  echo -e "|  0) [Offline]                                         |"
  printf "|     %-50s|\n" "directory: ${OFFLINE_DIR}"
  echo -e "|                                                       |"
  hr
  echo -e "|                                                       |"
  echo -e "| Mirror & Source:                                      |"
  echo -e "|  1) [Github]                                          |"
  echo -e "|  2) [pip]                                             |"
  printf "|     %-50s|\n" "source: $([[ -z ${PIP_BASE_URL} ]] && printf "default" || printf ${PIP_BASE_URL})"
  printf "|     %-50s|\n" "extra-source: $([[ -f "/etc/pip.conf" ]] && printf $(grep -E "^extra-index-url=" "/etc/pip.conf" | sed "s/extra-index-url=//") || printf "empty")"
  echo -e "|                                                       |"
  hr
  echo -e "|                          |                            |"
  echo -e "| Firmware & API:          | 3rd Party Webinterface:    |"
  echo -e "|  3) [Klipper]            |  8) [OctoPrint]            |"
  echo -e "|  4) [Moonraker]          |                            |"
  echo -e "|                          | Other:                     |"
  echo -e "| Klipper Webinterface:    |  9) [PrettyGCode]          |"
  echo -e "|  5) [Mainsail]           | 10) [Telegram Bot]         |"
  echo -e "|  6) [Fluidd]             | 11) $(obico_install_title) |"
  echo -e "|                          | 12) [OctoEverywhere]       |"
  echo -e "|                          | 13) [Mobileraker]          |"
  echo -e "| Touchscreen GUI:         |                            |"
  echo -e "|  7) [KlipperScreen]      | Webcam Streamer:           |"
  echo -e "|                          | 14) [Crowsnest]            |"
  echo -e "|                          | 15) [MJPG-Streamer]        |"
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
      0)
	do_action "set_offline_dir" "install_ui";;
      2)
	do_action "set_pip_base" "install_ui";;
      3)
        do_action "start_klipper_setup" "install_ui";;
      4)
        do_action "moonraker_setup_dialog" "install_ui";;
      5)
        do_action "install_mainsail" "install_ui";;
      6)
        do_action "install_fluidd" "install_ui";;
      7)
        do_action "install_klipperscreen" "install_ui";;
      8)
        do_action "octoprint_setup_dialog" "install_ui";;
      9)
        do_action "install_pgc_for_klipper" "install_ui";;
      10)
        do_action "telegram_bot_setup_dialog" "install_ui";;
      11)
        do_action "moonraker_obico_setup_dialog" "install_ui";;
      12)
        do_action "octoeverywhere_setup_dialog" "install_ui";;
      13)
        do_action "install_mobileraker" "install_ui";;
      14)
        do_action "install_crowsnest" "install_ui";;
      15)
	do_action "install_mjpg-streamer" "install_ui";;
      B|b)
        clear; main_menu; break;;
      *)
        deny_action "install_ui";;
    esac
  done
  install_menu
}
