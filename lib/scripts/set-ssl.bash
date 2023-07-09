#!/usr/bin/env bash

set -eo pipefail


current_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

source "${current_dir}/../utils.bash"
source "${current_dir}/../utils-php.bash"

# set +eou  # FOR DDEBUG!!!

get_ssl_version() {
  if [ ! z ${printf $1|grep -i 'SsL'}]; then
    printf $1 | grep -oP -i '(?<=SsL=)(\s+)?\K([^ ]*)'
  fi 
}

get_download_url_ssl() {
  local install_type=$1
  local version=$2
  if [ ${printf $version | cut -c1} >=  3 ]; then
    version="-"$version
  else
    version="_"${printf $version | sed 's+\.+_+g'}
  fi
  # https://github.com/openssl/openssl/archive/refs/tags/OpenSSL_1_1_1u.tar.gz
  # https://www.openssl.org/source/openssl-1.1.1u.tar.gz
  # https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1t/openssl-1.1.1t.tar.gz
  printf "https://github.com/openssl/openssl/archive/refs/tags/OpenSSL"$version".tar.gz"


}

  # https://www.php.net/manual/en/openssl.requirements.php
  # PHP 7.1-8.0 requires OpenSSL >= 1.0.1, < 3.0     :
  # aaa=$(find / -wholename "*\/openssl*\/lib\/pkgconfig")
  # echo $aaa|grep -oP -i '(?<=openssl-)(\s+)?\K([^\/]*)'|sort -r \
  #    |grep "^1\.0\.[1-9]*\|^1\.[1-9]*\|^2\.*"|head -n 1
  # PHP 7.0 requires OpenSSL >= 0.9.8, < 1.2
  # echo $aaa|grep -oP -i '(?<=openssl-)(\s+)?\K([^\/]*)'|sort -r  \
  #    |grep   "^1\.[0-1]\.[1-9]*\|^1\.[0-1]\|^1\.[0-1][^0-9]*\|^0\.9\.[8-9]*"|head -n 1
  # PHP >= 8.1 requires OpenSSL >= 1.0.2, < 4.0
  # echo $aaa|grep -oP -i '(?<=openssl-)(\s+)?\K([^\/]*)'|sort -r  \
  #    |grep   "^1\.0\.[2-9]\|^[2-3]\.[1-9]*\|^1\.0[^.]\|^1\.[1-9]"|head -n 1


# https://www.php.net/manual/en/openssl.requirements.php
 

check_matching_openssl_to_php() {
  local version_php=$1
  #version_php="8.1.2"
  IFS='.' read -a tokens <<<"$1"
  local ver_php_major=${tokens[0]}
  local ver_php_minor=${tokens[1]}
  local ver_php_patch=${tokens[2]}
  local matched_openssl_version_found
  local installed_ssl_packages
  log DEBUG "ver_php_major is [${ver_php_major}]"
  log DEBUG "ver_php_minor is [${ver_php_minor}]"
  log DEBUG "ver_php_patch is [${ver_php_patch}]"

  installed_ssl_packages=$(find / -wholename "*\/openssl*\/lib\/pkgconfig")
  logerr "installed_ssl_packages:\n $installed_ssl_packages"
  log2file "installed_ssl_packages= '$installed_ssl_packages' ..."
  #log ERROR "Install of type [$version_php] not supported"

  if [ "$ver_php_major" -ge 8 ]  && [ "$ver_php_minor" -ge 1 ]; then
    log INFO "PHP >= 8.1 requires OpenSSL >= 1.0.2, < 4.0 "
    matched_openssl_version_found=$(\
      echo "$installed_ssl_packages"|grep -oP -i '(?<=openssl-)(\s+)?\K([^\/]*)'|sort -r  \
      |grep   "^1\.0\.[2-9]\|^[2-3]\.[1-9]*\|^1\.0[^.]\|^1\.[1-9]"|head -n 1)

  elif { [ "$ver_php_major" -eq 8 ] && [ "$ver_php_minor" -eq 0 ]; } || \
       { [ "$ver_php_major" -eq 7 ] && [ "$ver_php_minor" -ge 1 ]; }; then
    log INFO "PHP 7.1-8.0 requires OpenSSL >= 1.0.1, < 3.0"
    matched_openssl_version_found=$(\
    echo "$installed_ssl_packages"|grep -oP -i '(?<=openssl-)(\s+)?\K([^\/]*)'|sort -r \
    |grep "^1\.0\.[1-9]*\|^1\.[1-9]*\|^2\.*"|head -n 1)
 
   elif { [ "$ver_php_major" -eq 7 ] && [ "$ver_php_minor" -eq 0 ]; } || \
        [ "$ver_php_major" -lt 7 ] ; then
      log INFO "PHP 7.0 requires OpenSSL >= 0.9.8, < 1.2"  
      matched_openssl_version_found=$(\
      echo "$installed_ssl_packages"|grep -oP -i '(?<=openssl-)(\s+)?\K([^\/]*)'|sort -r  \
      |grep   "^1\.[0-1]\.[1-9]*\|^1\.[0-1]\|^1\.[0-1][^0-9]*\|^0\.9\.[8-9]*"|head -n 1)
  else 
    log WARN "Unknown PHP version: %s" "$version_php"
  fi
  log DEBUG "matched_openssl_version_found is [${matched_openssl_version_found}]"

  local matched_openssl_package_found=''
  if [ -n "$matched_openssl_version_found" ]; then
    matched_openssl_package_found=$(printf $installed_ssl_packages| grep "$matched_openssl_version_found")
  fi 
  echo "$matched_openssl_package_found"
  log DEBUG "matched_openssl_package_found is [${matched_openssl_package_found}]"
}


get_download_file_path_ssl() {
  local install_type=$1
  local version=$2
  local tmp_download_dir=$3
  local ssl_version=$(get_ssl_version $version)
  local pkg_name="openssl-${ssl_version}.tar.gz"

  echo "$tmp_download_dir/$pkg_name"
}

download_source_ssl() {
  local install_type=$1
  local version=$2
  local download_path=$3
  local download_url=$(get_download_url_ssl $install_type $version)

  # curl -Lo $download_path -C - $download_url
  curl -Lo $download_path $download_url
}

untar_path_ssl() {
  local install_type=$1
  local version=$2
  local tmp_download_dir=$3

  local ssl_version=$(get_ssl_version $version)

  local dir_name="ssl-src-ssl-${ssl_version}"

  echo "$tmp_download_dir/$dir_name"
}

os_based_configure_options_ssl() {
  local operating_system=$(uname -a)
  local configure_options=""

  BUILD_PLATFORM=`uname -m`
  #echo $(uname)-$(uname -m)
  if [[ $operating_system =~ "Darwin" ]]; then
    configure_options= "zlib enable-tlsext"
    # possible extra options are:
    #   " enable-ec enable-camellia enable-seed enable-rc5 enable-rc2 enable-rc4 enable-idea"
    configure_options= "$(configure_options)  darwin64-$(BUILD_PLATFORM)-cc"
  else
    configure_options= "$(uname)-$(BUILD_PLATFORM)"
  fi

  echo $configure_options >> openssl_build.log 2>&1
  echo $configure_options
}

construct_configure_options_ssl() {
  local install_path=$1

  # many options included below are not applicable to newer SSL versions
  # these will trigger a build warning 
  global_config="--prefix=$install_path \
   -fPIC \
   -shared"

  if [ "$SSL_CONFIGURE_OPTIONS" = "" ]; then
    local configure_options="$(os_based_configure_options_ssl) $global_config"
  else
    local configure_options="$SSL_CONFIGURE_OPTIONS $global_config"
  fi

  echo "$configure_options"
}

install_ssl() {
  local install_type=$1
  local version=$2
  local install_path=$3

  if [ "$TMPDIR" = "" ]; then
    local tmp_download_dir=$(mktemp -d)
  else
    local tmp_download_dir=${TMPDIR%/}
  fi

  echo "Determining SSL configuration options..."
  local source_path=$(get_download_file_path_ssl $install_type $version $tmp_download_dir)
  local configure_options="$(construct_configure_options_ssl $install_path)"
  local make_flags="-j$ASDF_CONCURRENCY"

  local operating_system=$(uname -a)

  if [[ $operating_system =~ "Darwin" ]]; then
    exit_if_homebrew_not_installed

    local openssl_path=$(homebrew_package_path openssl@1.1)

    if [ -n "$openssl_path" ]; then
      export "PKG_CONFIG_PATH=${openssl_path}/lib/pkgconfig:${PKG_CONFIG_PATH}"
    else
      export ASDF_PKG_MISSING="$ASDF_PKG_MISSING openssl"
    fi
  fi

  echo "Downloading source code..."
  download_source $install_type $version $source_path

  # Running this in a subshell because we don't to disturb the current
  # working directory.
  (
    echo "Extracting source code..."
    cd $(dirname $source_path)
    tar -zxf $source_path || exit 1

    cd $(untar_path_ssl $install_type $version $tmp_download_dir)

    # Target is OS-specific
    # target=$(get_target)

    # Build SSL
    make clean >> openssl_build.log 2>&1 
    echo "Running buildconfig..."
    ./buildconf --force || exit 1
    echo "Running ./configure $configure_options"
    ./configure $configure_options >> openssl_build.log 2>&1 || exit 1
    echo "Running make \"$make_flags\""
    make "$make_flags" >> openssl_build.log 2>&1  || exit 1
    echo "Running make install..."
    # make "$make_flags" test || exit 1
    make "$make_flags" install >> openssl_build.log 2>&1  || exit 1
  )

  # it's not obvious where openssl.cnf  should be placed, let us make it easy for the user
  # see https://www.openssl.org/docs/man1.1.1/man5/config.html
   mkdir -p $install_path/config/
   echo "# add system-wide ssl configuration options here" >$install_path/config/openssl.cnf
}
