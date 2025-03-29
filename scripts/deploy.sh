#!/bin/bash

# Deployment script for Apache Ambari Download Site
# Author: Apache Ambari Community
# Created: 2024-03-20

set -e

# Configuration
SITE_ROOT="/var/www/apache-ambari/download"
REPO_ROOT="/root/ambari-download-site"
BACKUP_DIR="/var/backups/ambari-site"
LOG_DIR="/var/log/ambari-site"
LOG_FILE="${LOG_DIR}/deploy.log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Ensure directories exist
mkdir -p "${BACKUP_DIR}" "${LOG_DIR}"

# Logging function
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] $1" | tee -a "${LOG_FILE}"
}

# Backup current site
backup_site() {
    log "Creating backup of current site..."
    if [ -d "${SITE_ROOT}" ]; then
        tar -czf "${BACKUP_DIR}/site_backup_${TIMESTAMP}.tar.gz" -C "${SITE_ROOT}" .
        log "Backup created at ${BACKUP_DIR}/site_backup_${TIMESTAMP}.tar.gz"
    else
        log "No existing site to backup"
    fi
}

# Update from git
update_from_git() {
    log "Updating from git repository..."
    cd "${REPO_ROOT}"
    git pull origin main
    log "Git update completed"
}

# Deploy site files
deploy_site() {
    log "Deploying site files..."
    
    # Ensure site root exists
    mkdir -p "${SITE_ROOT}"
    
    # Copy files
    cp -r "${REPO_ROOT}/src/"* "${SITE_ROOT}/"
    
    # Set permissions
    chown -R www-data:www-data "${SITE_ROOT}"
    chmod -R 755 "${SITE_ROOT}"
    
    log "Site files deployed successfully"
}

# Verify deployment
verify_deployment() {
    log "Verifying deployment..."
    
    # Check if main files exist
    local required_files=("index.html" "css/styles.css" "js/main.js")
    local missing_files=0
    
    for file in "${required_files[@]}"; do
        if [ ! -f "${SITE_ROOT}/${file}" ]; then
            log "ERROR: Missing required file: ${file}"
            missing_files=$((missing_files + 1))
        fi
    done
    
    # Check translations
    if [ ! -d "${SITE_ROOT}/translations" ]; then
        log "ERROR: Missing translations directory"
        missing_files=$((missing_files + 1))
    else
        local required_translations=("en.json" "zh-CN.json")
        for trans in "${required_translations[@]}"; do
            if [ ! -f "${SITE_ROOT}/translations/${trans}" ]; then
                log "ERROR: Missing required translation: ${trans}"
                missing_files=$((missing_files + 1))
            fi
        done
    fi
    
    if [ ${missing_files} -eq 0 ]; then
        log "Deployment verification successful"
        return 0
    else
        log "Deployment verification failed: ${missing_files} files missing"
        return 1
    fi
}

# Main deployment process
main() {
    log "Starting deployment process..."
    
    # Backup current site
    backup_site
    
    # Update from git
    update_from_git
    
    # Deploy site files
    deploy_site
    
    # Verify deployment
    if verify_deployment; then
        log "Deployment completed successfully"
    else
        log "Deployment completed with errors"
        # Restore from backup if needed
        if [ -f "${BACKUP_DIR}/site_backup_${TIMESTAMP}.tar.gz" ]; then
            log "Restoring from backup..."
            rm -rf "${SITE_ROOT}/*"
            tar -xzf "${BACKUP_DIR}/site_backup_${TIMESTAMP}.tar.gz" -C "${SITE_ROOT}"
            log "Restore completed"
        fi
        exit 1
    fi
}

# Execute main function
main "$@" 