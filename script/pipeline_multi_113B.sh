# !/bin/bash

################################
#        LLaMA-Factory         #
#  Train-Infernce-Evaluation   #
#      All-in-one Pipeline     #
#                              #
#         WEI TIANJUN          #
################################

######### VARIABLES ##########

stages=(
   1           # TRAIN
  # 2           # INFER
  # 4           # EVAL
  # 8           # LOOP
  # 3           # TRAIN-INFER
  # 6           # INFER-EVAL
  # 9           # TRAIN-LOOP
  # 10          # INFER-LOOP
  # 7           # TRAIN-INFER-EVAL
  # 11          # TRAIN-INFER-LOOP
  # 15          # TRAIN-INFER-EVAL-LOOP
  # 0           # UNCOMMENT TO RUN STAGES
)

datasets=(
  # "alpaca_gpt4_zh"
  "novel_his_8192_xiao"
	# "oaast_sft_zh"

)

models=( 
    "Qwen1.5-113B"
    # "ChatGLM3-6B-Base"
    # "Baichuan2-13B-Base"
    # "Baichuan2-13B-Chat"
    # "InternLM-20B"
    # "InternLM-Chat-20B"
    # "Qwen1.5-72B-Chat-AWQ"
    # "Qwen1.5-14B"
    # "Yi-34B"
    # "Yi-34B-Chat"
)

robots=(
  # "gpt-4"
  "gpt-4-1106-preview"
  # "gpt-3.5-turbo-1106"
  # FOR EVALUATION
)

prompts=(
  # "abs"
  # "system"
  # "plot"
  "full"
  # CREATE NEW TEMPLATE AT configs/template/*.r
)

datetimes=(
  `date +"%Y%m%d_%H%M%S"`
#   "20240116_115415"     # SPECIFY SAVED MODEL HERE
  # FOR NEW TRAINED MODEL, USE THE FIRST ONE
)

sft_types=(
    # "lora"
    # "freeze"
    "full"
)

########## CONFIG ##########
stage=${stages[@]:0:1}
dataset=${datasets[@]:0:1}
model=${models[@]:0:1}
robot=${robots[@]:0:1}
prompt=${prompts[@]:0:1}
sft_type=${sft_types[@]:0:1}
datetime=${datetimes[@]:0:1}
username=$(whoami)
echo "Hello $username! Start training today's Llama?"

if [ "$username" = "root" ]; then
    model_path="models"
    checkpoint_path="checkpoints"
    log_path="logs"
    archive_path="archive"
else
    model_path="/home/work/wenku_yq/DataVault/models"
    checkpoint_path="/home/work/wenku_yq/${username}/blaze/checkpoints"
    log_path="/home/users/${username}/logs"
    archive_path="archive"
fi

case $model in
  "ChatGLM3-6B")
    template="chatglm3"
    ;;
  "Qwen1.5-113B-Chat")
    template="qwen"
    ;;
  "Qwen1.5-113B")
    template="default"
    ;;
  "Qwen1.5-72B")
    template="qwen"
    ;;
  "Qwen1.5-72B-Chat")
    template="qwen"
    ;;
  "Yi-34B")
    template="yi"
    ;;
  "Yi-34B-Chat")
    template="yi"
    ;;
  *)
  template="default"
    ;;
esac

######### PREPROCESS ########

# ADD ANY PREPROCESS CODE HERE


########## RUNNING ##########
# TRAIN
# Multiple nodes ('nums_gpu' indicates num. of gpu per node): deepspeed --hostfile=/root/paddlejob/workspace/hostfile --num_gpus 4 --master_port=9997 src/train_bash.py \
# Single Node: deepspeed --include=localhost:1,3,4,5,6,7 --master_port=9997 src/train_bash.py \
# ,2,3,4,5,6,7
#     --save_strategy epoch \
#     --save_strategy steps \
#     --save_steps 8 \
# 
# afs/Qwen1.5-113B-Chat_20240309_034638/checkpoint-640
# checkpoints/oaast_sft_zh/Qwen1.5-113B-Chat_20240308_140157
#  ${model_path}/${model}
    # --streaming True\
    # --max_steps 30000 \

per_device_train_batch_size=2   # MAX 2 FOR Yi-34B on A100
zero_stage=3
num_train_epochs=16


TRAIN="""
deepspeed --hostfile=/root/paddlejob/workspace/hostfile --num_gpus 8 --master_port=9997 src/train_bash.py\
    --stage sft \
    --model_name_or_path ${model_path}/${model} \
    --do_train \
    --finetuning_type ${sft_type} \
    --dataset ${dataset} \
    --template ${template} \
    --output_dir ${checkpoint_path}/${dataset}/${model}_${datetime} \
    --logging_dir ${log_path}/${dataset}/${model}_${datetime}  \
    --overwrite_output_dir \
    --overwrite_cache \
    --save_strategy steps \
    --save_steps 100 \
    --save_total_limit 4 \
    --save_only_model \
    --per_device_train_batch_size ${per_device_train_batch_size} \
    --gradient_accumulation_steps 1 \
    --lr_scheduler_type cosine \
    --logging_steps 0.001 \
    --learning_rate 3e-5 \
    --num_train_epochs ${num_train_epochs}.00 \
    --cutoff_len 8192 \
    --warmup_steps 100 \
    --plot_loss \
    --bf16 \
    --preprocessing_num_workers 30 \
    --deepspeed configs/deepspeed/zero${zero_stage}-bf16.json \
    --torch_compile \
    --neftune_noise_alpha 5.0 \
    --flash_attn \
    --save_on_each_node True
"""
if [ $((stage & 1)) -ne 0 ]; then
  echo "Start [TRAIN]"
  eval ${TRAIN}
  echo ${TRAIN} > ${checkpoint_path}/${dataset}/${model}_${datetime}/train.sh
  echo "Finish [TRAIN]"
fi




echo "All done!"
