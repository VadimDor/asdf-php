#!/usr/bin/env bash

set -euo pipefail

TOOL_NAME="1password-cli"
TOOL_TEST="op --version"
TOOL_GPG_KEY="3FEF9748469ADBE15DA7CA80AC2D62742012EA22"

ASDF_PHP_MY_NAME=asdf-php

# 0: (default) Copy venvs with explicit python version, symlink otherwise.
# 1: Prefer copies.
ASDF_PHP_VENV_COPY_MODE=${ASDF_PHP_VENV_COPY_MODE:-0}

ASDF_PHP_RESOLVED_PYTHON_PATH=

if [[ ${ASDF_PHP_DEBUG:-} -eq 1 ]]; then
  # In debug mode, dump everything to a log file
  # got a little help from https://askubuntu.com/a/1345538/985855

  ASDF_PHP_DEBUG_LOG_PATH="/tmp/${ASDF_PHP_MY_NAME}-debug.log"
  mkdir -p "$(dirname "$ASDF_PHP_DEBUG_LOG_PATH")"

  printf "\n\n-------- %s ----------\n\n" "$(date)" >>"$ASDF_PHP_DEBUG_LOG_PATH"

  exec > >(tee -ia "$ASDF_PHP_DEBUG_LOG_PATH")
  exec 2> >(tee -ia "$ASDF_PHP_DEBUG_LOG_PATH" >&2)

  exec 19>>"$ASDF_PHP_DEBUG_LOG_PATH"
  export BASH_XTRACEFD=19
  set -x
fi

fail() {
  echo >&2 -e "${ASDF_PHP_MY_NAME}: [ERROR] $*"
  exit 1
}

log2file() {
  if [[ ${ASDF_PHP_DEBUG:-} -eq 1 ]]; then
    echo >&2 -e "${ASDF_PHP_MY_NAME}: $*"
  fi
}

function echoerr {
  (>&2 echo "${1}")
}

function logerr {
  echoerr "=== (php) ===> ${1}"
}

# warning: it writes to stdout , that may break functions returning strings
function loginfo {
  echo -e "=== (php) ===> ${1}" 
}

# Borrowed here https://github.com/looztra/asdf-terraform-docs/blob/master/bin/install
# who himself borrowed to someone, but  don't remember who it was and is sorry for that :(
# Print message $2 with log-level $1 to STDERR, colorized if terminal
# log DEBUG "DOCKER_HOST ${DOCKER_HOST}"
function log() {
  local level=${1?}
  shift
  local code
  local line
  code=''
  line="[$(date '+%F %T')] $level: $*"
  if [ -t 2 ]; then
    case "$level" in
    INFO) code=36 ;;
    DEBUG) code=35 ;;
    WARN) code=33 ;;
    ERROR) code=31 ;;
    *) code=37 ;;
    esac
    echo -e "\e[${code}m${line} \e[94m(${FUNCNAME[1]})\e[0m"
  else
    echo "$line"
  fi >&2
}


curl_opts=(-fsSL)

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_all_versions() {
  cat \
    <(curl -s https://app-updates.agilebits.com/product_history/CLI |
      sed -n '/<h3/{n;p;}' |
      sed 's/[[:space:]]//g') \
    <(curl -s https://app-updates.agilebits.com/product_history/CLI2 |
      sed -n '/<h3/{n;p;}' |
      sed 's/[[:space:]]//g')
}

download_release() {
  local version filename url
  version="$1"
  filename="$2"
  platform=$(get_platform)
  arch=$(get_arch)
  ext="zip"
  filter_platform=$platform

  case $platform in
    darwin)
      ext="pkg"
      filter_platform="apple\|darwin"
      arch="${arch}\|universal"
      ;;
  esac

  if [[ "$version" =~ ^1\..*$ ]]; then
    url=$(curl -s https://app-updates.agilebits.com/product_history/CLI | grep "${version}" | grep "${filter_platform}" | grep "${arch}" | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | sed '/^[[:space:]]*$/d' | grep -o "https.*$")
  elif [[ "$version" =~ ^2\..*$ ]]; then
    url=$(curl -s https://app-updates.agilebits.com/product_history/CLI2 | grep "${version}\/" | grep "${filter_platform}" | grep "${arch}" | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | sed '/^[[:space:]]*$/d' | grep -o "https.*$")
  fi
  echo "* Downloading $TOOL_NAME release $version..."
  curl "${curl_opts[@]}" -o "$filename.${ext}" -C - "$url" || fail "Could not download $url"
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="$3"

  if [ "$install_type" != "version" ]; then
    fail "asdf-$TOOL_NAME supports release installs only"
  fi

  (
    platform=$(get_platform)
    mkdir -p "$install_path/bin"
    case $platform in
      darwin)
        ext="pkg"
        pkgutil --expand "${ASDF_DOWNLOAD_PATH}/${TOOL_NAME}-${ASDF_INSTALL_VERSION}.${ext}" "${ASDF_DOWNLOAD_PATH}/extracted/"
        pushd "$install_path/bin"
        cpio -i -F "${ASDF_DOWNLOAD_PATH}/extracted/op.${ext}/Payload" 2>/dev/null
        popd
        ;;
      *)
        cp -R "$ASDF_DOWNLOAD_PATH/." "$install_path/bin"
        is_exists=$(program_exists)
        echo $is_exists
        if [ "$is_exists" != 0 ]; then
          gpg --keyserver hkps://keyserver.ubuntu.com:443 --receive-keys "$TOOL_GPG_KEY"
          gpg --verify "$install_path/bin/op.sig" "$install_path/bin/op" || fail "asdf-$TOOL_NAME download file verify fail with GPG."
        fi
        ;;
    esac

    local tool_cmd
    tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
    test -x "$install_path/bin/$tool_cmd" || fail "Expected $install_path/bin/$tool_cmd to be executable."

    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error ocurred while installing $TOOL_NAME $version."
  )
}

get_arch() {
  local arch=""

  case "$(uname -m)" in
    x86_64 | amd64) arch="amd64" ;;
    i686 | i386) arch="386" ;;
    armv6l | armv7l) arch="arm" ;;
    aarch64 | arm64) arch="arm64" ;;
    *)
      fail "Arch '$(uname -m)' not supported!"
      ;;
  esac

  echo -n $arch
}

get_platform() {
  local platform=""

  case "$(uname | tr '[:upper:]' '[:lower:]')" in
    darwin) platform="darwin" ;;
    freebsd) platform="freebsd" ;;
    linux) platform="linux" ;;
    openbsd) platform="openbsd" ;;
    windows) platform="windows" ;;
    *)
      fail "Platform '$(uname -m)' not supported!"
      ;;
  esac

  echo -n $platform
}

program_exists() {
  local ret='0'
  command -v gpg gpg2 >/dev/null 2>&1 || { local ret='1'; }

  if [ "$ret" -ne 0 ]; then
    return 1
  fi

  return 0
}
