python src/export_model.py \
    --model_name_or_path /home/work/wenku_yq/DataVault/models/Baichuan2-13B-Base \
    --adapter_name_or_path /home/work/wenku_yq/weitianjun/blaze/checkpoints/CompleSimp/Baichuan2-13B-Base_20231212_100344 \
    --template completion \
    --finetuning_type lora \
    --export_dir /home/work/wenku_yq/weitianjun/export/BaichuanCompletion \
    --export_size 2