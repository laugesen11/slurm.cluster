#!/bin/bash

CONFIG_FILE="cluster.config"

# Make config file if not already there
[ ! -f $CONFIG_FILE ] && touch $CONFIG_FILE


show_help() {
    echo "Usage: $0 --CLUSTER_NAME <name> --MASTER_NAME <name> --CLUSTER_LOCATION <location> [options]"
    echo ""
    echo "  --cluster-name|-c <name>      Name of the cluster"
    echo "  --master-name|-m <name>       Name of the master node"
    echo "  --cluster-loc|-cl <path>      Cluster location"
    echo "  --bkup-master|-bm <name>      Backup master node"
    echo "  --slurm-user|-u <user>        SLURM user"
    echo "  --db-server|-d <server>       Database server"
    echo "  --db-passwd|-dp <passwd>      Database password"
    echo "  --db-user|-du <user>          Database user"
    echo "  --python-path|-p <path>       Python executable path"
    echo "  --no-sync-tools <flag>        No sync tools flag"
    echo "  --plugin-loc|-pl <location>   Plugin location"
    echo "  --jwk-key|-j <key>            Slurm JWK key"
    echo "  --jwk-passwd|-jp <passwd>     Slurm JWK password"
    echo ""
    exit 1
}

[ $# -eq 0 ] && show_help

# Parse arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --cluster-name|-c)  CLUSTER_NAME="$2"; shift 2 ;;
        --master-name|-m)   MASTER_NAME="$2"; shift; shift ;;
        --bkup-master|-bm)  BKUP_MASTER="$2"; shift; shift ;;
        --slurm-user|-u)    SLURM_USER="$2"; shift; shift ;;
        --db-server|-d)     DB_SERVER="$2"; shift; shift ;;
        --db-passwd|-dp)    DB_PASSWD="$2"; shift; shift ;;
        --db-user|-d)       DB_USER="$2"; shift; shift ;;
        --python-path|-p)   PYTHON_PATH="$2"; shift; shift ;;
        --no-sync-tools)    NO_SYNC_TOOLS=1; shift ;;
        --cluster-loc|-cl)  CLUSTER_LOCATION="$2"; shift; shift ;;
        --plugin-loc|-pl)   PLUGIN_LOC="$2"; shift; shift ;;
        --jwk-key|-j)       JWK_KEY="$2"; shift; shift ;;
        --jwk-passwd|-jp)   JWK_PASSWD="$2"; shift; shift ;;
        -h|--help)           show_help ;;
        *)                   echo "Unknown option $1"; show_help ;;
    esac
done

# Function to set or update a key/value in the config file
set_config_value() {
    local key="$1"
    local value="$2"
    if grep -q "^${key}=" "$CONFIG_FILE" 2>/dev/null; then
        sed -i'.bak' "s|^${key}=.*|${key}=${value}|" "$CONFIG_FILE"
    else
        echo "${key}=${value}" >> "$CONFIG_FILE"
    fi
}

# Set/update optional values if provided
[[ -n "$CLUSTER_NAME" ]]     && set_config_value "CLUSTER_NAME" "$CLUSTER_NAME"
[[ -n "MASTER_NAME" ]]     && set_config_value "MASTER_NAME" "$MASTER_NAME"
[[ -n "CLUSTER_LOCATION" ]]     && set_config_value "CLUSTER_LOCATION" "$CLUSTER_LOCATION"
[[ -n "$BKUP_MASTER" ]]     && set_config_value "BKUP_MASTER" "$BKUP_MASTER"
[[ -n "$SLURM_USER" ]]      && set_config_value "SLURM_USER" "$SLURM_USER"
[[ -n "$DB_SERVER" ]]       && set_config_value "DB_SERVER" "$DB_SERVER"
[[ -n "$DB_PASSWD" ]]       && set_config_value "DB_PASSWD" "$DB_PASSWD"
[[ -n "$DB_USER" ]]         && set_config_value "DB_USER" "$DB_USER"
[[ -n "$PYTHON_PATH" ]]     && set_config_value "PYTHON_PATH" "$PYTHON_PATH"
[[ -n "$NO_SYNC_TOOLS" ]]   && set_config_value "NO_SYNC_TOOLS" "$NO_SYNC_TOOLS"
[[ -n "$PLUGIN_LOC" ]]      && set_config_value "PLUGIN_LOC" "$PLUGIN_LOC"
[[ -n "$JWK_KEY" ]]         && set_config_value "JWK_KEY" "$JWK_KEY"
[[ -n "$JWK_PASSWD" ]]      && set_config_value "JWK_PASSWD" "$JWK_PASSWD"

echo "Configuration updated successfully in $CONFIG_FILE"
