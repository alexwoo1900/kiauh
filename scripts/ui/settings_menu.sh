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
      local delay=$(ping -c 4 -W 1 $domain | awk -F '/' 'END{if ($5 == "") {printf "\033[31mx Unreachable\033[37m"} else {printf "\033[32m~ "$5"ms\033[37m"}}')
      echo "$PIP_INDEX_URL $delay"
    else
      echo "$PIP_INDEX_URL"
    fi
    
  else
    echo "Illegal pip index url"
  fi
}

function settings_ui() {
  read_kiauh_ini "${FUNCNAME[0]}"

  local custom_repo="${custom_klipper_repo}"
  local custom_branch="${custom_klipper_repo_branch}"
  local ms_pre_rls="${mainsail_install_unstable}"
  local fl_pre_rls="${fluidd_install_unstable}"
  local bbu="${backup_before_update}"

  ### custom repository
  custom_repo=$(echo "${custom_repo}" | sed "s/https:\/\/github\.com\///" | sed "s/\.git$//" )
  if [[ -z ${custom_repo} ]]; then
    custom_repo="${cyan}Klipper3D/klipper${white}"
  else
    custom_repo="${cyan}${custom_repo}${white}"
  fi

  ### custom repository branch
  if [[ -z ${custom_branch} ]]; then
    custom_branch="${cyan}master${white}"
  else
    custom_branch="${cyan}${custom_branch}${white}"
  fi

  ### webinterface stable toggle
  if [[ ${ms_pre_rls} == "false" ]]; then
    ms_pre_rls="${red}● ${ms_pre_rls}${white}"
  else
    ms_pre_rls="${green}● ${ms_pre_rls}${white}"
  fi

  if [[ ${fl_pre_rls} == "false" ]]; then
    fl_pre_rls="${red}● ${fl_pre_rls}${white}"
  else
    fl_pre_rls="${green}● ${fl_pre_rls}${white}"
  fi

  ### backup before update toggle
  if [[ "${bbu}" == "false" ]]; then
    bbu="${red}● ${bbu}${white}"
  else
    bbu="${green}● ${bbu}${white}"
  fi

  top_border
  echo -e "|     $(title_msg "~~~~~~~~~~~~ [ KIAUH Settings ] ~~~~~~~~~~~~~")     |"
  hr
  echo -e "|                                                       |"
  echo -e "| Offline:                                              |"
  echo -e "|   ● root:                                             |"
  printf "|     %-60s|\n" "${cyan}${OFFLINE_DIR}${white}"
  echo -e "|     1) [Reset]                                        |"
  echo -e "|                                                       |"
  hr
  echo -e "|                                                       |"
  echo -e "| pip:                                                  |"
  echo -e "|   ● index:                                            |"
  printf "|     %-50s|\n" "$([[ -f "/etc/pip.conf" ]] && printf $(grep -E "^extra-index-url=" "/etc/pip.conf" | sed "s/extra-index-url=//")" (from pip.conf)" || printf "empty")"
  if [[ $TEST_PIP_INDEX_URL == "false" ]]; then
    printf "|     %-60s|\n" "${cyan}$(process_pip_index_url)${white}"
    printf "|     %-50s|\n" "2) [Test On]"
  else
    printf "|     %-70s|\n" "${cyan}$(process_pip_index_url)${white}"
    printf "|     %-50s|\n" "2) [Test Off]" 
  fi
  echo -e "|     3) [Reset]                                        |"
  echo -e "|                                                       |"
  hr
  echo -e "|                                                       |"
  echo -e "| Klipper:                                              |"
  echo -e "|   ● Repository:                                       |"
  printf  "|     %-70s|\n" "${custom_repo} (${custom_branch})"
  echo -e "|     4) [Reset]                                        |"
  echo -e "|                                                       |"
  hr
  echo -e "|                                                       |"
  echo -e "| Fluidd:                                               |"
  echo -e "|   ● release:                                          |"
  if [[ ${fl_pre_rls} == "false" ]]; then
    printf  "|     %-70s|\n" "Disallow unstable version"
    echo -e "|     5) [Allow]                                        |"
  else
    printf  "|     %-70s|\n" "Allow unstable version"
    echo -e "|     5) [Disallow]                                     |"
  fi
  echo -e "|                                                       |"
  hr
  echo -e "|                                                       |"
  echo -e "| Mainsail:                                             |"
  echo -e "|   ● release:                                          |"
  if [[ ${ms_pre_rls} == "false" ]]; then
    printf  "|     %-70s|\n" "Disallow unstable version"
    echo -e "|     6) [Allow]                                        |"
  else
    printf  "|     %-70s|\n" "Allow unstable version"
    echo -e "|     6) [Disallow]                                     |"
  fi
  echo -e "|                                                       |"
  hr
  echo -e "|                                                       |"
  printf  "| Backup before updating: %-42s|\n" "${bbu}"
  echo -e "|                                                       |"
  hr
  blank_line
  if [[ ${backup_before_update} == "false" ]]; then
  echo -e "| 7) ${green}Enable${white} automatic backups before updates            |"
  else
  echo -e "| 7) ${red}Disable${white} automatic backups before updates           |"
  fi
  back_help_footer
}

function show_settings_help() {
  local default_cfg="${cyan}${HOME}/klipper_config${white}"

  top_border
  echo -e "|    ~~~~~~ < ? > Help: KIAUH Settings < ? > ~~~~~~     |"
  hr
  echo -e "| ${cyan}Install unstable releases:${white}                            |"
  echo -e "| If set to ${green}true${white}, KIAUH installs/updates the software   |"
  echo -e "| with the latest, currently available release.         |"
  echo -e "| ${yellow}This will include alpha, beta and rc releases!${white}        |"
  blank_line
  echo -e "| If set to ${red}false${white}, KIAUH installs/updates the software  |"
  echo -e "| with the most recent stable release.                  |"
  blank_line
  echo -e "| Default: ${red}false${white}                                        |"
  blank_line
  hr
  echo -e "| ${cyan}Backup before updating:${white}                               |"
  echo -e "| If set to true, KIAUH will automatically create a     |"
  echo -e "| backup from the corresponding component you are about |"
  echo -e "| to update before actually updating it, preserving the |"
  echo -e "| current state of the component in a safe location.    |"
  echo -e "| All backups are stored in '~/kiauh_backups'.          |"
  blank_line
  echo -e "| Default: ${red}false${white}                                        |"
  blank_line
  back_footer

  local choice
  while true; do
    read -p "${cyan}###### Please select:${white} " choice
    case "${choice}" in
      B|b)
        clear && print_header
        settings_menu
        break;;
      *)
        deny_action "show_settings_help";;
    esac
  done
}

function settings_menu() {
  clear && print_header
  settings_ui

  local action
  while true; do
    read -p "${cyan}####### Perform action:${white} " action
    case "${action}" in
      1)
        clear && print_header
	      set_offline_dir
        settings_ui;;
      2)
        clear && print_header
	      toggle_pip_index_url_test
        settings_ui;;
      3)
        clear && print_header
	      set_pip_index_url
        settings_ui;;
      4)
        clear && print_header
        change_klipper_repo_menu
        settings_ui;;
      5)
        switch_mainsail_releasetype
        settings_menu;;
      6)
        switch_fluidd_releasetype
        settings_menu;;
      7)
        toggle_backup_before_update
        settings_menu;;
      B|b)
        clear
        main_menu
        break;;
      H|h)
        clear && print_header
        show_settings_help
        break;;
      *)
        deny_action "settings_ui";;
    esac
  done
}
