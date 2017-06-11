#!/bin/bash

# (C)2016 Robert Ventura
## Script per realitzar Backups d'una BD MySQL 
## via Percona XtraBackup

HELP_VERSION=1.0

## ================================================
## CONSTANTS
## ================================================
_ARCHIVE_EXTENSION="tar.gz"

## ================================================
## LIBRARIES
## ================================================
BSFL_LIB_PATH=./lib/bsfl
UTILS_LIB_PATH=./lib/utils

source ${UTILS_LIB_PATH}
if [[ $? -ne 0 ]]; then   
    echo "Origen de util library desconegut: ${UTILS_LIB_PATH}"
    exit ${_EXEC_FAILURE}
fi

source ${BSFL_LIB_PATH}
if [[ $? -ne 0 ]]; then   
    echo "Origen de util library desconegut: ${BSFL_LIB_PATH}"
    exit ${_EXEC_FAILURE}
fi


## ================================================
## FLAGS
## ================================================
FLAGS_verbose=1
FLAGS_backup_repository=''
FLAGS_mysql_user=''
FLAGS_mysql_pwd=''
FLAGS_tmp_dir='/tmp/xb_backup_mysql_full'  						# Directori temporal
FLAGS_log_file='/var/log/mysql/xb-backup-mysql-full-bash.log'	# Fitxer de log
FLAGS_backup_threads=1 											# Numero de threads utilitzats per fer el backup.


## ================================================
## GLOBAL VARIABLES
## ================================================
_innobackupex_bin=''
_archiver_bin=''
_xb_backup_opts=''
_xb_prepare_opts=''
_archive_path=''
			

## ================================================
## METHODS
## ================================================
###################################################
# Check if the required binaries are installed.
#
# Args:
#     None
# Output:
#     Error messages for each missing binary.
# Returns:
#     None
xb_check_binaries() {
    _innobackupex_bin=$(command -v innobackupex) || bail "Could not locate innobackupex binary. You must install Percona Xtrabackup."
    _archiver_bin=$(command -v tar) || bail "Could not locate tar binary. You must install tar."
}

###################################################
# Prepare the _xb_backup_opts & xb_prepare_opts variable 
# with the required options for the backup.
# Args:
#     None
# Output:
#     None
# Returns:
#     None
xb_prepare_bkp_opts() {
    _xb_backup_opts="--parallel=${FLAGS_backup_threads} --no-lock --no-timestamp"

    if [[ ${FLAGS_mysql_user} != "" ]]; then
		_xb_backup_opts="${_xb_backup_opts} --user=${FLAGS_mysql_user}"
    fi	
    if [[ ${FLAGS_mysql_pwd} != "" ]]; then
		_xb_backup_opts="${_xb_backup_opts} --password=${FLAGS_mysql_pwd}"
    fi
	
    _xb_prepare_opts="--apply-log"
}

###################################################
# Preparem el archive absolute path.
#
# Args:
#     None
# Output:
#     Information on repository sub directory creation.
# Returns:
#     None
xb_prepare_archive_path() {
    local datestamp=$(date +%Y%m%d)
    local timestamp=$(date +%Y%m%d_%H%M)
    local archive_name="backup_${timestamp}.${_ARCHIVE_EXTENSION}"
    local archive_repository="${_backup_repository}/${datestamp}"
    if ! util_dir_exists "${archive_repository}"; then
		cmd "mkdir -pv ${archive_repository}"
    fi
    _xb_archive_path="${archive_repository}/${archive_name}"
}

###################################################
# Create the backup and prepare it.
#
# Args:
#     None
# Output:
#     None
# Returns:
#     None
xb_fs_backup() {	    
    if [[ ${FLAGS_verbose} -ge 1 ]]; then
		${_innobackupex_bin} ${_xb_backup_opts} "${FLAGS_tmp_dir}/backup" || return ${_EXEC_FAILURE}
		${_innobackupex_bin} ${_xb_prepare_opts} "${FLAGS_tmp_dir}/backup" || return ${_EXEC_FAILURE}
    else
		${_innobackupex_bin} ${_xb_backup_opts} "${FLAGS_tmp_dir}/backup" > /dev/null 2>&1 || return ${_EXEC_FAILURE}
		${_innobackupex_bin} ${_xb_prepare_opts} "${FLAGS_tmp_dir}/backup" > /dev/null 2>&1 || return ${_EXEC_FAILURE}
    fi
}

###################################################
# Create the compressed backup archive and send it
# to the backup repository.
#
# Args:
#     None
# Output:
#     None
# Returns:
#     None
xb_archive_backup() {
    if [[ ${FLAGS_verbose} -ge 1 ]]; then
		${_archiver_bin} -cpvzf "${FLAGS_tmp_dir}/backup.tar.gz" -C "${FLAGS_tmp_dir}/backup" . || return ${_EXEC_FAILURE}
    else
		${_archiver_bin} -cpzf "${FLAGS_tmp_dir}/backup.tar.gz" -C "${FLAGS_tmp_dir}/backup" . || return ${_EXEC_FAILURE}
    fi
    mv "${FLAGS_tmp_dir}/backup.tar.gz" "${_xb_archive_path}"
}

## ================================================
## MAIN
## ================================================
main() {
    #cbl_check_sudoers_permissions || bail "This script requires sudo permissions."
    xb_check_binaries
    
	util_dir_exists "${FLAGS_backup_repository}" || bail "Unable to locate backup repository: ${FLAGS_backup_repository}"
    util_create_dir "${FLAGS_tmp_dir}"
    
	xb_prepare_bkp_opts
    xb_prepare_archive_path
    
	msg_info "Starting full backup." && start_watch
    
	xb_fs_backup || bail "An exception occured while trying to use innobackupex."
	
    msg_info "Backup done in $(stop_watch) seconds."
    msg_info "Starting backup compression." && start_watch
    
	xb_archive_backup || bail "An exception occured while trying to archive the backup."
    
	msg_info "Backup archived in $(stop_watch) seconds."
    
	rm -rf "${FLAGS_tmp_dir}"
    
	exit ${_EXEC_SUCCESS}
}

main