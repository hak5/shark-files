#!/bin/bash
#
# Title:         Sample Nmap Payload for Shark Jack
# Author:        Hak5
# Version:       1.0
#
# Scans target subnet with Nmap using specified options. Saves each scan result
# to loot storage folder.
#
# Red ...........Setup
# Amber..........Scanning
# Green..........Finished
#
# See nmap --help for options. Default "-sP" ping scans the address space for
# fast host discovery.

NMAP_OPTIONS="-sP --host-timeout 30s --max-retries 3"
LOOT_DIR=/root/loot/nmap
SCAN_DIR=/etc/shark/nmap


function finish() {
    LED CLEANUP
    # Kill Nmap
    wait $1
    kill $1 &> /dev/null

    # Sync filesystem
    echo $SCAN_M > $SCAN_FILE
    sync
    sleep 1

    LED FINISH
    sleep 1

    # Halt system
    halt
}

function setup() {
    LED SETUP
    # Create loot directory
    mkdir -p $LOOT_DIR &> /dev/null

    # Create tmp scan directory
    mkdir -p $SCAN_DIR &> /dev/null

    # Create tmp scan file if it doesn't exist
    SCAN_FILE=$SCAN_DIR/scan-count
    if [ ! -f $SCAN_FILE ]; then
        touch $SCAN_FILE && echo 0 > $SCAN_FILE
    fi

    # Find IP address and subnet
    NETMODE DHCP_CLIENT
    while [ -z "$SUBNET" ]; do
        sleep 1 && find_subnet
    done
}

function find_subnet() {
    #this function only finds ipv4 subnets but is safe in the presence of ipv6
    SUBNET=$(ip -4 addr show eth0 | awk '/inet\s/ {print $2}' | sed 's/\.[0-9]*\//\.0\//')
}

function run() {
    # Run setup
    setup

    SCAN_N=$(cat $SCAN_FILE)
    SCAN_M=$(( $SCAN_N + 1 ))

    LED ATTACK
    # Start scan
    nmap $NMAP_OPTIONS $SUBNET -oN $LOOT_DIR/nmap-scan_$SCAN_M.txt &>/dev/null &
    tpid=$!

    finish $tpid
}


# Run payload
run &
