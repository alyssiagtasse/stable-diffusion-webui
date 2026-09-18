#!/bin/bash
set -euo pipefail

# Fallback when the container is started as a non-root user (e.g. `--user 99:100`)
if [[ $EUID -ne 0 ]]; then
    exec bash /home/forge/sd-webui/entrypoint.sh "$@"
fi

# SSH (root login via public key only)
mkdir -p /run/sshd
if [[ -n "${SSH_ROOT_PUBKEY:-}" ]]; then
    mkdir -p /root/.ssh
    printf '%s\n' "$SSH_ROOT_PUBKEY" > /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/authorized_keys
fi
[[ -e /etc/ssh/ssh_host_ed25519_key ]] || ssh-keygen -A
/usr/sbin/sshd || echo "Warning: sshd failed to start" >&2

# Drop privileges and hand off to the WebUI as the forge user
exec setpriv --reuid=99 --regid=100 --init-groups env HOME=/home/forge \
    bash /home/forge/sd-webui/entrypoint.sh "$@"
