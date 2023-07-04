PIP_INSTALL_OPTIONS=""
PIP_BASE_URL=""

function set_pip_base() {
  read -p "Enter a new pip base url like https://sample.com: " url
  if [[ -n $url ]]; then
    PIP_BASE_URL=$url
    PIP_INSTALL_OPTIONS=${PIP_INSTALL_OPTIONS}" -i ${PIP_BASE_URL} "
  fi
}
