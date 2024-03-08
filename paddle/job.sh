#!/bin/bash
# 系统环境变量 wiki: http://wiki.baidu.com/pages/viewpage.action?pageId=1053742013#2.4%20CaaS

mkdir -p ${TRAIN_WORKSPACE}/env_run/RECORD

world_size=${TRAINER_INSTANCES_NUM}
if [ $world_size -eq 1 ]; then
    bash paddle/conf.sh
else
    python paddle/mpi.py
fi

source ~/.bashrc

python -c "import time;
while True: time.sleep(5)
"
 