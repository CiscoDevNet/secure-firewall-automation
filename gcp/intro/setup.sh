#!/bin/bash

# Install required packages
apt-get update
apt-get install -y curl gnupg

# Add Google Cloud SDK repository and import key
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# Install Google Cloud SDK
apt-get update
apt-get install -y google-cloud-sdk python3

# Clean up
apt-get clean