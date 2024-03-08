# !/bin/bash

datasets=(
    # "short_novel_info_1"
    # "short_novel_info_2"
    # "LongNovelZip_Completion,LongNovel_Completion,ShortNovel_Completion"
    "Instructed"
    # "oaast_sft_zh"
    # "Outline"
    # "short_novel_info"
    # "novel_gen"
)

models=( 
    # "ChatGLM3-6B"
    # "ChatGLM3-6B-Base"
    # "Baichuan2-13B-Base"
    # "Baichuan2-13B-Chat"
    # "InternLM-20B"
    # "Intern-Chat-20B"
    "Qwen-14B"
    # "Yi-34B"
    # "Yi-34B-Chat"
)
sft_types=(
    "lora"
    # "full"
)
template="qwen"

username=$(whoami)
echo "Hello $username! Start training today's Llama?"

if [ "$username" = "weitianjun" ]; then
    model_path="/home/work/wenku_yq/DataVault/models"
    checkpoint_path="/home/work/wenku_yq/weitianjun/blaze/checkpoints"
    log_path="/home/work/wenku_yq/weitianjun/blaze/logs"
    archive_path="archive"
else
    model_path="models"
    checkpoint_path="checkpoints"
    log_path="logs"
    archive_path="archive"
fi

dataset=${datasets[@]:0:1}
model=${models[@]:0:1}
sft_type=${sft_types[@]:0:1}

time="20231220_080543"
step=3

GEN_CONFIG="configs/generation/creative.json" \
PROMPT_PATH="configs/template/${prompt}.json" \
EVAL_DATA="data/novel_test.json" \
OUT_PATH="data/new.jsonl" \
CUDA_VISIBLE_DEVICES=7 python src/chat_iter.py \
    --model_name_or_path ${model_path}/${model} \
    --template ${template} \
    --finetuning_type ${sft_type} \
    --adapter_name_or_path ${checkpoint_path}/${dataset}/${model}_${time}/ \
