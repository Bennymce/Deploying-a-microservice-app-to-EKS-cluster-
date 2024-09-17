#!/bin/bash

# Define the group name
GROUP_NAME="devops-team"

# Create the group
sudo groupadd "$GROUP_NAME"

# Define the usernames
USERNAMES=("benny" "jenny" "john")

# Add each user to the group
for USER in "${USERNAMES[@]}"; do
    sudo usermod -aG "$GROUP_NAME" "$USER"
done

echo "Group $GROUP_NAME created and users added."



# Define the kubeconfig file path and group name
KUBECONFIG_FILE=~/.kube/config
GROUP_NAME="devops-team"

# Change the group ownership of the kubeconfig file
sudo chown :$GROUP_NAME "$KUBECONFIG_FILE"

# Set read permissions for the group
sudo chmod 400 "$KUBECONFIG_FILE"

echo "Group $GROUP_NAME has been given read permission to $KUBECONFIG_FILE."
