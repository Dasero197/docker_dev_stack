#!/usr/bin/with-contenv bash
# This script runs at container startup before Syncthing starts.
# It checks if the /sync directory is mapped correctly and has the right permissions.

echo "[custom-init] Checking /sync directory..."

if [ ! -d "/sync" ]; then
    echo "[custom-init] ERROR: /sync directory is missing. Make sure SYNCTHING_SYNC_DIR is defined in your .env file."
    exit 1
fi

# Check if directory is owned by root, which means Docker auto-created it because it was missing on the host.
DIR_OWNER=$(stat -c '%u' /sync)

if [ "$DIR_OWNER" = "0" ]; then
    echo "=========================================================================="
    echo " WARNING: /sync directory is owned by root!"
    echo " This usually means Docker created the folder on your host automatically,"
    echo " because it did not exist before running 'docker compose up'."
    echo " Please stop the container, delete the auto-created folder, run the setup"
    echo " script 'scripts/setup-vault-manager.sh', and then restart."
    echo "=========================================================================="
    # We chown it to PUID/PGID as a fallback to prevent permission denied errors in Syncthing,
    # but the warning above is important for the user to understand.
    chown -R "$PUID:$PGID" /sync
else
    echo "[custom-init] /sync directory permissions look good."
fi
