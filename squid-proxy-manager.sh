#!/usr/bin/env bash
# https://github.com/complexorganizations/squid-proxy-manager

# Require script to be run as root
function super-user-check() {
  if [ "${EUID}" -ne 0 ]; then
    echo "Error: You need to run this script as administrator."
    exit
  fi
}

# Check for root
super-user-check

# Get the current system information
function system-information() {
  if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    CURRENT_DISTRO=${ID}
    CURRENT_DISTRO_VERSION=${VERSION_ID}
    CURRENT_KERNEL_VERSION=$(uname -r | cut -d'.' -f1-2)
  fi
}

# Get the current system information
system-information

# Pre-Checks system requirements
function installing-system-requirements() {
  if { [ "${CURRENT_DISTRO}" == "ubuntu" ] || [ "${CURRENT_DISTRO}" == "debian" ] || [ "${CURRENT_DISTRO}" == "raspbian" ] || [ "${CURRENT_DISTRO}" == "pop" ] || [ "${CURRENT_DISTRO}" == "kali" ] || [ "${CURRENT_DISTRO}" == "linuxmint" ] || [ "${CURRENT_DISTRO}" == "neon" ] || [ "${CURRENT_DISTRO}" == "fedora" ] || [ "${CURRENT_DISTRO}" == "centos" ] || [ "${CURRENT_DISTRO}" == "rhel" ] || [ "${CURRENT_DISTRO}" == "almalinux" ] || [ "${CURRENT_DISTRO}" == "rocky" ] || [ "${CURRENT_DISTRO}" == "arch" ] || [ "${CURRENT_DISTRO}" == "archarm" ] || [ "${CURRENT_DISTRO}" == "manjaro" ] || [ "${CURRENT_DISTRO}" == "alpine" ] || [ "${CURRENT_DISTRO}" == "freebsd" ]; }; then
    if { [ ! -x "$(command -v curl)" ] || [ ! -x "$(command -v cut)" ] || [ ! -x "$(command -v jq)" ] || [ ! -x "$(command -v ip)" ] || [ ! -x "$(command -v lsof)" ] || [ ! -x "$(command -v cron)" ] || [ ! -x "$(command -v awk)" ] || [ ! -x "$(command -v pgrep)" ] || [ ! -x "$(command -v grep)" ] || [ ! -x "$(command -v qrencode)" ] || [ ! -x "$(command -v sed)" ] || [ ! -x "$(command -v zip)" ] || [ ! -x "$(command -v unzip)" ] || [ ! -x "$(command -v openssl)" ] || [ ! -x "$(command -v iptables)" ] || [ ! -x "$(command -v bc)" ] || [ ! -x "$(command -v gpg)" ]; }; then
      if { [ "${CURRENT_DISTRO}" == "ubuntu" ] || [ "${CURRENT_DISTRO}" == "debian" ] || [ "${CURRENT_DISTRO}" == "raspbian" ] || [ "${CURRENT_DISTRO}" == "pop" ] || [ "${CURRENT_DISTRO}" == "kali" ] || [ "${CURRENT_DISTRO}" == "linuxmint" ] || [ "${CURRENT_DISTRO}" == "neon" ]; }; then
        apt-get update
        apt-get install curl coreutils jq iproute2 lsof cron gawk procps grep qrencode sed zip unzip openssl iptables bc gnupg -y
      elif { [ "${CURRENT_DISTRO}" == "fedora" ] || [ "${CURRENT_DISTRO}" == "centos" ] || [ "${CURRENT_DISTRO}" == "rhel" ] || [ "${CURRENT_DISTRO}" == "almalinux" ] || [ "${CURRENT_DISTRO}" == "rocky" ]; }; then
        yum update -y
        yum install epel-release elrepo-release -y
        yum install curl coreutils jq iproute lsof cronie gawk procps-ng grep qrencode sed zip unzip openssl iptables bc gnupg -y
      elif { [ "${CURRENT_DISTRO}" == "arch" ] || [ "${CURRENT_DISTRO}" == "archarm" ] || [ "${CURRENT_DISTRO}" == "manjaro" ]; }; then
        pacman -Syu --noconfirm --needed curl coreutils jq iproute2 lsof cronie gawk procps-ng grep qrencode sed zip unzip openssl iptables bc gnupg
      elif [ "${CURRENT_DISTRO}" == "alpine" ]; then
        apk update
        apk add curl coreutils jq iproute2 lsof cronie gawk procps grep qrencode sed zip unzip openssl iptables bc gnupg
      elif [ "${CURRENT_DISTRO}" == "freebsd" ]; then
        pkg update
        pkg install curl coreutils jq iproute2 lsof cronie gawk procps grep qrencode sed zip unzip openssl iptables bc gnupg 
      fi
    fi
  else
    echo "Error: ${CURRENT_DISTRO} ${CURRENT_DISTRO_VERSION} is not supported."
    exit
  fi
}

# Run the function and check for requirements
installing-system-requirements

# Global variables
SQUID_PROXY_DIRECTORY="/etc/squid"
SQUID_CONFIG_PATH="${SQUID_PROXY_DIRECTORY}/squid.conf"
SQUID_EXTERNAL_CONFIG_DIRECTORY="${SQUID_PROXY_DIRECTORY}/conf.d"
SQUID_BLOCKED_DOMAIN_PATH="${SQUID_EXTERNAL_CONFIG_DIRECTORY}/blocked-domains.acl"
SQUID_USERS_DATABASE="${SQUID_PROXY_DIRECTORY}/users"
case $(shuf -i1-4 -n1) in
1)
  SQUID_BLOCKED_DOMAIN_URL="https://raw.githubusercontent.com/complexorganizations/content-blocker/main/assets/hosts"
  ;;
2)
  SQUID_BLOCKED_DOMAIN_URL="https://cdn.statically.io/gh/complexorganizations/content-blocker/main/assets/hosts"
  ;;
3)
  SQUID_BLOCKED_DOMAIN_URL="https://cdn.jsdelivr.net/gh/complexorganizations/content-blocker/assets/hosts"
  ;;
4)
  SQUID_BLOCKED_DOMAIN_URL="https://combinatronics.io/complexorganizations/content-blocker/main/assets/hosts"
  ;;
esac

# Check if the squid proxy is installed
if [ ! -f "${SQUID_CONFIG_PATH}" ]; then

  # Choose the proxy port
  function choose-proxy-port() {
    echo "What port do you want Squid Proxy server to listen to?"
    echo "  1) 3128 (Recommended)"
    echo "  2) Custom (Advanced)"
    until [[ "${SERVER_PORT_SETTINGS}" =~ ^[1-2]$ ]]; do
      read -rp "Port Choice [1-2]:" -e -i 1 SERVER_PORT_SETTINGS
    done
    case ${SERVER_PORT_SETTINGS} in
    1)
      SERVER_PORT="3128"
      if [ "$(lsof -i UDP:"${SERVER_PORT}")" ]; then
        echo "Error: Please use a different port because ${SERVER_PORT} is already in use."
      fi
      ;;
    2)
      until [[ "${SERVER_PORT}" =~ ^[0-9]+$ ]] && [ "${SERVER_PORT}" -ge 1 ] && [ "${SERVER_PORT}" -le 65535 ]; do
        read -rp "Custom port [1-65535]:" SERVER_PORT
      done
      if [ "$(lsof -i UDP:"${SERVER_PORT}")" ]; then
        echo "Error: The port ${SERVER_PORT} is already used by a different application, please use a different port."
      fi
      ;;
    esac
  }

  choose-proxy-port

  # Get the IPv4
  function test-connectivity-v4() {
    echo "How would you like to detect IPv4?"
    echo "  1) Curl (Recommended)"
    echo "  2) Custom (Advanced)"
    until [[ "${SERVER_HOST_V4_SETTINGS}" =~ ^[1-2]$ ]]; do
      read -rp "IPv4 Choice [1-2]:" -e -i 1 SERVER_HOST_V4_SETTINGS
    done
    case ${SERVER_HOST_V4_SETTINGS} in
    1)
      SERVER_HOST_V4="$(curl -4 --connect-timeout 5.00 -s 'https://api.ipengine.dev' | jq -r '.network.ip')"
      if [ -z "${SERVER_HOST_V4}" ]; then
        SERVER_HOST_V4="$(curl -4 --connect-timeout 5.00 -s 'https://checkip.amazonaws.com')"
      fi
      ;;
    2)
      read -rp "Custom IPv4:" SERVER_HOST_V4
      if [ -z "${SERVER_HOST_V4}" ]; then
        SERVER_HOST_V4="$(curl -4 --connect-timeout 5.00 -s 'https://api.ipengine.dev' | jq -r '.network.ip')"
      fi
      if [ -z "${SERVER_HOST_V4}" ]; then
        SERVER_HOST_V4="$(curl -4 --connect-timeout 5.00 -s 'https://checkip.amazonaws.com')"
      fi
      ;;
    esac
  }

  # Get the IPv4
  test-connectivity-v4

  # Determine IPv6
  function test-connectivity-v6() {
    echo "How would you like to detect IPv6?"
    echo "  1) Curl (Recommended)"
    echo "  2) Custom (Advanced)"
    until [[ "${SERVER_HOST_V6_SETTINGS}" =~ ^[1-2]$ ]]; do
      read -rp "IPv6 Choice [1-2]:" -e -i 1 SERVER_HOST_V6_SETTINGS
    done
    case ${SERVER_HOST_V6_SETTINGS} in
    1)
      SERVER_HOST_V6="$(curl -6 --connect-timeout 5.00 -s 'https://api.ipengine.dev' | jq -r '.network.ip')"
      if [ -z "${SERVER_HOST_V6}" ]; then
        SERVER_HOST_V6="$(curl -6 --connect-timeout 5.00 -s 'https://checkip.amazonaws.com')"
      fi
      ;;
    2)
      read -rp "Custom IPv6:" SERVER_HOST_V6
      if [ -z "${SERVER_HOST_V6}" ]; then
        SERVER_HOST_V6="$(curl -6 --connect-timeout 5.00 -s 'https://api.ipengine.dev' | jq -r '.network.ip')"
      fi
      if [ -z "${SERVER_HOST_V6}" ]; then
        SERVER_HOST_V6="$(curl -6 --connect-timeout 5.00 -s 'https://checkip.amazonaws.com')"
      fi
      ;;
    esac
  }

  # Get the IPv6
  test-connectivity-v6

  function block-trackers-and-ads() {
    echo "Do you want to block trackers and ads?"
    echo "  1) Yes (Recommended)"
    echo "  2) No"
    until [[ "${BLOCK_TRACKERS_AND_ADS_SETTINGS}" =~ ^[1-2]$ ]]; do
      read -rp "Block trackers and ads [1-2]:" -e -i 1 BLOCK_TRACKERS_AND_ADS_SETTINGS
    done
    case ${BLOCK_TRACKERS_AND_ADS_SETTINGS} in
    1)
      BLOCK_TRACKERS_AND_ADS=true
      ;;
    2)
      BLOCK_TRACKERS_AND_ADS=false
      ;;
    esac
  }

  function install-squid-proxy() {
    if [ ! -x "$(command -v squid)" ]; then
      if { [ "${CURRENT_DISTRO}" == "ubuntu" ] || [ "${CURRENT_DISTRO}" == "debian" ] || [ "${CURRENT_DISTRO}" == "raspbian" ] || [ "${CURRENT_DISTRO}" == "pop" ] || [ "${CURRENT_DISTRO}" == "kali" ] || [ "${CURRENT_DISTRO}" == "linuxmint" ] || [ "${CURRENT_DISTRO}" == "neon" ]; }; then
        apt-get install squid -y
      elif { [ "${CURRENT_DISTRO}" == "fedora" ] || [ "${CURRENT_DISTRO}" == "centos" ] || [ "${CURRENT_DISTRO}" == "rhel" ] || [ "${CURRENT_DISTRO}" == "almalinux" ] || [ "${CURRENT_DISTRO}" == "rocky" ]; }; then
        yum install squid -y
      elif [ "${CURRENT_DISTRO}" == "arch" ] || [ "${CURRENT_DISTRO}" == "archarm" ] || [ "${CURRENT_DISTRO}" == "manjaro" ]; then
        pacman -S --noconfirm --needed squid
      elif [ "${CURRENT_DISTRO}" == "alpine" ]; then
        apk add squid
      elif [ "${CURRENT_DISTRO}" == "freebsd" ]; then
        pkg install squid
      fi
    fi
  }

  function configure-squid-proxy() {
    echo "via off
forwarded_for delete
follow_x_forwarded_for deny all
access_log none
cache_store_log none
cache_log /dev/null
http_access allow all
auth_param basic program /usr/local/squid/bin/ncsa_auth ${SQUID_USERS_DATABASE}
acl squid_users proxy_auth REQUIRED
http_access allow squid_users" >${SQUID_CONFIG_PATH}
    if [ "${BLOCK_TRACKERS_AND_ADS}" == true ]; then
      echo "acl blocked_url dstdomain ${SQUID_BLOCKED_DOMAIN_PATH}
http_access deny blocked_url" >>${SQUID_CONFIG_PATH}
      curl "${SQUID_BLOCKED_DOMAIN_URL}" | awk '$1' | awk '{print "."$1""}' >${SQUID_BLOCKED_DOMAIN_PATH}
    fi
  }

else

  function configure-after-installation() {
    echo "What do you want to do?"
    echo "1) Start Squid Proxy"
    echo "2) Stop Squid Proxy"
    echo "3) Restart Squid Proxy"
    echo "4) Add a user to squid proxy"
    echo "5) Remove a user from squid proxy"
    echo "6) Reinstall Squid"
    echo "7) Uninstall Squid"
    echo "8) Update this script"
    echo "9) Backup Squid"
    echo "10) Restore Squid"
    echo "11) Update Interface Port"
    echo "12) Purge Squid Users"
    echo "13) Generate QR Code"
    until [[ "${SQUID_OPTIONS}" =~ ^[0-9]+$ ]] && [ "${SQUID_OPTIONS}" -ge 1 ] && [ "${SQUID_OPTIONS}" -le 13 ]; do
      read -rp "Select an Option [1-14]:" -e -i 0 SQUID_OPTIONS
    done
    case ${SQUID_OPTIONS} in
    1) # Start Squid
      if [ -x "$(command -v service)" ]; then
        service squid restart
      elif [ -x "$(command -v systemctl)" ]; then
        systemctl enable squid
        systemctl restart squid
      fi
      ;;
    2) # Stop Squid
      if [ -x "$(command -v service)" ]; then
        service squid stop
      elif [ -x "$(command -v systemctl)" ]; then
        systemctl stop squid
      fi
      ;;
    3) # Restart Squid
      if [ -x "$(command -v service)" ]; then
        service squid restart
      elif [ -x "$(command -v systemctl)" ]; then
        systemctl restart squid
      fi
      ;;
    4) # Add a squid user
      SQUID_USERNAME="$(openssl rand -hex 25)"
      SQUID_PASSWORD="$(openssl rand -hex 25)"
      echo "${SQUID_USERNAME}:$(openssl passwd -crypt "${SQUID_PASSWORD}")" >>${SQUID_USERS_DATABASE}
      echo "http://${SERVER_HOST}:${SERVER_PORT}/${SQUID_USERNAME}:${SQUID_PASSWORD}"
      ;;
    5) # Remove a user
      awk -F ':' '{print $1}' ${SQUID_USERS_DATABASE}
      ;;
    6) # Reinstall squid
      if { [ "${CURRENT_DISTRO}" == "ubuntu" ] || [ "${CURRENT_DISTRO}" == "debian" ] || [ "${CURRENT_DISTRO}" == "raspbian" ] || [ "${CURRENT_DISTRO}" == "pop" ] || [ "${CURRENT_DISTRO}" == "kali" ] || [ "${CURRENT_DISTRO}" == "linuxmint" ] || [ "${CURRENT_DISTRO}" == "neon" ]; }; then
        apt-get --reinstall install squid -y
      elif { [ "${CURRENT_DISTRO}" == "fedora" ] || [ "${CURRENT_DISTRO}" == "centos" ] || [ "${CURRENT_DISTRO}" == "rhel" ] || [ "${CURRENT_DISTRO}" == "almalinux" ] || [ "${CURRENT_DISTRO}" == "rocky" ]; }; then
        yum reinstall squid -y
      elif [ "${CURRENT_DISTRO}" == "arch" ] || [ "${CURRENT_DISTRO}" == "archarm" ] || [ "${CURRENT_DISTRO}" == "manjaro" ]; then
        pacman -S --noconfirm squid
      elif [ "${CURRENT_DISTRO}" == "alpine" ]; then
        apk fix squid
      elif [ "${CURRENT_DISTRO}" == "freebsd" ]; then
        pkg check squid
      fi
      ;;
    7) # Uninstall squid
      if { [ "${CURRENT_DISTRO}" == "ubuntu" ] || [ "${CURRENT_DISTRO}" == "debian" ] || [ "${CURRENT_DISTRO}" == "raspbian" ] || [ "${CURRENT_DISTRO}" == "pop" ] || [ "${CURRENT_DISTRO}" == "kali" ] || [ "${CURRENT_DISTRO}" == "linuxmint" ] || [ "${CURRENT_DISTRO}" == "neon" ]; }; then
        apt-get remove squid -y
      elif { [ "${CURRENT_DISTRO}" == "fedora" ] || [ "${CURRENT_DISTRO}" == "centos" ] || [ "${CURRENT_DISTRO}" == "rhel" ] || [ "${CURRENT_DISTRO}" == "almalinux" ] || [ "${CURRENT_DISTRO}" == "rocky" ]; }; then
        yum remove squid -y
      elif [ "${CURRENT_DISTRO}" == "arch" ] || [ "${CURRENT_DISTRO}" == "archarm" ] || [ "${CURRENT_DISTRO}" == "manjaro" ]; then
        pacman -Rs --noconfirm squid
      elif [ "${CURRENT_DISTRO}" == "alpine" ]; then
        apk del squid
      elif [ "${CURRENT_DISTRO}" == "freebsd" ]; then
        pkg delete squid
      fi
      if [ -d "${SQUID_PROXY_DIRECTORY}" ]; then
        rm -rf "${SQUID_PROXY_DIRECTORY}"
      fi
      ;;
    8)
      curl "${WIREGUARD_MANAGER_UPDATE}" -o "${CURRENT_FILE_PATH}"
      chmod +x "${CURRENT_FILE_PATH}"
      ;;
    9)
      if [ -d "${SQUID_PROXY_DIRECTORY}" ]; then
        tar -czf "${SQUID_PROXY_DIRECTORY}.tar.gz" "${SQUID_PROXY_DIRECTORY}"
      fi
      ;;
    10)
      if [ -d "${SQUID_PROXY_DIRECTORY}" ]; then
        rm -rf "${SQUID_PROXY_DIRECTORY}"
      fi
      if [ -f "${SQUID_PROXY_DIRECTORY}.tar.gz" ]; then
        tar -xzf "${SQUID_PROXY_DIRECTORY}.tar.gz"
      fi
      ;;
    11)
      sed -i "s|current_port|new_port|g" ${SQUID_CONFIG_PATH}
      ;;
    12)
      echo "" >${SQUID_USERS_DATABASE}
      ;;
    13)
      echo "Generate QR Code"
      ;;
    esac
  }

fi
