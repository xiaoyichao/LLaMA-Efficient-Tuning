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
  "alpaca_gpt4_zh"
    # "novel_big"
	#"CompleFilt"
    # "Instructed"
    # COMMENT UNUSED DATASETS, OR FIRST WILL BE USED
)

models=( 
    "Qwen1.5-113B-Chat"
    # "ChatGLM3-6B-Base"
    # "Baichuan2-13B-Base"
    # "Baichuan2-13B-Chat"
    # "InternLM-20B"
    # "InternLM-Chat-20B"
    # "Qwen1.5-72B-Chat-AWQ"
    # "Qwen1.5-72B-Chat"
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

per_device_train_batch_size=2   # MAX 2 FOR Yi-34B on A100
zero_stage=3
num_train_epochs=8

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
  "Baichuan2-13B-Base")
    template="baichuan2"
    ;;
  "Baichuan2-13B-Chat")
    template="baichuan2"
    ;;
  "Qwen-14B")
    template="qwen"
    ;;
  "Qwen-14B-Chat")
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

TRAIN="""
deepspeed --hostfile=/root/paddlejob/workspace/hostfile --num_gpus 8 --master_port=9997 src/train_bash.py\
    --stage sft \
    --model_name_or_path ${model_path}/${model}\
    --do_train \
    --finetuning_type ${sft_type} \
    --dataset ${dataset} \
    --template ${template} \
    --output_dir ${checkpoint_path}/${dataset}/${model}_${datetime} \
    --logging_dir ${log_path}/${dataset}/${model}_${datetime}  \
    --overwrite_output_dir \
    --overwrite_cache \
    --save_strategy steps \
    --save_steps 128 \
    --save_total_limit 2 \
    --save_only_model \
    --per_device_train_batch_size ${per_device_train_batch_size} \
    --gradient_accumulation_steps 2 \
    --lr_scheduler_type cosine \
    --logging_steps 0.001 \
    --learning_rate 3e-5 \
    --num_train_epochs ${num_train_epochs}.00 \
    --cutoff_len 4096 \
    --warmup_steps 100 \
    --plot_loss \
    --bf16 \
    --preprocessing_num_workers 20 \
    --deepspeed configs/deepspeed/zero${zero_stage}-bf16.json \
    --torch_compile \
    --neftune_noise_alpha 5.0 \
    --save_on_each_node True
"""
if [ $((stage & 1)) -ne 0 ]; then
  echo "Start [TRAIN]"
  eval ${TRAIN}
  echo ${TRAIN} > ${checkpoint_path}/${dataset}/${model}_${datetime}/train.sh
  echo "Finish [TRAIN]"
fi


# INFERENCE
if [ $((stage & 2)) -ne 0 ]; then
  echo "Start [INFER]"
  gpu_id=0
  for gene in $(find configs/generation/ -maxdepth 1 -type f); do
  gen_type=$(basename ${gene} .json)
  
  if [ "$sft_type" = "lora" ]; then
  INFER="""
  mkdir -p ${archive_path}/prediction/${dataset}/${model}_${datetime}/${gen_type}/;
  GEN_CONFIG=${gene} \
  PROMPT_PATH="configs/template/${prompt}.r" \
  EVAL_DATA="data/eval/${dataset}_eval.jsonl" \
  OUT_PATH="${archive_path}/prediction/${dataset}/${model}_${datetime}/${gen_type}/" \
  CUDA_VISIBLE_DEVICES=${gpu_id} python src/chat_iter.py \
      --model_name_or_path ${model_path}/${model}/ \
      --template ${template} \
      --finetuning_type ${sft_type} \
      --adapter_name_or_path ${checkpoint_path}/${dataset}/${model}_${datetime}/ \
  """
  else
  INFER="""
  mkdir -p ${archive_path}/prediction/${dataset}/${model}_${datetime}/${gen_type}/;
  GEN_CONFIG=${gene} \
  PROMPT_PATH="configs/template/${prompt}.r" \
  EVAL_DATA="data/eval/${dataset}_eval.jsonl" \
  OUT_PATH="${archive_path}/prediction/${dataset}/${model}_${datetime}/${gen_type}/" \
  CUDA_VISIBLE_DEVICES=${gpu_id} python src/chat_iter.py \
      --model_name_or_path ${checkpoint_path}/${dataset}/${model}_${datetime}/ \
      --template ${template} \
      --finetuning_type ${sft_type} \
  """
  fi

  echo "INFER $(basename ${gene} .json) on GPU ${gpu_id}"
  eval ${INFER} &
  gpu_id=$((gpu_id+1))
  if [ $gpu_id -eq 8 ]; then
    gpu_id=0
  fi
  done
  wait
  echo ${INFER} > ${archive_path}/prediction/${dataset}/${model}_${datetime}/infer.sh
  if [ "$username" = "root" ]; then
    rsync -a ${archive_path}/prediction/${dataset}/${model}_${datetime} afs/archive/prediction/${dataset}
  fi
  echo "Finish [INFER]"
fi

# EVALUATION
EVAL="""
python src/auto_eval.py \
    --robot ${robot} \
    --task completion \
    --prompt baidu/query.json \
    --A ${archive_path}/completion/original \
    --B ${archive_path}/prediction/${dataset}/${model}_${datetime} \
    --output_dir ${archive_path}/evaluation/${dataset}/${model}_${datetime} \
"""

if [ $((stage & 4)) -ne 0 ]; then
  echo "Start [EVAL]"
  eval ${EVAL}
  echo ${EVAL} > ${archive_path}/evaluation/${dataset}/${model}_${datetime}/eval.sh
  echo "Finish [EVAL]"
fi

# LOOP
# Run on paddlecloud only to keep GPU usage
LOOP="""
deepspeed --hostfile=/root/paddlejob/workspace/hostfile --num_gpus 8 --master_port=9997 src/train_bash.py\
    --stage sft \
    --model_name_or_path ${model_path}/Qwen-14B-Chat\
    --do_train \
    --finetuning_type ${sft_type} \
    --dataset ${dataset} \
    --template ${template} \
    --output_dir ${checkpoint_path}/Loop \
    --logging_dir ${log_path}/${dataset}/${model}_${datetime}  \
    --overwrite_output_dir \
    --overwrite_cache \
    --save_strategy epoch \
    --save_total_limit 1 \
    --save_only_model \
    --per_device_train_batch_size 1 \
    --gradient_accumulation_steps 1 \
    --lr_scheduler_type cosine \
    --logging_steps 0.001 \
    --learning_rate 3e-5 \
    --num_train_epochs 10000000.0 \
    --cutoff_len 4096 \
    --warmup_steps 100 \
    --plot_loss \
    --bf16 \
    --preprocessing_num_workers 4 \
    --deepspeed configs/deepspeed/zero${zero_stage}-bf16.json \

"""
if [ $((stage & 8)) -ne 0 ]; then
  eval ${LOOP}
fi

echo "All done!"
