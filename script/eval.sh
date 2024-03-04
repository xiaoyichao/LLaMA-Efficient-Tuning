# !/bin/bash

datasets=(
    # "short_novel_info_1"
    # "short_novel_info_2"
    "short_novel_info"
    # "novel_gen"
)

robots=(
  # "gpt-4"
#   "gpt-4-1106-preview"
  "gpt-3.5-turbo-1106"
#   "EB4"
)


robot=${robots[@]:0:1}
dataset=${datasets[@]:0:1}

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

    # EVAL="""
    #     python src/auto_eval.py \
    #         --robot ${robot} \
    #         --task completion \
    #         --prompt baidu/query.json \
    #         --A ${archive_path}/completion/original \
    #         --B ${archive_path}/prediction/${dataset}/Baichuan_LoRA64_15EP_FP16 \
    #         --output_dir ${archive_path}/evaluation/${dataset}/Baichuan_LoRA64_15EP_FP16 \
    #     """
    # eval ${EVAL}


x=($(find ${archive_path}/prediction/${dataset} -mindepth 1 -maxdepth 1 -type d))

for i in {1..$((${#x[@]}-1))}; do
    for j in {$((${i}+1))..$((${#x[@]}))}; do
        if [[ "${x[i]}" != "${x[j]}" ]] && [ ! -e "${archive_path}/evaluation/${dataset}/${x[i]:t}+${x[j]:t}" ] && [ ! -e "${archive_path}/evaluation/${dataset}/${x[j]:t}+${x[i]:t}" ]; then
            echo "Evaluating ${x[i]:t} and ${x[j]:t}"
            EVAL="""
                python src/auto_eval.py \
                    --robot ${robot} \
                    --task completion \
                    --prompt baidu/query.json \
                    --A ${x[i]} \
                    --B ${x[j]} \
                    --output_dir ${archive_path}/evaluation/${dataset}/${x[i]:t}+${x[j]:t} \
                """
            eval ${EVAL}
        fi
    done
done