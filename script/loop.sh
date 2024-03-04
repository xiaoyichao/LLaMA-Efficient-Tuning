# !/bin/bash
# Train

username=$(whoami)
echo "Hello $username! Start training today's Llama?"

if [ "$username" = "weitianjun" ]; then # Change
    model_path="/home/work/wenku_yq/DataVault/models/"
    checkpoint_path="/home/work/wenku_yq/weitianjun/checkpoints/"
else
    model_path="models/"
    checkpoint_path="checkpoints/"
fi

deepspeed --include=localhost:0,1,2,3,4,5,6,7 --master_port=9996 src/train_bash.py \
    --stage sft \
    --model_name_or_path ${model_path}/Yi-34B\
    --do_train \
    --finetuning_type full \
    --dataset CompleFilt \
    --template default \
    --output_dir ${checkpoint_path}/Loop \
    --overwrite_output_dir \
    --overwrite_cache \
    --per_device_train_batch_size 2 \
    --gradient_accumulation_steps 1 \
    --lr_scheduler_type cosine \
    --logging_steps 100000000 \
    --learning_rate 3e-5 \
    --save_strategy no \
    --num_train_epochs 1000000.0 \
    --cutoff_len 3072 \
    --plot_loss \
    --bf16 \
    --preprocessing_num_workers 4 \
    --deepspeed configs/deepspeed/zero2-bf16.json \
