#!/bin/bash

# Author: Apache Ambari Community
# Created: 2024-03-20
# Description: Generate MD5 checksums for RPM packages and update website translations

# Configuration
DIST_DIR="/var/www/apache-ambari/dist"
WEBSITE_DIR="/var/www/apache-ambari/download"
LOG_DIR="/var/log/apache-ambari"
LOG_FILE="${LOG_DIR}/md5_generation.log"

# Ensure log directory exists
mkdir -p "${LOG_DIR}"

# Logging function
log() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] ${message}" | tee -a "${LOG_FILE}"
}

# Function to generate MD5 checksums for a specific version and OS version
generate_version_md5() {
    local component="$1"  # ambari or bigtop
    local version="$2"    # e.g., 3.0.0 or 3.3.0
    local os_version="$3" # rocky8 or rocky9
    
    # Normalize path components and remove any double slashes
    local target_dir="${DIST_DIR}/${component}/${version}/${os_version}"
    target_dir=$(echo "${target_dir}" | sed 's#/\+#/#g')
    local md5_file="${target_dir}/MD5SUMS.txt"
    
    if [ ! -d "${target_dir}" ]; then
        log "Error: Directory ${target_dir} does not exist"
        return 1
    fi
    
    log "Generating MD5 checksums for ${component} ${version} ${os_version}"
    
    # Create MD5SUMS.txt file
    cd "${target_dir}" || return 1
    find . -type f -name "*.rpm" -exec md5sum {} \; | sort -k 2 > "${md5_file}"
    local result=$?
    
    if [ ${result} -eq 0 ]; then
        log "Successfully generated ${md5_file}"
        # Verify the MD5SUMS.txt file was created and has content
        if [ -s "${md5_file}" ]; then
            log "MD5SUMS.txt file created successfully with content"
            return 0
        else
            log "Warning: MD5SUMS.txt file is empty, no RPM files found"
            return 1
        fi
    else
        log "Error: Failed to generate ${md5_file}"
        return 1
    fi
}

# Function to update website translations
update_website_translations() {
    local languages=("en" "zh-CN" "ja" "ko" "es" "fr" "de" "it" "pt" "ru" "ar" "hi")
    
    for lang in "${languages[@]}"; do
        local translation_file="${WEBSITE_DIR}/translations/${lang}.json"
        if [ -f "${translation_file}" ]; then
            log "Updating translations for ${lang}"
            jq --arg lang "${lang}" '.' "${translation_file}" > "${translation_file}.tmp" && mv "${translation_file}.tmp" "${translation_file}"
        else
            log "Warning: Translation file for ${lang} not found"
        fi
    done
}

# Main function
main() {
    local components=("ambari" "bigtop")
    local versions=("3.0.0" "3.3.0")
    local os_versions=("rocky8" "rocky9")
    
    for component in "${components[@]}"; do
        for version in "${versions[@]}"; do
            # Skip if version doesn't match component
            if [ "${component}" = "ambari" ] && [ "${version}" != "3.0.0" ]; then
                continue
            fi
            if [ "${component}" = "bigtop" ] && [ "${version}" != "3.3.0" ]; then
                continue
            fi
            
            for os_version in "${os_versions[@]}"; do
                generate_version_md5 "${component}" "${version}" "${os_version}"
            done
        done
    done
    
    #update_website_translations
    
    log "MD5 checksum generation completed"
}

# Execute main function
main "$@" 

# Usage Instructions:
# =================
# This script generates MD5 checksums for RPM packages in the Apache Ambari and Bigtop distributions.
#
# Directory Structure:
#   /var/www/apache-ambari/dist/
#   ├── ambari/3.0.0/
#   │   ├── rocky8/
#   │   └── rocky9/
#   └── bigtop/3.3.0/
#       ├── rocky8/
#       └── rocky9/
#
# How to use:
# 1. Make sure you have write permissions to the distribution directories
# 2. Simply run the script:
#    ./generate_md5.sh
#
# The script will:
# - Generate MD5SUMS.txt for all RPM packages in each directory
# - Log all operations to /var/log/apache-ambari/md5_generation.log
# - Handle both Ambari (3.0.0) and Bigtop (3.3.0) distributions
# - Process both Rocky 8 and Rocky 9 OS versions
#
# Example output files:
# - /var/www/apache-ambari/dist/ambari/3.0.0/rocky8/MD5SUMS.txt
# - /var/www/apache-ambari/dist/ambari/3.0.0/rocky9/MD5SUMS.txt
# - /var/www/apache-ambari/dist/bigtop/3.3.0/rocky8/MD5SUMS.txt
# - /var/www/apache-ambari/dist/bigtop/3.3.0/rocky9/MD5SUMS.txt 