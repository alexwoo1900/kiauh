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

TEST_GITHUB_BASE="false"
TEST_PIP_INDEX_URL="false"

function toggle_github_base_test() {
  if [[ $TEST_GITHUB_BASE == "false" ]]; then
    TEST_GITHUB_BASE="true"
  else
    TEST_GITHUB_BASE="false"
  fi
}

function get_github_base() {
  local github_base=$(git config --get-regexp "^url\.https:\/\/github\.com\/" | awk '{print $2}')
  if [[ -n $github_base ]]; then
    echo $github_base
  else
    echo "https://github.com"
  fi
}

function set_github_base() {
  while true; do
    read -p "Enter a github base url (https://gitclone.com/github.com/): " url

    if [[ $url =~ ^(http|https)://.*$ ]]; then
      git config --global url."https://github.com/".insteadOf $url
      break
    else
      echo "No available github base!"
      break
    fi
  done
}

function process_github_base() {
  local github_base=$(get_github_base)
  local domain=$(echo $github_base | sed -E -e 's_.*://([^/@]*@)?([^/:]+).*_\2_')
  if [[ $TEST_GITHUB_BASE == "true" ]]; then
    local delay=$(ping -c 4 -W 1 $domain | awk -F '/' 'END{if ($5 == "") {printf "\033[31mx Unreachable\033[37m"} else {printf "\033[32m~ "$5"ms\033[37m"}}')
    echo "$github_base $delay"
  else
    echo "$github_base $delay"
  fi
}

function toggle_pip_index_url_test() {
  if [[ $TEST_PIP_INDEX_URL == "false" ]]; then
    TEST_PIP_INDEX_URL="true"
  else
    TEST_PIP_INDEX_URL="false"
  fi
}

function get_pip_index_url() {
  local pip_index_url=$(sudo pip config --global get global.index-url)
  if [[ $pip_index_url != ERROR* ]]; then
    echo $pip_index_url
  else
    echo "https://pypi.org/simple"
  fi
}


function set_pip_index_url() {
  while true; do
    read -p "Enter a new pip index url (https://pypi.tuna.tsinghua.edu.cn/simple): " url

    if [[ $url =~ ^(http|https)://.*$ ]]; then
      sudo pip config --global set global.index-url $url
      break
    else
      echo "Illegal pip index url!"
    fi
  done
}

function process_pip_index_url() {
  local pip_index_url=$(get_pip_index_url)
  local domain=$(echo $pip_index_url | sed -E -e 's_.*://([^/@]*@)?([^/:]+).*_\2_')
  if [[ $domain =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    if [[ $TEST_PIP_INDEX_URL == "true" ]]; then
      local delay=$(ping -c 4 -W 1 $domain | awk -F '/' 'END{if ($5 == "") {printf "\033[31mx Unreachable\033[37m"} else {printf "\033[32m~ "$5"ms\033[37m"}}')
      echo "$pip_index_url $delay"
    else
      echo "$pip_index_url"
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
  echo -e "| Source:                                               |"
  echo -e "|   ● Offline root:                                     |"
  printf "|     %-60s|\n" "${cyan}${OFFLINE_DIR}${white}"
  echo -e "|     1) <Reset>                                        |"
  echo -e "|                                                       |"
  echo -e "|   ● Github base:                                      |"
  if [[ $TEST_GITHUB_BASE == "false" ]]; then
    printf "|     %-60s|\n" "${cyan}$(process_github_base)${white}"
    printf "|     %-50s|\n" "2) <Test On>"
  else
    printf "|     %-70s|\n" "${cyan}$(process_github_base)${white}"
    printf "|     %-50s|\n" "2) <Test Off>" 
  fi
  echo -e "|     3) <Reset>                                        |"
  echo -e "|                                                       |"
  echo -e "|   ● pip index:                                        |"
  if [[ $TEST_PIP_INDEX_URL == "false" ]]; then
    printf "|     %-60s|\n" "${cyan}$(process_pip_index_url)${white}"
    printf "|     %-50s|\n" "4) <Test On>"
  else
    printf "|     %-70s|\n" "${cyan}$(process_pip_index_url)${white}"
    printf "|     %-50s|\n" "4) <Test Off>" 
  fi
  echo -e "|     5) <Reset>                                        |"
  echo -e "|                                                       |"
  hr
  echo -e "|                                                       |"
  echo -e "| Klipper:                                              |"
  echo -e "|   ● Repository:                                       |"
  printf  "|     %-70s|\n" "${custom_repo} (${custom_branch})"
  echo -e "|     6) <Reset>                                        |"
  echo -e "|                                                       |"
  hr
  echo -e "|                                                       |"
  echo -e "| Fluidd:                                               |"
  echo -e "|   ● release:                                          |"
  if [[ ${fluidd_install_unstable} == "false" ]]; then
    printf  "|     %-60s|\n" "${red}Disallow${white} unstable version"
    echo -e "|     7) <Allow>                                        |"
  else
    printf  "|     %-60s|\n" "${green}Allow${white} unstable version"
    echo -e "|     7) <Disallow>                                     |"
  fi
  echo -e "|                                                       |"
  hr
  echo -e "|                                                       |"
  echo -e "| Mainsail:                                             |"
  echo -e "|   ● release:                                          |"
  if [[ ${mainsail_install_unstable} == "false" ]]; then
    printf  "|     %-60s|\n" "${red}Disallow${white} unstable version"
    echo -e "|     8) <Allow>                                        |"
  else
    printf  "|     %-60s|\n" "${green}Allow${white} unstable version"
    echo -e "|     8) <Disallow>                                     |"
  fi
  echo -e "|                                                       |"
  hr
  echo -e "|                                                       |"
  echo -e "| Others:                                               |"
  if [[ ${backup_before_update} == "false" ]]; then
    printf  "|     %-60s|\n" "${red}No backup${white} before update"
    echo -e "|     9) <Do backup>                                    |"
  else
    printf  "|     %-60s|\n" "${green}Backup${white} before update"
    echo -e "|     9) <No backup>                                    |"
  fi
  echo -e "|                                                       |"
  blank_line
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
  clear -x && sudo -v && clear -x # (re)cache sudo credentials so password prompt doesn't bork ui

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
	      toggle_github_base_test
        settings_ui;;
      3)
        clear && print_header
	      set_github_base
        settings_ui;;
      4)
        clear && print_header
	      toggle_pip_index_url_test
        settings_ui;;
      5)
        clear && print_header
	      set_pip_index_url
        settings_ui;;
      6)
        clear && print_header
        change_klipper_repo_menu
        settings_ui;;
      7)
        switch_fluidd_releasetype
        settings_menu;;
      8)
        switch_mainsail_releasetype
        settings_menu;;
      9)
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
