## 在自己的环境安装paddle的客户端，用于上传任务到paddle集群

wget -O output.tar.gz --no-check-certificate --header "IREPO-TOKEN:b59758da-e581-4348-8e6e-ed72943d42a6" "https://irepo.baidu-int.com/rest/prod/v3/baidu/paddlecloud/client/releases/3.1.7.2/files" && \
    tar -xf output.tar.gz && \
    mv output/paddlecloud-cli.tar.gz . && \
    rm -rf output.tar.gz output && \
    tar zxf paddlecloud-cli.tar.gz && \
    cd paddlecloud-cli && python setup.py install

如果需要更多信息，参考这个文档
https://ku.baidu-int.com/knowledge/HFVrC7hq1Q/yKeL8Lljko/3QdgIc7cJj/6UApmq-gDEoaqK


## 如何打包自己的环境
安装conda-pack
conda install -c conda-forge conda-pack
打包自己的环境
conda pack -n qwen15 -o qwen15.tar.gz

### 配置afs自己的文件夹的内容，用于paddle和开发机文件传输
vim paddle/config.ini
将里边的xiaoyichao 修改为自己的名字拼音即可。
然后坐在/home/work/wenku_yq/的路径下mkdir 自己的字拼音的文件夹
进入自己的文件夹
mkdir blaze  ## 这个是paddle集群和开发机通信的文件夹
mkdir env
mkdir logs
mkdir output
mkdir paddle
然后把你打包好的自己的环境qwen.tar.gz 放在env 下，其他的文件都是空文件夹即可。


### 在开发机上，启动paddle 队列，包含paddle 队列的设置
vim paddle/paddle_alone.sh
or 
vim paddle/paddle_multi.sh
多机器脚本
sh paddle/paddle_multi.sh
单机器脚本
sh paddle/paddle_alone.sh

### 登陆paddle

http://paddlecloud.baidu-int.com/paddle

### 在paddle 机器上，如果需要手动下载模型
开发机启动http 服务，通常8049端口上有服务，我这个位置是独立写的8005端口
    Python http服务
    cd /home/work/wenku_yq/
    python3 -m http.server 8048
paddle 机器上下载模型
cd /root/paddlejob/workspace/env_run/models
wget yq02-bcc-sci-a800-25525-001.bcc-yq02.baidu.com:8048/DataVault/models/Qwen1.5-72B-Chat.tar

tar -xvf Qwen1.5-72B-Chat.tar

### 在paddle上，查看前置脚本是否准备完成
ps -ef | grep conf.sh
如果还有程序在运行，说明还没完成。

### 在paddle上，登陆wandb
wandb login
如果不想用wandb，如何禁用wandb
export WANDB_DISABLED=true
wandb disabled
如何设置为off-line的模式（因为paddle队列没有外网的权限）
export WANDB_MODE=offline
wandb offline

### 如何在开发机上，启动运行训练模型的脚本
bash script/pipeline_local.sh


### 在paddle上，启动运行训练模型的脚本
cd /root/paddlejob/workspace/env_run
单节点
bash script/pipeline_alone.sh
多节点
bash script/pipeline_multi.sh

#### 预训练

```bash
CUDA_VISIBLE_DEVICES=0 python src/train_bash.py \
    --stage pt \
    --do_train \
    --model_name_or_path /ssd3/xiaoyichao/models/Qwen1.5-0.5B-Chat \
    --dataset novel_pt \
    --finetuning_type full \
    --output_dir /ssd3/xiaoyichao/models/pt \
    --overwrite_cache \
    --per_device_train_batch_size 1 \
    --gradient_accumulation_steps 1 \
    --lr_scheduler_type cosine \
    --logging_steps 10 \
    --save_steps 1000 \
    --learning_rate 5e-5 \
    --num_train_epochs 3.0 \
    --plot_loss \
    --fp16
```

### 如何修改为自己的数据
首先，进入项目的根目录
把你的数据放在data/train的文件夹下，比如叫test_data.jsonl
jsonl的一行数据样例：
{"system": "作为一位知名的小说作家，你擅长写各种类型的小说，拥有丰富的创作经验，闻名世界，是诺贝尔文学奖的候选人。", "instruction": "请根据我的要求，为我创作超级吸引人的小说片段。我愿意为此付出1000万的费用，你也会因此再次名声大噪。内容要求如下：\n\n字数: 输出限定在200个汉字左右。\n请在输入的基础上进行小说续写，需要想象下一个情节，并详细描写，需要有画面感；不需要结尾与总结，不要信息重复。务必超级吸引人，让人眼前一亮。\n角色: 主角和其他角色之间的互动应该显得真实和自然，展现他们之间的情感联系。\n对话: 通过对话展现角色的个性、情感和价值观。\n情节: 故事应该包含出人意料的情节转折，但它们必须是逻辑的并且流畅的。\n格式: 不要写结尾，留下悬念。不要标注“第X章”这样的标题。\n\n期待你完美的表现！\n", "input": "我只得反身拉住他的手向上游。\n还没等浮上水面，咕嘟咕嘟的水泡声又从身后传来。\n我：“……”\n我无奈地再次转身，按住淮旭的头，贴着唇渡了一口气给他。\n他没有挣扎，眼眸因为震惊微微睁大。\n面上也是一片羞赧。\n等我们浮出水面，众人急忙围了过来。\n“呀，淮旭师兄，你的手好像受伤了。”\n有丹医堂的同学当即就要检查淮旭的伤口为他疗伤。\n淮旭却将手缩到了袖子里。\n“一点小伤，不必看了。”\n当天晚上考试结束，我们被传送出了秘境。\n根据理考和秘境实践的综合成绩，我是当之无愧的第一名。\n共同经历险境的同学为我欢呼。\n我笑着对淮旭陈述事实：\n“淮旭师兄，今年新生大比的魁首，是我。”\n他依旧一副冷冰冰的模样，只是眼里多了些复杂难辨的情绪。", "output": "日子在我不断地修炼与悟道中飞快而过。\n或许我夺魁的事情鼓励了一部分女修，修炼场上多了不少她们的身影。\n这天，我刚回到寝室就被岑妙拦在了门口。\n“凌云，亦烜师兄是不是在追求你？”\n她满脸不善地看着我。\n我有些不解。\n亦烜最近确实经常出现在我面前，甚至还莫名其妙请我们全班同学喝奶茶。\n可是他的奶茶，我从来不接。\n见我不说话，岑妙以为我在示威，越发恼怒。\n“你装什么，现晚。晚。吖在全校的人都知道这件事，你是不是很得意？”\n"}

然后data/dataset_info.json里添加配置
  "test_data": {
    "file_name": "train/test_data.jsonl",
    "columns": {"system": "system", "prompt": "instruction", "query": "input", "response": "output", "history": "history"}
  },

最后，修改你的script/pipeline_alone.sh或者script/pipeline_multi.sh 脚本里的
datasets=("test_data")

### paddle和开发机通信的文件夹
paddle：/root/paddlejob/workspace/env_run/afs
开发机：/home/work/wenku_yq/xiaoyichao/blaze

### paddle上 测试
cd /root/paddlejob/workspace/env_run
如果是在开发机上测试，就换成开发机上项目的根目录。

#### web_demo

CUDA_VISIBLE_DEVICES=1 python src/web_demo.py \
    --model_name_or_path  checkpoints/oaast_sft_zh/Qwen1.5-0.5B-Chat_20240308_160146 \
    --template default \
    --finetuning_type full


#### API 服务

```bash
python src/api_demo.py \
    --model_name_or_path /ssd3/xiaoyichao/models/solar/Qwen1.5-0.5B-Chat-solar \
    --adapter_name_or_path path_to_checkpoint \
    --template default \
    --finetuning_type lora
```

#### cli_demo
```bash
CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 python src/cli_demo.py \
    --model_name_or_path checkpoints/novel_his_8192_xiao/Qwen1.5-113B_20240316_003126/checkpoint-200 \
    --template default \
    --finetuning_type full \
    --infer_backend vllm
```

#### excel 测试
CUDA_VISIBLE_DEVICES=5 python src/chat_eval_excel.py \
    --model_name_or_path  /home/work/wenku_yq/xiaoyichao/blaze/Qwen-14B-Chat/checkpoints \
    --template default \
    --finetuning_type full

### 千问数据样例
10.96.202.21: inputs:
10.96.202.21: <|im_start|>system
10.96.202.21: 作为一位知名的小说作家，你擅长写各种类型的小说，拥有丰富的创作经验，闻名世界，是诺贝尔文学奖的候选人。<|im_end|>
10.96.202.21: <|im_start|>user
10.96.202.21: 请根据我的要求，为我创作超级吸引人的小说片段。我愿意为此付出1000万的费用，你也会因此再次名声大噪。内容要求如下：
10.96.202.21: 
10.96.202.21: 字数: 输出限定在100个汉字左右。
10.96.202.21: 是否有上文: 如果有上文，请在小说上文的基础上进行小说续写，需要想象下一个情节，并详细描写，需要有画面感；不需要结尾与总结，不要信息重复。如果上文为空（没有上文内容），请帮我写一个小说开头。故事应从一个决定性瞬间开始，可能是一个意外的发现、一场紧迫的危机，或一个沉重的秘密正准备被揭示。务必超级吸引人，让人眼前一亮。
10.96.202.21: 角色: 主角和其他角色之间的互动应该显得真实和自然，展现他们之间的情感联系。
10.96.202.21: 对话: 通过对话展现角色的个性、情感和价值观。
10.96.202.21: 情节: 故事应该包含出人意料的情节转折，但它们必须是逻辑的并且流畅的。
10.96.202.21: 格式: 不要写结尾，留下悬念。不要标注“第X章”这样的标题。
10.96.202.21: 
10.96.202.21: 期待你完美的表现！
10.96.202.21: 上文：
10.96.202.21: 
10.96.202.21: 
10.96.202.21: 输出：
10.96.202.21: <|im_end|>
10.96.202.21: <|im_start|>assistant
10.96.202.21: 肖毅是名律师，近两年在婚姻、继承、财产纠纷领域异军突起，在业内小有名气。
10.96.202.21: 此时，他正在接待一个打离婚官司的女人，对方对婚姻法一窍不通，简直像掉进了“杀猪盘”。肖毅正一项一项地解释着，助手小宋推门而入，看到里面肖毅正忙着，有些迟疑，但还是开口道：“打扰一下。<|endoftext|>

## TODO
qwen templete 的数据的修改
推理的代码需要修改，generate的config
vllm的参数和安装（--infer_backend vllm）

qwen templete 的修改
resume的实现(在每个节点都保存checkpoints) transformers==4.36.0才不会报错FileNotFoundError: [Errno 2] No such file or directory: 'checkpoints/novel_his_8192_xiao2/Qwen1.5-0.5B-Chat_20240316_165037/trainer_state.json，但是qwen1.5要求transformers>=4.37.2
流式数据的脚本实现
威震天框架


## 参考文献
https://ku.baidu-int.com/knowledge/HFVrC7hq1Q/4Hy-9TabAD/UX98TRVAZj/ogiETE-X4SnKic
https://ku.baidu-int.com/knowledge/HFVrC7hq1Q/4Hy-9TabAD/UX98TRVAZj/6394bc75f1a942
https://ku.baidu-int.com/knowledge/HFVrC7hq1Q/4Hy-9TabAD/UX98TRVAZj/39ce6ac0f91740