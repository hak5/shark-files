#!/bin/bash
#
# Title:         Demo Advanced Payload for Shark Jack
# Author:        Zero_Chaos
# Version:       2.0
#
# Scans target subnet with Nmap using specified options. Saves each scan result
# to loot storage folder.
#
# Red ...........Setup
# Amber..........Scanning
# Green..........Finished
#
# See nmap --help for options. Default "-sS" syn scans the address space
# with heavy timeouts for fast host discovery.

NMAP_OPTIONS="-sS --host-timeout 30s --max-retries 3"

function finish() {
    LED CLEANUP
    wait "${1}"

    # Sync filesystem
    echo "${SCAN_M}" > "${SCAN_FILE}"
    sync

    LED FINISH
    sleep 1

    # Halt system
    halt
}

function setup() {
    LED SETUP

    SCAN_DIR=/etc/shark/nmap
    # Create tmp scan directory
    mkdir -p "${SCAN_DIR}" &> /dev/null

    # Create tmp scan file if it doesn't exist
    SCAN_FILE="${SCAN_DIR}/scan-count"
    if [ ! -f "${SCAN_FILE}" ]; then
        touch "${SCAN_FILE}" && echo 0 > "${SCAN_FILE}"
    fi

    # Find IP address and subnet
    NETMODE DHCP_CLIENT
    while [ -z "${SUBNET}" ]; do
        sleep 1 && find_subnet
    done
}

function run() {
    # Run setup
    setup

    SCAN_N=$(cat ${SCAN_FILE})
    SCAN_M=$(( SCAN_N + 1 ))

    LED ATTACK
    # Start scan
    nmap ${NMAP_OPTIONS} "${SUBNET}" -oN "${LOOT_DIR}/nmap-scan_${SCAN_M}.txt" &>/dev/null &
    tpid=$!

    finish "${tpid}"
}


# Run payload with a 5 minute timeout
timeout -t 300 run &
