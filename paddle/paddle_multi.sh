# !/bin/bash
# Paddlecloud Configuration

time=`date +"%Y-%m-%d_%H-%M-%S"`
job="TRAIN_${time}"
# ------------------------
group_name="wenku_train_query"
job_conf="paddle/config.ini"
start_cmd=". paddle/job.sh"
file_dir="."
job_version="pytorch-1.7.1"
k8s_trainers=3
k8s_gpu_cards=8
algo_id=algo-b246a6f3c20940b8

ak='09d5444054c15494ab0107bdcd077916'
sk='0f887b3ba5de559abe793978ca4b961b'

paddlecloud job --ak $ak --sk $sk \
    train --job-name $job \
    --group-name $group_name \
    --job-conf "$job_conf" \
    --start-cmd "$start_cmd" \
    --file-dir $file_dir \
    --job-version $job_version \
    --k8s-trainers $k8s_trainers \
    --k8s-gpu-cards $k8s_gpu_cards \
    --algo-id $algo_id \
    --is-standalone 0
