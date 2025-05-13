#!/bin/bash

check_and_set_permissions() {
    local dir=$1
    local owner="${PUID}:${PGID}"
    
    echo "Checking permissions for ${dir}..."
    
    if [ "$(stat -c '%U:%G' "${dir}")" != "${owner}" ]; then
        echo "Updating ownership of ${dir} to ${owner}..."
        chown "${owner}" "${dir}"
        chmod 775 "${dir}"
        if [ $? -ne 0 ]; then
            echo "Failed to set ownership on ${dir}"
            return 1
        fi
    else
        echo "Ownership of ${dir} is already correct"
    fi

    # Check a random file/subdirectory in the directory
    local sample_item=$(find "${dir}" -maxdepth 1 | head -n 2 | tail -n 1)
    if [ -n "${sample_item}" ] && [ "$(stat -c '%U:%G' "${sample_item}")" != "${owner}" ]; then
        echo "Updating ownership of contents in ${dir} to ${owner}..."
        chown -R "${owner}" "${dir}"
        chmod 775 -R "${dir}"
        if [ $? -ne 0 ]; then
            echo "Failed to set ownership on contents of ${dir}"
            return 1
        fi
    else
        echo "Ownership of contents in ${dir} appears to be correct"
    fi

    return 0
}

check_and_set_permissions "${USER_HOME}"

su -c "source /start_game.sh" "$(id -u -n $PUID)"