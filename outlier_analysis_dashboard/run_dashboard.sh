#!/bin/bash

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--port)
            PORT="$2"
            shift # past argument
            shift # past value
            ;;
        -d|--data)
            DATA="$2"
            shift # past argument
            shift # past value
            ;;
        -*|--*)
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1") # save positional arg
            shift # past argument
            ;;
    esac
done
set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

eval "$(conda shell.bash hook)"
source /groups/umcg-gdio/tmp01/umcg-tniemeijer/envs/mamba-env/etc/profile.d/mamba.sh
mamba activate dashboard_env

fraser_data="${DATA}/*fraser.tsv"
outrider_data="${DATA}/*outrider.tsv"
mae_data="${DATA}/*mae.tsv"

panel serve run.py --port $PORT --args $fraser_data $outrider_data $mae_data 