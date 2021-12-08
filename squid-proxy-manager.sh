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
    if { [ ! -x "$(command -v curl)" ] || [ ! -x "$(command -v cut)" ] || [ ! -x "$(command -v jq)" ] || [ ! -x "$(command -v ip)" ] || [ ! -x "$(command -v lsof)" ] || [ ! -x "$(command -v cron)" ] || [ ! -x "$(command -v awk)" ] || [ ! -x "$(command -v pgrep)" ] || [ ! -x "$(command -v grep)" ] || [ ! -x "$(command -v qrencode)" ] || [ ! -x "$(command -v sed)" ] || [ ! -x "$(command -v zip)" ] || [ ! -x "$(command -v unzip)" ] || [ ! -x "$(command -v openssl)" ] || [ ! -x "$(command -v iptables)" ] || [ ! -x "$(command -v bc)" ] || [ ! -x "$(command -v ifup)" ] || [ ! -x "$(command -v chattr)" ] || [ ! -x "$(command -v gpg)" ] || [ ! -x "$(command -v systemd-detect-virt)" ]; }; then
      if { [ "${CURRENT_DISTRO}" == "ubuntu" ] || [ "${CURRENT_DISTRO}" == "debian" ] || [ "${CURRENT_DISTRO}" == "raspbian" ] || [ "${CURRENT_DISTRO}" == "pop" ] || [ "${CURRENT_DISTRO}" == "kali" ] || [ "${CURRENT_DISTRO}" == "linuxmint" ] || [ "${CURRENT_DISTRO}" == "neon" ]; }; then
        apt-get update
        apt-get install curl coreutils jq iproute2 lsof cron gawk procps grep qrencode sed zip unzip openssl iptables bc ifupdown e2fsprogs gnupg systemd -y
      elif { [ "${CURRENT_DISTRO}" == "fedora" ] || [ "${CURRENT_DISTRO}" == "centos" ] || [ "${CURRENT_DISTRO}" == "rhel" ] || [ "${CURRENT_DISTRO}" == "almalinux" ] || [ "${CURRENT_DISTRO}" == "rocky" ]; }; then
        yum update -y
        yum install epel-release elrepo-release -y
        yum install curl coreutils jq iproute lsof cronie gawk procps-ng grep qrencode sed zip unzip openssl iptables bc NetworkManager e2fsprogs gnupg systemd -y
      elif { [ "${CURRENT_DISTRO}" == "arch" ] || [ "${CURRENT_DISTRO}" == "archarm" ] || [ "${CURRENT_DISTRO}" == "manjaro" ]; }; then
        pacman -Syu --noconfirm --needed curl coreutils jq iproute2 lsof cronie gawk procps-ng grep qrencode sed zip unzip openssl iptables bc ifupdown e2fsprogs gnupg systemd
      elif [ "${CURRENT_DISTRO}" == "alpine" ]; then
        apk update
        apk add curl coreutils jq iproute2 lsof cronie gawk procps grep qrencode sed zip unzip openssl iptables bc ifupdown e2fsprogs gnupg systemd
      elif [ "${CURRENT_DISTRO}" == "freebsd" ]; then
        pkg update
        pkg install curl coreutils jq iproute2 lsof cronie gawk procps grep qrencode sed zip unzip openssl iptables bc ifupdown e2fsprogs gnupg systemd
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

# Check if the squid proxy is installed
if [ ! -f "${SQUID_CONFIG_PATH}" ]; then

  # Custom IPv4 subnet
  function set-ipv4-subnet() {
    echo "What IPv4 subnet do you want to use?"
    echo "  1) 10.0.0.0/8 (Recommended)"
    echo "  2) Custom (Advanced)"
    until [[ "${IPV4_SUBNET_SETTINGS}" =~ ^[1-2]$ ]]; do
      read -rp "Subnet Choice [1-2]:" -e -i 1 IPV4_SUBNET_SETTINGS
    done
    case ${IPV4_SUBNET_SETTINGS} in
    1)
      IPV4_SUBNET="10.0.0.0/8"
      ;;
    2)
      read -rp "Custom IPv4 Subnet:" IPV4_SUBNET
      if [ -z "${IPV4_SUBNET}" ]; then
        IPV4_SUBNET="10.0.0.0/8"
      fi
      ;;
    esac
  }

  # Custom IPv4 Subnet
  set-ipv4-subnet

  # Custom IPv6 subnet
  function set-ipv6-subnet() {
    echo "What IPv6 subnet do you want to use?"
    echo "  1) fd00:00:00::0/8 (Recommended)"
    echo "  2) Custom (Advanced)"
    until [[ "${IPV6_SUBNET_SETTINGS}" =~ ^[1-2]$ ]]; do
      read -rp "Subnet Choice [1-2]:" -e -i 1 IPV6_SUBNET_SETTINGS
    done
    case ${IPV6_SUBNET_SETTINGS} in
    1)
      IPV6_SUBNET="fd00:00:00::0/8"
      ;;
    2)
      read -rp "Custom IPv6 Subnet:" IPV6_SUBNET
      if [ -z "${IPV6_SUBNET}" ]; then
        IPV6_SUBNET="fd00:00:00::0/8"
      fi
      ;;
    esac
  }

  # Custom IPv6 Subnet
  set-ipv6-subnet

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

fi
