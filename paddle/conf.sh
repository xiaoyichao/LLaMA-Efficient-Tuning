#!/bin/bash

fs_name="afs://wudang.afs.baidu.com:9902"
fs_ugi="wenkuai-afs-online,wenkuai-afs-online"
mount_afs="true"

# 设置自定义的python包
is_auto_unzip=1
export PYTHON_HOME=${TRAIN_WORKSPACE}/env_run/thirdparty
export LD_LIBRARY_PATH=${PYTHON_HOME}/lib:${LD_LIBRARY_PATH}
export PATH=${PYTHON_HOME}/bin:${PATH}
export CUDA_PATH=/usr/local/cuda

current_rank_index=${POD_INDEX}
rank_0_ip=${POD_0_IP}
IFS=',' read -r -a pod_0_ip_port <<< "$TRAINER_IP_PORT_LIST"
IFS=':' read -r -a arr <<< "${pod_0_ip_port[0]}"
free_port="${arr[1]}"
dist_url="tcp://${rank_0_ip}:${free_port}"
world_size=${TRAINER_INSTANCES_NUM}
echo "current_rank_index: ${current_rank_index}"
echo "dist_url: ${dist_url}"
echo "world_size: ${world_size}"

lsof -i:${free_port}


# 配置环境变量
echo 'export PATH="/root/paddlejob/workspace/env_run/thirdparty/bin:$PATH"' >> ~/.bashrc
echo 'export mac="yq02-bcc-sci-a800-25525-001.bcc-yq02.baidu.com:8049/"' >> ~/.bashrc
source ~/.bashrc

# 主机和端口
host="yq02-bcc-sci-a800-25525-001.bcc-yq02.baidu.com"
port="8049"

mkdir -p /root/paddlejob/workspace/env_run/tools
cd /root/paddlejob/workspace/env_run/tools

# 工具文件列表
tools=(
    "tools/screen_4.6.2-1ubuntu1.1_amd64.deb.tar"
    "tools/pdsh-2.34.tar.gz"
    "tools/cuda_11.8.0_520.61.05_linux.run"
    "tools/flash-attention.tar"
)

# 模型文件列表
models=(
    "models/Qwen1.5-14B.tar"
    # "models/Qwen1.5-72B-Chat-AWQ"
    "models/Qwen1.5-72B-Chat.tar"
    # "models/Yi-34B-Chat.tar"
    # "models/Baichuan2-13B-Base.tar"
)

# 下载并解压工具文件
for file in "${tools[@]}"; do
    if [ -e "$file" ]; then
        echo -e "\e[32;1m文件已存在: $file，跳过下载和解压\e[0m"
    else
        wget -q "$host:$port/$file"
        file_name=${file#*/}
        tar xf "$file_name"
        echo -e "\e[32;1m解压文件: $file_name\e[0m"
    fi
done

# 解压并安装pdsh
cd pdsh-2.34
./configure --with-ssh --with-rsh --with-mrsh --with-mqshell --with-dshgroups --with-machines=/etc/pdsh/machines
make && make install

# 解压并安装screen
cd ..
dpkg -i screen_4.6.2-1ubuntu1.1_amd64.deb

# 启动crontab
mkdir -p /root/paddlejob/workspace/env_run/afs/logs
service cron start
(crontab -l ; echo "*/10 * * * * bash /root/paddlejob/workspace/env_run/paddle/cronjob.sh") | crontab

# 安装python依赖包

pip install transformers==4.37.2
pip install transformers-stream-generator           # Qwen
pip install --no-deps triton==2.0.0
pip install trl==0.7.6
pip install peft==0.8.2
pip install wandb==0.16.2

# 安装CUDA
cd /root/paddlejob/workspace/env_run/tools
sh cuda_11.8.0_520.61.05_linux.run --silent --toolkit --override \
    --toolkitpath=/root/paddlejob/workspace/env_run/tools/cuda-11.8/ \
    --defaultroot=/root/paddlejob/workspace/env_run/tools/cuda-11.8/ \

echo 'export PATH="/root/paddlejob/workspace/env_run/tools/cuda-11.8/bin:$PATH"' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH="/root/paddlejob/workspace/env_run/tools/cuda-11.8/lib64:$LD_LIBRARY_PATH"' >> ~/.bashrc
echo 'export CUDA_HOME="/root/paddlejob/workspace/env_run/tools/cuda-11.8"' >> ~/.bashrc
source ~/.bashrc

# 安装flash-attention
cd /root/paddlejob/workspace/env_run/tools/flash-attention
MAX_JOBS=16 python setup.py install
cd csrc/layer_norm && pip install .

# 创建目录
mkdir -p /root/paddlejob/workspace/env_run/models
cd /root/paddlejob/workspace/env_run/models


# 下载并解压模型
for file in "${models[@]}"; do
    if [ -e "$file" ]; then
        echo -e "\e[32;1m文件已存在: $file，跳过下载和解压\e[0m"
    else
        wget -q "$host:$port/$file"
        file_name=${file#*/}
        tar xf "$file_name"
        echo -e "\e[32;1m解压文件: $file_name\e[0m"
    fi
done

rm -f *.tar