#!/usr/bin/env bash

set -euo pipefail

# code here
#

echo "Starting Splunk Universal Forwarder setup..."
echo "Starting Splunk Universal Forwarder setup..." >> setup-forwarder.log

echo "Checking if i'm running as root."
echo "Checking if i'm running as root." >> setup-forwarder.log

USER=$(whoami)
if [[ "$USER" != "root" ]]; then
  echo "Run me as root. Exiting!"
  echo "Run me as root. Exiting!" >> setup-forwarder.log
  exit 1
fi

install_splunk() {
  # 1. Detect the Operating System and Architecture
  OS=$(uname -s)
  ARCH=$(uname -m)

  # Define the download URL based on OS and architecture
  if [[ "$OS" == "Linux" ]]; then
      if [[ "$ARCH" == "x86_64" ]]; then
          DOWNLOAD_URL="https://mscampus.wustl.edu/Splunk/UniversalForwarder/Linux/64-bit/splunkforwarder-9.4.4-f627d88b766b-linux-amd64.tgz"
      else
        echo "Unsupported Linux architecture $ARCH. Exiting..."
        exit 1
      fi
    else
      echo "Unsupported operating system $OS. Exiting..."
      exit 1
  fi

  # 2. Download the Splunk Universal Forwarder
  echo "Downloading Splunk Universal Forwarder from $DOWNLOAD_URL..."
  wget --header="User-Agent: Mozilla/5.0" -O /tmp/splunkforwarder.tgz "$DOWNLOAD_URL"

  # Check if download was successful
  if [[ $? -ne 0 ]]; then
      echo "Failed to download Splunk Universal Forwarder. Exiting..."
      exit 1
  fi

  # 3. Extract the downloaded file
  echo "Extracting Splunk Universal Forwarder..."
  sudo tar -xzvf /tmp/splunkforwarder.tgz -C /opt/ || { echo "Failed to extract Splunk Universal Forwarder. Exiting..."; exit 1; }

  # 4. Start the Splunk Universal Forwarder
  echo "Starting Splunk Universal Forwarder..."
  cd /opt/splunkforwarder/bin
  sudo ./splunk start --accept-license

  # 5. Enable Splunk to start on boot
  echo "Enabling Splunk Universal Forwarder to start on boot..."
  sudo ./splunk enable boot-start

  # 6. Prompt the user for the Splunk server IP
  read -p "Enter the IP address of the Splunk server: " splunk_server_ip
}

apt_based() {
  echo "Checking if wget, tar, or unzip is not installed." >> setup-forwarder.log 

  # Ensure required tools are installed (wget, tar, unzip)
  if ! command -v wget &> /dev/null || ! command -v tar &> /dev/null || ! command -v unzip &> /dev/null; then
    echo "wget, tar, or unzip is not installed. Installing..."
    echo "wget, tar, or unzip is not installed. Installing..." >> setup-forwarder.log 
    sudo apt-get update && apt-get install wget tar unzip -y || { echo "Failed to install required tools"; exit 1; }
  fi
  echo "tools found or installed"
  install_splunk
}

while true; do
  printf "1.| apt\n2.| dnf\n3.| other \n"
  printf "\nWhat package manager are you using?: "
  read -r package_manager_selection
  if [ "$package_manager_selection" = "1" ]; then
      echo "on apt_based" >> setup-forwarder.log 
      apt_based
      break 
    elif [ "$package_manager_selection" = "2" ]; then
      swap_size=32
      break
    elif [ "$package_manager_selection" = "3" ]; then
      swap_size=8
      break
    else
      red_text "Invalid selection $package_manager_selection"
      continue
    fi

done

