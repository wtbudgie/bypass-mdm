#!/bin/bash

# Define color codes
RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
YEL='\033[1;33m'
PUR='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

# Function to get the system volume name
get_system_volume() {
    system_volume=$(diskutil info / | grep "Device Node" | awk -F': ' '{print $2}' | xargs diskutil info | grep "Volume Name" | awk -F': ' '{print $2}' | tr -d ' ')
    echo "$system_volume"
}

# Get the system volume name
system_volume=$(get_system_volume)

# Display header
echo -e "${CYAN}Bypass MDM By Assaf Dori (assafdori.com)${NC}"
echo ""

# Prompt user for choice
PS3='Please enter your choice: '
options=("Bypass MDM from Recovery" "Reboot & Exit")
select opt in "${options[@]}"; do
    case $opt in
        "Bypass MDM from Recovery")
            # Bypass MDM from Recovery
            echo -e "${YEL}Bypass MDM from Recovery"
            if [ -d "/Volumes/$system_volume - Data" ]; then
                diskutil rename "$system_volume - Data" "Data"
            fi

            # Block MDM domains
            echo "0.0.0.0 deviceenrollment.apple.com" >>/Volumes/"$system_volume"/etc/hosts
            echo "0.0.0.0 mdmenrollment.apple.com" >>/Volumes/"$system_volume"/etc/hosts
            echo "0.0.0.0 iprofiles.apple.com" >>/Volumes/"$system_volume"/etc/hosts
            echo -e "${GRN}Successfully blocked MDM & Profile Domains"

            # Remove configuration profiles
            touch /Volumes/Data/private/var/db/.AppleSetupDone
            rm -rf /Volumes/"$system_volume"/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
            rm -rf /Volumes/"$system_volume"/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
            touch /Volumes/"$system_volume"/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
            touch /Volumes/"$system_volume"/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound

            echo -e "${GRN}MDM enrollment has been bypassed!${NC}"
            echo -e "${NC}Exit terminal and reboot your Mac.${NC}"
            break
            ;;
        "Reboot & Exit")
            # Reboot & Exit
            echo "Rebooting..."
            reboot
            break
            ;;
        *) echo "Invalid option $REPLY" ;;
    esac
done
