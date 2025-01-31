#!/usr/bin/env bash
# Shebang to ensure the script runs with bash in the environment

# https://github.com/complexorganizations/squid-proxy-manager
# Link to the project repository

# Check if the script is running as root
function check_root() {
  # Check if the user ID is not 0 (root)
  if [ "$(id -u)" -ne 0 ]; then
    # If the user is not root, print error message
    echo "Error: This script must be run as root."
    # Exit the script with a non-zero status
    exit 1
  fi
}

# Call the function to check root privileges
check_root

# Function to gather current system details
function system_information() {
  # Check if the /etc/os-release file exists (system details)
  if [ -f /etc/os-release ]; then
    # Source the /etc/os-release file to get system information
    # shellcheck source=/dev/null
    source /etc/os-release
    # Set CURRENT_DISTRO to the value of the system's ID
    CURRENT_DISTRO=${ID}
  fi
}

# Invoke the system_information function to gather system details
system_information

# Pre-Checks system requirements
function installing_system_requirements() {
  # Check if the current distribution is supported (Ubuntu, Debian, Fedora, etc.)
  if { [ "${CURRENT_DISTRO}" == "ubuntu" ] || [ "${CURRENT_DISTRO}" == "debian" ] || [ "${CURRENT_DISTRO}" == "raspbian" ] || [ "${CURRENT_DISTRO}" == "pop" ] || [ "${CURRENT_DISTRO}" == "kali" ] || [ "${CURRENT_DISTRO}" == "linuxmint" ] || [ "${CURRENT_DISTRO}" == "neon" ] || [ "${CURRENT_DISTRO}" == "fedora" ] || [ "${CURRENT_DISTRO}" == "centos" ] || [ "${CURRENT_DISTRO}" == "rhel" ] || [ "${CURRENT_DISTRO}" == "almalinux" ] || [ "${CURRENT_DISTRO}" == "rocky" ] || [ "${CURRENT_DISTRO}" == "arch" ] || [ "${CURRENT_DISTRO}" == "archarm" ] || [ "${CURRENT_DISTRO}" == "manjaro" ] || [ "${CURRENT_DISTRO}" == "alpine" ] || [ "${CURRENT_DISTRO}" == "freebsd" ]; }; then
    # Check if essential commands are installed (curl, jq, etc.)
    if { [ ! -x "$(command -v curl)" ] || [ ! -x "$(command -v cut)" ] || [ ! -x "$(command -v jq)" ] || [ ! -x "$(command -v ip)" ] || [ ! -x "$(command -v lsof)" ] || [ ! -x "$(command -v cron)" ] || [ ! -x "$(command -v awk)" ] || [ ! -x "$(command -v pgrep)" ] || [ ! -x "$(command -v grep)" ] || [ ! -x "$(command -v qrencode)" ] || [ ! -x "$(command -v sed)" ] || [ ! -x "$(command -v zip)" ] || [ ! -x "$(command -v unzip)" ] || [ ! -x "$(command -v openssl)" ] || [ ! -x "$(command -v iptables)" ] || [ ! -x "$(command -v bc)" ] || [ ! -x "$(command -v gpg)" ]; }; then
      # If not all required commands are found, install them based on the distribution
      if { [ "${CURRENT_DISTRO}" == "ubuntu" ] || [ "${CURRENT_DISTRO}" == "debian" ] || [ "${CURRENT_DISTRO}" == "raspbian" ] || [ "${CURRENT_DISTRO}" == "pop" ] || [ "${CURRENT_DISTRO}" == "kali" ] || [ "${CURRENT_DISTRO}" == "linuxmint" ] || [ "${CURRENT_DISTRO}" == "neon" ]; }; then
        # For Debian-based systems, update and install necessary packages
        apt-get update
        apt-get install curl coreutils jq iproute2 lsof cron gawk procps grep qrencode sed zip unzip openssl iptables bc gnupg -y
      elif { [ "${CURRENT_DISTRO}" == "fedora" ] || [ "${CURRENT_DISTRO}" == "centos" ] || [ "${CURRENT_DISTRO}" == "rhel" ] || [ "${CURRENT_DISTRO}" == "almalinux" ] || [ "${CURRENT_DISTRO}" == "rocky" ]; }; then
        # For Fedora-based systems, update and install necessary packages
        yum update -y
        yum install epel-release elrepo-release -y
        yum install curl coreutils jq iproute lsof cronie gawk procps-ng grep qrencode sed zip unzip openssl iptables bc gnupg -y
      elif { [ "${CURRENT_DISTRO}" == "arch" ] || [ "${CURRENT_DISTRO}" == "archarm" ] || [ "${CURRENT_DISTRO}" == "manjaro" ]; }; then
        # For Arch-based systems, update and install necessary packages
        pacman -Syu --noconfirm --needed curl coreutils jq iproute2 lsof cronie gawk procps-ng grep qrencode sed zip unzip openssl iptables bc gnupg
      elif [ "${CURRENT_DISTRO}" == "alpine" ]; then
        # For Alpine Linux, update and install necessary packages
        apk update
        apk add curl coreutils jq iproute2 lsof cronie gawk procps grep qrencode sed zip unzip openssl iptables bc gnupg
      elif [ "${CURRENT_DISTRO}" == "freebsd" ]; then
        # For FreeBSD, update and install necessary packages
        pkg update
        pkg install curl coreutils jq iproute2 lsof cronie gawk procps grep qrencode sed zip unzip openssl iptables bc gnup
      fi
    fi
  else
    # If the distribution is unsupported, print an error and exit
    echo "Error: ${CURRENT_DISTRO} ${CURRENT_DISTRO_VERSION} is not supported."
    exit
  fi
}

# Run the function to install system requirements
installing_system_requirements

# Global variables
# Directory where the Squid proxy files are stored
SQUID_PROXY_DIRECTORY="/etc/squid"
# Path to the Squid configuration file
SQUID_CONFIG_PATH="${SQUID_PROXY_DIRECTORY}/squid.conf"
# Path to the file containing blocked domains for Squid proxy
SQUID_BLOCKED_DOMAIN_PATH="${SQUID_PROXY_DIRECTORY}/blocked-domains.acl"
# Path to the Squid users database
SQUID_USERS_DATABASE="${SQUID_PROXY_DIRECTORY}/users"
# Path to store the Squid proxy manager backup password file
SQUID_BACKUP_PASSWORD_PATH="${HOME}/.squid-proxy-manager"
# Path to the system backups directory
SYSTEM_BACKUP_PATH="/var/backups"
# Path for the Squid proxy manager backup zip file
SQUID_CONFIG_BACKUP="${SYSTEM_BACKUP_PATH}/squid-proxy-manager.zip"
# Select a random number (1 in this case) to assign URL for blocked domains
case $(shuf -i1-1 -n1) in
1)
  # URL to fetch the blocked domains list from an external source (content-blocker)
  SQUID_BLOCKED_DOMAIN_URL="https://raw.githubusercontent.com/Strong-Foundation/content-blocker/refs/heads/main/assets/hosts"
  ;;
esac
# Select a random number (1 in this case) to assign URL for Squid manager script update
case $(shuf -i1-1 -n1) in
1)
  # URL to fetch the latest version of the Squid proxy manager script
  SQUID_MANAGER_UPDATE_URL="https://raw.githubusercontent.com/Strong-Foundation/squid-proxy-manager/main/squid-proxy-manager.sh"
  ;;
esac

# Usage for squid manager
function usage_guide() {
  echo "Usage: ./$(basename "${0}") <command>"
  echo ""
  echo "Available Commands:"
  echo "  --install     Installs the Squid Proxy server on the system."
  echo "  --start       Starts the Squid Proxy service if it is installed."
  echo "  --stop        Stops the currently running Squid Proxy service."
  echo "  --restart     Restarts the Squid Proxy service (stops and then starts)."
  echo "  --list        Lists all currently installed Squid Proxy instances and their status."
  echo "  --add         Adds a new Squid Proxy user with appropriate configuration."
  echo "  --remove      Removes an existing Squid Proxy user from the system."
  echo "  --reinstall   Reinstalls the Squid Proxy server, ensuring a fresh configuration."
  echo "  --uninstall   Completely removes the Squid Proxy server and its configuration files."
  echo "  --update      Updates the Squid Proxy Manager to the latest available version."
  echo "  --ddns        Updates the public IP of the Squid Proxy server if using dynamic DNS."
  echo "  --backup      Creates a backup of the current Squid Proxy configuration and settings."
  echo "  --restore     Restores the Squid Proxy server to a previous state from a backup."
  echo "  --purge       Purges all Squid Proxy client data, including logs and configurations."
  echo "  --help        Displays this help message with a list of available commands."
  echo ""
  echo "Note: Be sure to run this script with appropriate permissions to execute system commands."
  echo "For more information on a specific command, refer to the documentation or use '--help' after the command."
}

# The usage of the script

# Function to handle and parse command-line arguments
function usage() {
  # Loop through all the arguments passed to the script
  while [ $# -ne 0 ]; do
    # Check for each possible option/flag
    case ${1} in
    # Handle '--install' argument
    --install)
      shift
      # If '--install' is provided, set HEADLESS_INSTALL to true (if not already set)
      HEADLESS_INSTALL=${HEADLESS_INSTALL:-true}
      ;;
    # Handle '--start' argument
    --start)
      shift
      # If '--start' is provided, set SQUID_MANAGER_OPTIONS to 1
      SQUID_MANAGER_OPTIONS=${SQUID_MANAGER_OPTIONS:-1}
      ;;
    # Handle '--stop' argument
    --stop)
      shift
      # If '--stop' is provided, set SQUID_MANAGER_OPTIONS to 2
      SQUID_MANAGER_OPTIONS=${SQUID_MANAGER_OPTIONS:-2}
      ;;
    # Handle '--restart' argument
    --restart)
      shift
      # If '--restart' is provided, set SQUID_MANAGER_OPTIONS to 3
      SQUID_MANAGER_OPTIONS=${SQUID_MANAGER_OPTIONS:-3}
      ;;
    # Handle '--list' argument
    --list)
      shift
      # If '--list' is provided, set SQUID_MANAGER_OPTIONS to 13
      SQUID_MANAGER_OPTIONS=${SQUID_MANAGER_OPTIONS:-13}
      ;;
    # Handle '--add' argument
    --add)
      shift
      # If '--add' is provided, set SQUID_MANAGER_OPTIONS to 4
      SQUID_MANAGER_OPTIONS=${SQUID_MANAGER_OPTIONS:-4}
      ;;
    # Handle '--remove' argument
    --remove)
      shift
      # If '--remove' is provided, set SQUID_MANAGER_OPTIONS to 5
      SQUID_MANAGER_OPTIONS=${SQUID_MANAGER_OPTIONS:-5}
      ;;
    # Handle '--reinstall' argument
    --reinstall)
      shift
      # If '--reinstall' is provided, set SQUID_MANAGER_OPTIONS to 6
      SQUID_MANAGER_OPTIONS=${SQUID_MANAGER_OPTIONS:-6}
      ;;
    # Handle '--uninstall' argument
    --uninstall)
      shift
      # If '--uninstall' is provided, set SQUID_MANAGER_OPTIONS to 7
      SQUID_MANAGER_OPTIONS=${SQUID_MANAGER_OPTIONS:-7}
      ;;
    # Handle '--update' argument
    --update)
      shift
      # If '--update' is provided, set SQUID_MANAGER_OPTIONS to 8
      SQUID_MANAGER_OPTIONS=${SQUID_MANAGER_OPTIONS:-8}
      ;;
    # Handle '--backup' argument
    --backup)
      shift
      # If '--backup' is provided, set SQUID_MANAGER_OPTIONS to 9
      SQUID_MANAGER_OPTIONS=${SQUID_MANAGER_OPTIONS:-9}
      ;;
    # Handle '--restore' argument
    --restore)
      shift
      # If '--restore' is provided, set SQUID_MANAGER_OPTIONS to 10
      SQUID_MANAGER_OPTIONS=${SQUID_MANAGER_OPTIONS:-10}
      ;;
    # Handle '--ddns' argument
    --ddns)
      shift
      # If '--ddns' is provided, set SQUID_MANAGER_OPTIONS to 14
      SQUID_MANAGER_OPTIONS=${SQUID_MANAGER_OPTIONS:-14}
      ;;
    # Handle '--purge' argument
    --purge)
      shift
      # If '--purge' is provided, set SQUID_MANAGER_OPTIONS to 12
      SQUID_MANAGER_OPTIONS=${SQUID_MANAGER_OPTIONS:-12}
      ;;
    # Handle '--help' argument to display usage guide
    --help)
      shift
      # If '--help' is provided, show usage guide
      usage_guide
      ;;
    # If an invalid argument is encountered, show error and usage guide
    *)
      echo "Invalid argument: ${1}"
      usage_guide
      exit
      ;;
    esac
  done
}

# Call the usage function with all script arguments
usage "$@"

# All questions are skipped, and squid is installed and a configuration is generated.
function headless_install() {
  # Check if HEADLESS_INSTALL is set to true
  if [ "${HEADLESS_INSTALL}" == true ]; then
    # Set default values for various server settings if not already set
    SERVER_PORT_SETTINGS=${SERVER_PORT_SETTINGS:-1}                       # Default port settings
    SERVER_HOST_V4_SETTINGS=${SERVER_HOST_V4_SETTINGS:-1}                 # Default IPv4 settings
    SERVER_HOST_V6_SETTINGS=${SERVER_HOST_V6_SETTINGS:-1}                 # Default IPv6 settings
    SERVER_HOST_SETTINGS=${SERVER_HOST_SETTINGS:-1}                       # Default server host settings
    AUTOMATIC_UPDATES_SETTINGS=${AUTOMATIC_UPDATES_SETTINGS:-1}           # Default automatic updates settings
    AUTOMATIC_BACKUP_SETTINGS=${AUTOMATIC_BACKUP_SETTINGS:-1}             # Default automatic backup settings
    BLOCK_TRACKERS_AND_ADS_SETTINGS=${BLOCK_TRACKERS_AND_ADS_SETTINGS:-1} # Default block trackers and ads settings
    SQUID_USERNAME=${SQUID_USERNAME:-$(openssl rand -hex 5)}              # Generate a random Squid username if not provided
    AUTOMATIC_CONFIG_REMOVER=${AUTOMATIC_CONFIG_REMOVER:-1}               # Default automatic config remover setting
  fi
}

# Headless installation
headless_install

# Check if the squid proxy is installed
if [ ! -f "${SQUID_CONFIG_PATH}" ]; then

  # Choose the proxy port
  function choose_proxy_port() {
    # Prompt the user to choose the port for Squid Proxy server
    echo "What port do you want Squid Proxy server to listen to?"
    echo "  1) 3128 (Recommended)"
    echo "  2) Custom (Advanced)"
    # Keep asking the user for input until a valid choice (1 or 2) is made
    until [[ "${SERVER_PORT_SETTINGS}" =~ ^[1-2]$ ]]; do
      read -rp "Port Choice [1-2]:" -e -i 1 SERVER_PORT_SETTINGS
    done
    # Handle the user's choice
    case ${SERVER_PORT_SETTINGS} in
    # If the user chooses the recommended port (3128)
    1)
      SERVER_PORT="3128" # Set the default port to 3128
      # Check if the port is already in use
      if [ "$(lsof -i UDP:"${SERVER_PORT}")" ]; then
        echo "Error: Please use a different port because ${SERVER_PORT} is already in use."
      fi
      ;;
    # If the user chooses to provide a custom port
    2)
      # Ensure the custom port is a valid number within the range [0-65535]
      until [[ "${SERVER_PORT}" =~ ^[0-9]+$ ]] && [ "${SERVER_PORT}" -ge 0 ] && [ "${SERVER_PORT}" -le 65535 ]; do
        read -rp "Custom port [0-65535]:" SERVER_PORT
      done
      # Check if the custom port is already in use
      if [ "$(lsof -i UDP:"${SERVER_PORT}")" ]; then
        echo "Error: The port ${SERVER_PORT} is already used by a different application, please use a different port."
      fi
      ;;
    esac
  }

  # choose what port to use for proxy
  choose_proxy_port

  # Get the IPv4 of the current server.
  function test_connectivity_v4() {
    # Prompt the user to choose how they want to detect the IPv4 address
    echo "How would you like to detect IPv4?"
    echo "  1) Curl (Recommended)"
    echo "  2) Custom (Advanced)"
    # Keep asking for input until a valid choice (1 or 2) is made
    until [[ "${SERVER_HOST_V4_SETTINGS}" =~ ^[1-2]$ ]]; do
      read -rp "IPv4 Choice [1-2]:" -e -i 1 SERVER_HOST_V4_SETTINGS
    done
    # Handle the user's choice
    case ${SERVER_HOST_V4_SETTINGS} in
    # If the user chooses the recommended method using Curl
    1)
      # Fetch the server's IPv4 address using an external service
      SERVER_HOST_V4="$(curl --ipv4 --connect-timeout 5 --tlsv1.2 --silent 'https://checkip.amazonaws.com')"
      # If the first service fails, try another service
      if [ -z "${SERVER_HOST_V4}" ]; then
        SERVER_HOST_V4="$(curl --ipv4 --connect-timeout 5 --tlsv1.3 --silent 'https://icanhazip.com')"
      fi
      ;;
    # If the user chooses to manually input a custom IPv4 address
    2)
      read -rp "Custom IPv4:" SERVER_HOST_V4
      # If no custom IPv4 is provided, fall back to Curl-based methods
      if [ -z "${SERVER_HOST_V4}" ]; then
        SERVER_HOST_V4="$(curl --ipv4 --connect-timeout 5 --tlsv1.2 --silent 'https://checkip.amazonaws.com')"
      fi
      if [ -z "${SERVER_HOST_V4}" ]; then
        SERVER_HOST_V4="$(curl --ipv4 --connect-timeout 5 --tlsv1.3 --silent 'https://icanhazip.com')"
      fi
      ;;
    esac
  }

  # Get the IPv4 of the server
  test_connectivity_v4

  # Determine IPv6
  function test_connectivity_v6() {
    # Ask the user how they want to detect the IPv6 address
    echo "How would you like to detect IPv6?"
    echo "  1) Curl (Recommended)"
    echo "  2) Custom (Advanced)"

    # Keep prompting the user until they select a valid choice (1 or 2)
    until [[ "${SERVER_HOST_V6_SETTINGS}" =~ ^[1-2]$ ]]; do
      read -rp "IPv6 Choice [1-2]:" -e -i 1 SERVER_HOST_V6_SETTINGS
    done

    # Handle the user's choice
    case ${SERVER_HOST_V6_SETTINGS} in
    # If the user chooses to detect IPv6 using Curl (recommended)
    1)
      # Fetch the IPv6 address using a Curl-based service
      SERVER_HOST_V6="$(curl --ipv6 --connect-timeout 5 --tlsv1.3 --silent 'https://ifconfig.co')"
      # If the first service fails, try a second service
      if [ -z "${SERVER_HOST_V6}" ]; then
        SERVER_HOST_V6="$(curl --ipv6 --connect-timeout 5 --tlsv1.3 --silent 'https://icanhazip.com')"
      fi
      ;;
    # If the user chooses to manually input a custom IPv6 address
    2)
      read -rp "Custom IPv6:" SERVER_HOST_V6
      # If no custom IPv6 is provided, try using the Curl-based services
      if [ -z "${SERVER_HOST_V6}" ]; then
        SERVER_HOST_V6="$(curl --ipv6 --connect-timeout 5 --tlsv1.3 --silent 'https://ifconfig.co')"
      fi
      if [ -z "${SERVER_HOST_V6}" ]; then
        SERVER_HOST_V6="$(curl --ipv6 --connect-timeout 5 --tlsv1.3 --silent 'https://icanhazip.com')"
      fi
      ;;
    esac
  }

  # Get the IPv6 of the system
  test_connectivity_v6

  # What IP version would you like to be available on this squid server?
  function ipvx_select() {
    # Prompt the user to choose the IP version for Squid server connection
    echo "What IPv do you want to use to connect to the squid server?"
    echo "  1) IPv4 (Recommended)"
    echo "  2) IPv6"
    # Keep asking until a valid choice (1 or 2) is made
    until [[ "${SERVER_HOST_SETTINGS}" =~ ^[1-2]$ ]]; do
      read -rp "IP Choice [1-2]:" -e -i 1 SERVER_HOST_SETTINGS
    done
    # Handle the user's selection
    case ${SERVER_HOST_SETTINGS} in
    # If the user selects IPv4 (default)
    1)
      # If the IPv4 address is detected, use it
      if [ -n "${SERVER_HOST_V4}" ]; then
        SERVER_HOST="${SERVER_HOST_V4}"
      else
        # If IPv4 isn't available, fall back to IPv6
        SERVER_HOST="[${SERVER_HOST_V6}]"
      fi
      ;;
    # If the user selects IPv6
    2)
      # If the IPv6 address is detected, use it
      if [ -n "${SERVER_HOST_V6}" ]; then
        SERVER_HOST="[${SERVER_HOST_V6}]"
      else
        # If IPv6 isn't available, fall back to IPv4
        SERVER_HOST="${SERVER_HOST_V4}"
      fi
      ;;
    esac
  }

  # IPv4 or IPv6 Selector
  ipvx_select

  # real-time updates
  function enable_automatic_updates() {
    # Prompt the user to decide whether to enable real-time updates
    echo "Would you like to setup real-time updates?"
    echo "  1) Yes (Recommended)"
    echo "  2) No (Advanced)"
    # Keep prompting the user until they select a valid choice (1 or 2)
    until [[ "${AUTOMATIC_UPDATES_SETTINGS}" =~ ^[1-2]$ ]]; do
      read -rp "Automatic Updates [1-2]:" -e -i 1 AUTOMATIC_UPDATES_SETTINGS
    done
    # Handle the user's choice
    case ${AUTOMATIC_UPDATES_SETTINGS} in
    # If the user chooses to enable automatic updates
    1)
      # Add a cron job to run updates daily at midnight
      crontab -l | {
        cat
        echo "0 0 * * * ${CURRENT_FILE_PATH} --update"
      } | crontab -

      # Check if systemd is in use for managing services
      if pgrep systemd-journal; then
        # Enable and start the cron service with systemd
        systemctl enable cron
        systemctl start cron
      else
        # Enable and start the cron service without systemd
        service cron enable
        service cron start
      fi
      ;;
    # If the user chooses not to enable automatic updates
    2)
      echo "Real-time Updates Disabled"
      ;;
    esac
  }

  # Enable real-time updates
  enable_automatic_updates

  # real-time backup
  function enable_automatic_backup() {
    # Prompt the user to decide whether to enable real-time backups
    echo "Would you like to setup real-time backup?"
    echo "  1) Yes (Recommended)"
    echo "  2) No (Advanced)"
    # Keep prompting the user until they select a valid choice (1 or 2)
    until [[ "${AUTOMATIC_BACKUP_SETTINGS}" =~ ^[1-2]$ ]]; do
      read -rp "Automatic Backup [1-2]:" -e -i 1 AUTOMATIC_BACKUP_SETTINGS
    done
    # Handle the user's choice
    case ${AUTOMATIC_BACKUP_SETTINGS} in
    # If the user chooses to enable automatic backups
    1)
      # Add a cron job to run backups daily at midnight
      crontab -l | {
        cat
        echo "0 0 * * * ${CURRENT_FILE_PATH} --backup"
      } | crontab -

      # Check if systemd is in use for managing services
      if pgrep systemd-journal; then
        # Enable and start the cron service with systemd
        systemctl enable cron
        systemctl start cron
      else
        # Enable and start the cron service without systemd
        service cron enable
        service cron start
      fi
      ;;
    # If the user chooses not to enable automatic backups
    2)
      echo "Real-time Backup Disabled"
      ;;
    esac
  }

  # Enable real-time backup
  enable_automatic_backup

  # Function to block trackers and ads
  function block_trackers_and_ads() {
    # Ask the user if they want to block trackers and ads
    echo "Do you want to block trackers and ads?"
    echo "  1) Yes (Recommended)"
    echo "  2) No"
    # Keep prompting until the user selects a valid choice (1 or 2)
    until [[ "${BLOCK_TRACKERS_AND_ADS_SETTINGS}" =~ ^[1-2]$ ]]; do
      read -rp "Block trackers and ads [1-2]:" -e -i 1 BLOCK_TRACKERS_AND_ADS_SETTINGS
    done
    # Handle the user's choice
    case ${BLOCK_TRACKERS_AND_ADS_SETTINGS} in
    # If the user chooses to block trackers and ads
    1)
      BLOCK_TRACKERS_AND_ADS=true
      ;;
    # If the user chooses not to block trackers and ads
    2)
      BLOCK_TRACKERS_AND_ADS=false
      ;;
    esac
  }

  # Call the function to decide whether to block trackers and ads
  block_trackers_and_ads

  # Function to set the Squid client's name
  function client_name() {
    # If the Squid username is not already set, prompt the user to enter one
    if [ -z "${SQUID_USERNAME}" ]; then
      echo "Let's name the Squid proxy. Use one word only, no special characters, no spaces."
      read -rp "Client name:" -e -i "$(openssl rand -hex 5)" SQUID_USERNAME
    fi
    # If the username is still empty, generate a random one
    if [ -z "${SQUID_USERNAME}" ]; then
      SQUID_USERNAME="$(openssl rand -hex 5)"
    fi
  }

  # Set the Squid client name by calling the function
  client_name

  # Automatically remove squid proxy after a period of time.
  function auto_remove_confg() {
    # Ask the user if they want to automatically expire the peer after a certain period of time
    echo "Would you like to expire the peer after a certain period of time?"
    echo "  1) Every Year (Recommended)"
    echo "  2) No"
    # Ensure the user chooses either option 1 or 2
    until [[ "${AUTOMATIC_CONFIG_REMOVER}" =~ ^[1-2]$ ]]; do
      read -rp "Automatic config expire [1-2]:" -e -i 1 AUTOMATIC_CONFIG_REMOVER
    done
    # Check the user's choice
    case ${AUTOMATIC_CONFIG_REMOVER} in
    # If the user chose option 1 (expire every year)
    1)
      # Add a cron job to remove the Squid configuration at a set time each year
      crontab -l | {
        cat
        # Schedule the task to execute the script to remove the configuration
        echo "$(date +%M) $(date +%H) $(date +%d) $(date +%m) * echo -e \"${SQUID_USERNAME}\" | ${CURRENT_FILE_PATH} --remove"
      } | crontab -
      # Enable and start the cron service based on the system’s init system (systemd or service)
      if pgrep systemd-journal; then
        systemctl enable cron
        systemctl start cron
      else
        service cron enable
        service cron start
      fi
      ;;
    # If the user chose option 2 (no automatic expiration)
    2) ;;
    esac
  }

  # Call the function to handle the automatic configuration removal
  auto_remove_confg

  # Function to install Squid proxy server if not already installed
  function install_squid_proxy() {
    # Check if the Squid proxy is installed
    if [ ! -x "$(command -v squid)" ]; then
      # Check the current distribution and install Squid accordingly
      if { [ "${CURRENT_DISTRO}" == "ubuntu" ] || [ "${CURRENT_DISTRO}" == "debian" ] || [ "${CURRENT_DISTRO}" == "raspbian" ] || [ "${CURRENT_DISTRO}" == "pop" ] || [ "${CURRENT_DISTRO}" == "kali" ] || [ "${CURRENT_DISTRO}" == "linuxmint" ] || [ "${CURRENT_DISTRO}" == "neon" ]; }; then
        # For Debian/Ubuntu-based systems, install Squid using apt
        apt-get install squid -y
      elif { [ "${CURRENT_DISTRO}" == "fedora" ] || [ "${CURRENT_DISTRO}" == "centos" ] || [ "${CURRENT_DISTRO}" == "rhel" ] || [ "${CURRENT_DISTRO}" == "almalinux" ] || [ "${CURRENT_DISTRO}" == "rocky" ]; }; then
        # For Fedora/CentOS-based systems, install Squid using yum
        yum install squid -y
      elif [ "${CURRENT_DISTRO}" == "arch" ] || [ "${CURRENT_DISTRO}" == "archarm" ] || [ "${CURRENT_DISTRO}" == "manjaro" ]; then
        # For Arch-based systems, install Squid using pacman
        pacman -S --noconfirm --needed squid
      elif [ "${CURRENT_DISTRO}" == "alpine" ]; then
        # For Alpine Linux, install Squid using apk
        apk add squid
      elif [ "${CURRENT_DISTRO}" == "freebsd" ]; then
        # For FreeBSD, install Squid using pkg
        pkg install squid
      fi
    fi
  }

  # Call the function to install Squid proxy if not already installed
  install_squid_proxy

  # Function to configure the Squid Proxy
  function configure_squid_proxy() {
    # Write the initial Squid configuration to the config file
    echo "acl safe_ports port 0-65535
http_access allow safe_ports
http_access allow all
auth_param basic program /usr/lib/squid/basic_ncsa_auth ${SQUID_USERS_DATABASE}
acl authenticated proxy_auth REQUIRED
http_access allow authenticated
http_port ${SERVER_HOST}:${SERVER_PORT}
via off
forwarded_for delete
follow_x_forwarded_for deny all
access_log none
cache_store_log none
cache_log /dev/null" >${SQUID_CONFIG_PATH}
    # If ad-blocking is enabled, add the necessary configuration to block domains
    if [ "${BLOCK_TRACKERS_AND_ADS}" == true ]; then
      # Add rules to block domains listed in the blacklist
      echo "acl domain_blacklist dstdomain ${SQUID_BLOCKED_DOMAIN_PATH}
http_access deny all domain_blacklist" >>${SQUID_CONFIG_PATH}
      # Download the list of blocked domains and format them into the necessary format
      curl "${SQUID_BLOCKED_DOMAIN_URL}" | awk '$1' | awk '{print "."$1""}' >${SQUID_BLOCKED_DOMAIN_PATH}
    fi
    # Generate a random password for the Squid Proxy user
    SQUID_PASSWORD="$(openssl rand -hex 5)"
    # Add the Squid Proxy user and password to the user database
    echo "${SQUID_USERNAME}:$(openssl passwd -apr1 "${SQUID_PASSWORD}")" >>${SQUID_USERS_DATABASE}
    # Construct the connection string for the Squid Proxy, which includes the username and password
    SQUID_PROXY_CONNECTION_STRING="http://${SQUID_USERNAME}:${SQUID_PASSWORD}@${SERVER_HOST}:${SERVER_PORT}"
    # Generate a QR code for the Squid Proxy connection string and print it to the terminal
    qrencode -t ansiutf8 "${SQUID_PROXY_CONNECTION_STRING}"
    # Display the Squid Proxy connection string to the user
    echo "${SQUID_PROXY_CONNECTION_STRING}"
  }

  # Call the function to configure the Squid Proxy
  configure_squid_proxy

else

  # Function to start the Squid Proxy
  function start_squid_proxy() {
    # Check if the 'service' command is available and restart Squid using service
    if [ -x "$(command -v service)" ]; then
      service squid restart
    # If 'service' is not available, check if 'systemctl' is available and enable & restart Squid using systemctl
    elif [ -x "$(command -v systemctl)" ]; then
      systemctl enable squid
      systemctl restart squid
    fi
  }

  # Function to stop the Squid Proxy
  function stop_squid_proxy() {
    # Check if the 'service' command is available and stop Squid using service
    if [ -x "$(command -v service)" ]; then
      service squid stop
    # If 'service' is not available, check if 'systemctl' is available and stop Squid using systemctl
    elif [ -x "$(command -v systemctl)" ]; then
      systemctl stop squid
    fi
  }

  # Function to restart the Squid Proxy
  function restart_squid_proxy() {
    # Check if the 'service' command is available and restart Squid using service
    if [ -x "$(command -v service)" ]; then
      service squid restart
    # If 'service' is not available, check if 'systemctl' is available and restart Squid using systemctl
    elif [ -x "$(command -v systemctl)" ]; then
      systemctl restart squid
    fi
  }

  # Function to add a Squid Proxy user
  function add_squid_proxy_users() {
    # If the Squid username is not set, ask for a new username.
    if [ -z "${SQUID_USERNAME}" ]; then
      echo "Let's name the Squid proxy. Use one word only, no special characters, no spaces."
      read -rp "Client name:" -e -i "$(openssl rand -hex 5)" SQUID_USERNAME
    fi
    # If the username is still not set, generate a random username using openssl.
    if [ -z "${SQUID_USERNAME}" ]; then
      SQUID_USERNAME="$(openssl rand -hex 5)"
    fi
    # Generate a random password for the Squid user.
    SQUID_PASSWORD="$(openssl rand -hex 5)"
    # Extract the server host and port from the Squid config file.
    SERVER_HOST=$(grep http_port ${SQUID_CONFIG_PATH} | awk '{print $2}' | cut -d ":" -f 1)
    SERVER_PORT=$(grep http_port ${SQUID_CONFIG_PATH} | awk '{print $2}' | cut -d ":" -f 2)
    # Add the username and password to the Squid users database (hashed password).
    echo "${SQUID_USERNAME}:$(openssl passwd -apr1 "${SQUID_PASSWORD}")" >>${SQUID_USERS_DATABASE}
    # Generate a QR code for the user to easily connect to the Squid proxy.
    qrencode -t ansiutf8 "http://${SERVER_HOST}:${SERVER_PORT}/${SQUID_USERNAME}:${SQUID_PASSWORD}"
    # Print the Squid proxy connection string.
    echo "http://${SERVER_HOST}:${SERVER_PORT}/${SQUID_USERNAME}:${SQUID_PASSWORD}"
    # If there is an automatic config remover set in crontab, update it to remove the user after a certain period.
    if crontab -l | grep -q "${CURRENT_FILE_PATH} --remove"; then
      crontab -l | {
        cat
        echo "$(date +%M) $(date +%H) $(date +%d) $(date +%m) * echo -e \"${SQUID_USERNAME}\" | ${CURRENT_FILE_PATH} --remove"
      } | crontab -
    fi
  }

  # Function to remove a Squid Proxy user
  function remove_squid_users() {
    # List all users currently in the Squid users database (just the usernames).
    echo "Which Squid proxy would you like to remove?"
    awk -F ':' '{print $1}' ${SQUID_USERS_DATABASE}
    # Prompt the user to input the username of the client they want to remove.
    read -rp "Peer's name:" REMOVECLIENT
    # Remove the selected username from the Squid users database.
    sed -i "/${REMOVECLIENT}/d" ${SQUID_USERS_DATABASE}
  }

  # Function to reinstall Squid Proxy
  function reinstall_squid_proxy() {
    # Check if the current distribution is a Debian-based system and reinstall squid if true.
    if { [ "${CURRENT_DISTRO}" == "ubuntu" ] || [ "${CURRENT_DISTRO}" == "debian" ] || [ "${CURRENT_DISTRO}" == "raspbian" ] || [ "${CURRENT_DISTRO}" == "pop" ] || [ "${CURRENT_DISTRO}" == "kali" ] || [ "${CURRENT_DISTRO}" == "linuxmint" ] || [ "${CURRENT_DISTRO}" == "neon" ]; }; then
      # Use apt-get to reinstall Squid on Debian-based systems
      apt-get --reinstall install squid -y
    # Check if the current distribution is based on RedHat and reinstall squid if true.
    elif { [ "${CURRENT_DISTRO}" == "fedora" ] || [ "${CURRENT_DISTRO}" == "centos" ] || [ "${CURRENT_DISTRO}" == "rhel" ] || [ "${CURRENT_DISTRO}" == "almalinux" ] || [ "${CURRENT_DISTRO}" == "rocky" ]; }; then
      # Use yum to reinstall Squid on RedHat-based systems
      yum reinstall squid -y
    # Check if the current distribution is Arch-based and reinstall squid if true.
    elif [ "${CURRENT_DISTRO}" == "arch" ] || [ "${CURRENT_DISTRO}" == "archarm" ] || [ "${CURRENT_DISTRO}" == "manjaro" ]; then
      # Use pacman to reinstall Squid on Arch-based systems
      pacman -S --noconfirm squid
    # Check if the current distribution is Alpine and reinstall squid if true.
    elif [ "${CURRENT_DISTRO}" == "alpine" ]; then
      # Use apk to fix Squid on Alpine Linux
      apk fix squid
    # Check if the current distribution is FreeBSD and reinstall squid if true.
    elif [ "${CURRENT_DISTRO}" == "freebsd" ]; then
      # Use pkg to check and reinstall Squid on FreeBSD
      pkg check squid
    fi
  }

  # Function to uninstall Squid Proxy
  function uninstall_squid_proxy() {
    # Check if the current distribution is a Debian-based system and uninstall squid if true.
    if { [ "${CURRENT_DISTRO}" == "ubuntu" ] || [ "${CURRENT_DISTRO}" == "debian" ] || [ "${CURRENT_DISTRO}" == "raspbian" ] || [ "${CURRENT_DISTRO}" == "pop" ] || [ "${CURRENT_DISTRO}" == "kali" ] || [ "${CURRENT_DISTRO}" == "linuxmint" ] || [ "${CURRENT_DISTRO}" == "neon" ]; }; then
      # Use apt-get to remove Squid on Debian-based systems
      apt-get remove squid -y
    # Check if the current distribution is based on RedHat and uninstall squid if true.
    elif { [ "${CURRENT_DISTRO}" == "fedora" ] || [ "${CURRENT_DISTRO}" == "centos" ] || [ "${CURRENT_DISTRO}" == "rhel" ] || [ "${CURRENT_DISTRO}" == "almalinux" ] || [ "${CURRENT_DISTRO}" == "rocky" ]; }; then
      # Use yum to remove Squid on RedHat-based systems
      yum remove squid -y
    # Check if the current distribution is Arch-based and uninstall squid if true.
    elif [ "${CURRENT_DISTRO}" == "arch" ] || [ "${CURRENT_DISTRO}" == "archarm" ] || [ "${CURRENT_DISTRO}" == "manjaro" ]; then
      # Use pacman to remove Squid on Arch-based systems
      pacman -Rs --noconfirm squid
    # Check if the current distribution is Alpine and uninstall squid if true.
    elif [ "${CURRENT_DISTRO}" == "alpine" ]; then
      # Use apk to remove Squid on Alpine Linux
      apk del squid
    # Check if the current distribution is FreeBSD and uninstall squid if true.
    elif [ "${CURRENT_DISTRO}" == "freebsd" ]; then
      # Use pkg to remove Squid on FreeBSD
      pkg delete squid
    fi
    # Remove the Squid proxy directory if it exists
    if [ -d "${SQUID_PROXY_DIRECTORY}" ]; then
      rm -rf "${SQUID_PROXY_DIRECTORY}"
    fi
    # Remove the Squid backup password file if it exists
    if [ -f "${SQUID_BACKUP_PASSWORD_PATH}" ]; then
      rm -f "${SQUID_BACKUP_PASSWORD_PATH}"
    fi
    # Remove the Squid configuration backup file if it exists
    if [ -f "${SQUID_CONFIG_BACKUP}" ]; then
      rm -f "${SQUID_CONFIG_BACKUP}"
    fi
  }

  # Function to update Squid Proxy Manager
  function update_squid_proxy_manager() {
    # Download the latest version of the Squid Proxy Manager script from the update URL
    curl "${SQUID_MANAGER_UPDATE_URL}" -o "${CURRENT_FILE_PATH}"
    # Make the downloaded script executable
    chmod +x "${CURRENT_FILE_PATH}"
    # If the blocked domain path exists, update it by downloading the latest blocked domain list
    if [ -f "${SQUID_BLOCKED_DOMAIN_PATH}" ]; then
      curl "${SQUID_BLOCKED_DOMAIN_URL}" -o "${SQUID_BLOCKED_DOMAIN_PATH}"
      # Restart the Squid service using the appropriate command for the system
      if [ -x "$(command -v service)" ]; then
        service squid restart
      elif [ -x "$(command -v systemctl)" ]; then
        systemctl restart squid
      fi
    fi
  }

  # Backup Squid Proxy Configuration and Data
  function backup_squid_proxy() {
    # Check if the Squid Proxy directory exists
    if [ -d "${SQUID_PROXY_DIRECTORY}" ]; then
      # Generate a random password for backup encryption
      BACKUP_PASSWORD="$(openssl rand -hex 5)"
      # Save the generated password to a backup password file
      echo "${BACKUP_PASSWORD}" >"${SQUID_BACKUP_PASSWORD_PATH}"
      # Create a backup of the Squid configuration files and related data (with password encryption)
      zip -P "${BACKUP_PASSWORD}" -rj ${SQUID_CONFIG_BACKUP} ${SQUID_CONFIG_PATH} ${SQUID_BLOCKED_DOMAIN_PATH} ${SQUID_USERS_DATABASE}
    fi
  }

  # Restore Squid Proxy Configuration from Backup
  function restore_squid_proxy() {
    # Check if the Squid backup file exists
    if [ -f "${SQUID_CONFIG_BACKUP}" ]; then
      # Remove the existing configuration, blocked domains, and user database if they exist
      if [ -f "${SQUID_CONFIG_PATH}" ]; then
        rm -f ${SQUID_CONFIG_PATH}
      fi
      if [ -f "${SQUID_BLOCKED_DOMAIN_PATH}" ]; then
        rm -f ${SQUID_BLOCKED_DOMAIN_PATH}
      fi
      if [ -f "${SQUID_USERS_DATABASE}" ]; then
        rm -f ${SQUID_USERS_DATABASE}
      fi
      # Unzip the backup configuration files to the Squid proxy directory
      unzip ${SQUID_CONFIG_BACKUP} -d ${SQUID_PROXY_DIRECTORY}
    fi
  }

  # Function to choose the Squid Proxy port
  function choose_squid_proxy_port() {
    # Get the current server port from the Squid configuration file
    OLD_SERVER_PORT=$(grep http_port ${SQUID_CONFIG_PATH} | awk '{print $2}' | cut -d ":" -f 2)

    # Prompt the user to enter a new server port within the valid range (0-65535)
    until [[ "${NEW_SERVER_PORT}" =~ ^[0-9]+$ ]] && [ "${NEW_SERVER_PORT}" -ge 0 ] && [ "${NEW_SERVER_PORT}" -le 65535 ]; do
      read -rp "Custom port [0-65535]: " -e -i 3128 NEW_SERVER_PORT
    done

    # Check if the chosen port is already in use by another application using 'lsof'
    if [ "$(lsof -i UDP:"${NEW_SERVER_PORT}")" ]; then
      echo "Error: The port ${NEW_SERVER_PORT} is already used by a different application, please use a different port."
    fi

    # Update the Squid configuration file with the new port
    sed -i "s|${OLD_SERVER_PORT}|${NEW_SERVER_PORT}|" ${SQUID_CONFIG_PATH}
  }

  # Function to purge all Squid users
  function purge_squid_users() {
    # Prompt the user for confirmation to purge all Squid users
    echo "Are you sure you want to purge all squid users?"
    echo "In the future"
    # The functionality to actually remove users is missing here.
  }

  # Function to list all Squid users
  function list_all_squid_users() {
    # List all the Squid users from the database by extracting the first field (username) from the file
    awk -F ':' '{print $1}' ${SQUID_USERS_DATABASE}
  }

  # Function to update the Squid Proxy IP address
  function update_ip_address() {
    # Get the current server host (IP address) from the Squid configuration file
    OLD_SERVER_HOST=$(grep http_port ${SQUID_CONFIG_PATH} | awk '{print $2}' | cut -d ":" -f 1)
    # Attempt to fetch the current external IP address using a couple of services
    NEW_SERVER_HOST="$(curl --ipv4 --connect-timeout 5 --tlsv1.2 --silent 'https://checkip.amazonaws.com')"
    # If the first service fails to return an IP, try the second service
    if [ -z "${NEW_SERVER_HOST}" ]; then
      NEW_SERVER_HOST="$(curl --ipv4 --connect-timeout 5 --tlsv1.3 --silent 'https://icanhazip.com')"
    fi
    # Replace the old IP address in the Squid configuration file with the new one
    sed -i "s/${OLD_SERVER_HOST}/${NEW_SERVER_HOST}/" ${SQUID_CONFIG_PATH}
  }

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
    echo "13) List all users"
    echo "14) Update ip address"
    until [[ "${SQUID_MANAGER_OPTIONS}" =~ ^[0-9]+$ ]] && [ "${SQUID_MANAGER_OPTIONS}" -ge 1 ] && [ "${SQUID_MANAGER_OPTIONS}" -le 14 ]; do
      read -rp "Select an Option [1-14]:" -e -i 0 SQUID_MANAGER_OPTIONS
    done
    case ${SQUID_MANAGER_OPTIONS} in
    1) # Start Squid
      start_squid_proxy
      ;;
    2) # Stop Squid
      stop_squid_proxy
      ;;
    3) # Restart Squid
      restart_squid_proxy
      ;;
    4) # Add a squid user
      add_squid_proxy_users
      ;;
    5) # Remove a user
      remove_squid_users
      ;;
    6) # Reinstall squid
      reinstall_squid_proxy
      ;;
    7) # Uninstall squid
      uninstall_squid_proxy
      ;;
    8) # Update the script
      update_squid_proxy_manager
      ;;
    9) # Backup squid
      backup_squid_proxy
      ;;
    10) # Restore squid
      restore_squid_proxy
      ;;
    11) # Update the interface port
      choose_squid_proxy_port
      ;;
    12) # Purge squid users
      purge_squid_users
      ;;
    13) # List all squid users
      list_all_squid_users
      ;;
    14) # Update the ip address
      update_ip_address
      ;;
    esac
  }

  configure-after-installation

fi
