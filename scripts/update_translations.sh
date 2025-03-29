#!/bin/bash

# Translation update script for Apache Ambari Download Site
# Author: Apache Ambari Community
# Created: 2024-03-20

set -e

# Configuration
REPO_ROOT="/root/ambari-download-site"
TRANSLATIONS_DIR="${REPO_ROOT}/src/translations"
LOG_DIR="/var/log/ambari-site"
LOG_FILE="${LOG_DIR}/translations.log"

# Ensure log directory exists
mkdir -p "${LOG_DIR}"

# Logging function
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] $1" | tee -a "${LOG_FILE}"
}

# Update a specific translation file
update_translation() {
    local lang="$1"
    local trans_file="${TRANSLATIONS_DIR}/${lang}.json"
    
    log "Updating translation for ${lang}..."
    
    # Ensure the translation file exists
    if [ ! -f "${trans_file}" ]; then
        log "ERROR: Translation file not found: ${trans_file}"
        return 1
    fi
    
    # Validate JSON format
    if ! jq '.' "${trans_file}" > /dev/null 2>&1; then
        log "ERROR: Invalid JSON format in ${trans_file}"
        return 1
    fi
    
    # Update translation file with any missing keys from English
    jq -s '.[0] * .[1]' "${TRANSLATIONS_DIR}/en.json" "${trans_file}" > "${trans_file}.tmp"
    mv "${trans_file}.tmp" "${trans_file}"
    
    log "Translation updated successfully for ${lang}"
    return 0
}

# Main function
main() {
    log "Starting translation update process..."
    
    # List of supported languages
    local languages=("en" "zh-CN" "ja" "ko" "es" "fr" "de" "it" "pt" "ru" "ar" "hi")
    local errors=0
    
    # Update each translation
    for lang in "${languages[@]}"; do
        if ! update_translation "${lang}"; then
            errors=$((errors + 1))
        fi
    done
    
    # Report results
    if [ ${errors} -eq 0 ]; then
        log "All translations updated successfully"
        return 0
    else
        log "Translation update completed with ${errors} errors"
        return 1
    fi
}

# Execute main function
main "$@" 