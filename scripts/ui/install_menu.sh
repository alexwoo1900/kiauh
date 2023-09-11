#!/usr/bin/env bash

#=======================================================================#
# Copyright (C) 2020 - 2023 Dominik Willner <th33xitus@gmail.com>       #
#                                                                       #
# This file is part of KIAUH - Klipper Installation And Update Helper   #
# https://github.com/dw-0/kiauh                                         #
#                                                                       #
# This file may be distributed under the terms of the GNU GPLv3 license #
#=======================================================================#

set -e

function install_ui() {
  top_border
  echo -e "|     ${cyan}~~~~~~~~~~ [ Available packages ] ~~~~~~~~~~~${white}     |"
  hr
  echo -e "|                          |                            |"
  echo -e "| Firmware & API:          | 3rd Party Webinterface:    |"
  echo -e "|  1) [Klipper]            |  6) [OctoPrint]            |"
  echo -e "|  2) [Moonraker]          |                            |"
  echo -e "|                          | Webcam Streamer:           |"
  echo -e "| Klipper Webinterface:    |  7) [Crowsnest]            |"
  echo -e "|  3) [Mainsail]           |  8) [MJPG-Streamer]        |"
  echo -e "|  4) [Fluidd]             |                            |"
  echo -e "|                          | Other:                     |"
  echo -e "| Touchscreen GUI:         |  9) [PrettyGCode]          |"
  echo -e "|  5) [KlipperScreen]      | 10) [Telegram Bot]         |"
  echo -e "|                          | 11) $(obico_install_title) |"
  echo -e "|                          | 12) [OctoEverywhere]       |"
  echo -e "|                          | 13) [Mobileraker]          |"
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
        do_action "start_klipper_setup" "install_ui";;
      2)
        do_action "moonraker_setup_dialog" "install_ui";;
      3)
        do_action "install_mainsail" "install_ui";;
      4)
        do_action "install_fluidd" "install_ui";;
      5)
        do_action "install_klipperscreen" "install_ui";;
      6)
        do_action "octoprint_setup_dialog" "install_ui";;
      7)
        do_action "install_crowsnest" "install_ui";;
      8)
	      do_action "install_mjpg-streamer" "install_ui";;
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
      B|b)
        clear; main_menu; break;;
      *)
        deny_action "install_ui";;
    esac
  done
  install_menu
}
