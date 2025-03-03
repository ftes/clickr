#!/bin/bash

# After opening a Wireguard connection to your Fly network, run this script to
# open a BEAM Observer from your local machine to the remote server. This creates
# a local node that is clustered to a machine running on Fly.

# In order for it to work:
# - Your wireguard connection must be up.
# - The COOKIE value must be the same as the cookie value used for your project.
# - Observer needs to be working in your local environment. That requires WxWidget support in your Erlang install.

# When done, close Observer. It leaves you with an open IEx shell that is connected to the remote server. You can safely CTRL+C, CTRL+C to exit it.

# COOKIE NOTE:
# ============
# You can explicitly set the COOKIE value in the script if you prefer. That would look like this.
#
COOKIE=GiuABWCdF6V5b7o3hs8MF6zqWiferbajc2bfvOLQVSd7XF58A8ARbA==

set -e

if [ -z "$COOKIE" ]; then
    echo "Set the COOKIE your project uses in the COOKIE ENV value before running this script"
    exit 1
fi

# Get the first IPv6 address returned
ip_array=( $(fly ips private | awk '(NR>1){ print $3 }') )
IP=${ip_array[0]}

# Get the Fly app name. Assumes it is used as part of the full node name
APP_NAME=`fly info --name`
FULL_NODE_NAME="${APP_NAME}@${IP}"
echo Attempting to connect to $FULL_NODE_NAME

# Export the BEAM settings for running the "iex" command.
# This creates a local node named "my_remote". The name used isn't important.
# The cookie must match the cookie used in your project so the two nodes can connect.
iex --erl "-proto_dist inet6_tcp" --sname my_remote --cookie ${COOKIE} -e "IO.inspect(Node.connect(:'${FULL_NODE_NAME}'), label: \"Node Connected?\"); IO.inspect(Node.list(), label: \"Connected Nodes\"); :observer.start"
