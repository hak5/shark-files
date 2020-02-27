#!/bin/bash
#
# HAK5_HELPERS by @Zero_ChaosX
# Built in helper functions and variables to aid writing payloads

export LOOT_DIR=/root/loot/

function find_subnet() {
    #USAGE:  find_subnet
    #Result: defines SUBNET environment variable, if an IP address has been assigned
    #Notes:  this function only finds ipv4 subnets but is safe in the presence of ipv6
    #        removing the tail -n1 would make this a newline seperated list of assigned ip addresses
    SUBNET=$(ip -4 addr show eth0 | awk '/inet\s/ {print $2}' | sed 's/\.[0-9]*\//\.0\//' | tail -n1)
    export SUBNET
}
export -f find_subnet

#function wait_for_link()
    #USAGE:  wait_for_link
    #Result: execution pauses until link connected state is detected
    #Notes:  defined in /usr/bin/execute_payload

function wait_for_no_link() {
    #USAGE:  wait_for_no_link
    #Result: execution pauses until link disconnected state is detected
    LED LINKSETUP
    until swconfig dev switch0 port 0 get link | grep -q 'link:down'; do
        sleep 1
    done
    LED SETUP
}
export -f wait_for_no_link
