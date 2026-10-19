#!/bin/sh
set -eu
mkdir -p /run/ssh /run/ansible-public
if [ ! -f /run/ssh/id_ed25519 ]; then
  ssh-keygen -q -t ed25519 -N '' -f /run/ssh/id_ed25519
fi
chmod 600 /run/ssh/id_ed25519
cp /run/ssh/id_ed25519.pub /run/ansible-public/authorized_keys
chmod 644 /run/ansible-public/authorized_keys
echo "Lab SSH key is ready. Private key stays in the controller's Docker volume."
