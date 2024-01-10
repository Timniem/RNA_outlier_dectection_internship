#!/bin/bash

eval "$(conda shell.bash hook)"
source /groups/umcg-gdio/tmp01/umcg-tniemeijer/envs/mamba-env/etc/profile.d/mamba.sh
mamba activate dashboard_env

panel serve run.py --port 7979