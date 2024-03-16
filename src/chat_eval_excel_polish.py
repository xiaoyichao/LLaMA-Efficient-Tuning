import pandas as pd
import os
import json
from tqdm import tqdm
from llmtuner import ChatModel
from llmtuner.extras.misc import torch_gc
from transformers.generation import GenerationConfig

''''
CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 python src/chat_eval_excel_polish.py \
    --model_name_or_path  /ssd3/xiaoyichao/models/Qwen1.5-0.5B-Chat \
    --template default \
    --finetuning_type full
'''

# os.environ["CUDA_VISIBLE_DEVICES"] = "0,1,2,3,4,5,6,7"

INPUT_PATH = 'data/eval/polish/eval_data.xlsx'
OUT_PATH = 'data/archive/prediction/polish/polish_eval.xlsx'
GEN_CONFIG = 'configs/generation/polish.json'

chat_model = ChatModel()

gen_config = chat_model.engine.generating_args
gen_config.update(json.loads(open(GEN_CONFIG).read()))
print("gen_config:", chat_model.engine.generating_args)


# chat_model.generating_args.max_length = 4096
# chat_model.generating_args.max_new_tokens = 4096


def eval():
    """
    对指定excel文件中的数据进行润色处理，并将结果保存到新的excel文件中。
    """
    cnt = 0
    cnt_err = 0

    # 读取excel文件
    df = pd.read_excel(INPUT_PATH)

    for index, row in tqdm(df.iterrows()):
        input_data = row[19]  # 未润色正文
        node = row[17]
        novel_id = row[1]
        gt = row[3]
        story_info = row[6]  # 故事梗概
        role_info = row[7]  # 人物介绍

        if error_case(node, input_data):
            cnt_err += 1
            df.at[index, 'polish'] = "-1"
            continue
        cnt += 1

        query_content = build_query_addition(role_info, story_info, input_data)
        messages = [{"role": "user", "content": query_content}]
        response_text = ""
        for new_text in chat_model.stream_chat(messages):
            print(new_text, end="", flush=True)
            response_text += new_text
        df.at[index, 'polish'] = response_text

        # clear
        torch_gc()
        print("History has been removed.")

    df.to_excel(OUT_PATH, index=False)

    print("处理数据: ", cnt)
    print("触发风控: ", cnt_err)


def error_case(node, input_data):
    """
    触发风控
    """
    if node is None or node == '' or str(node) == '-1':
        return True
    if input_data is None or input_data == '' or input_data == '触发风控。' or str(input_data) == 'nan' or str(
            input_data) == '-1':
        return True
    return False


def build_query_addition(role_info, story_info, story_input):
    """
    根据角色信息和故事信息，构建查询语句，用于润色短篇小说。

    Args:
        role_info (str): 角色信息，包含人物介绍等。
        story_info (str): 故事信息，包含故事梗概等。
        story_input (str): 需要润色的短篇小说内容。

    Returns:
        str: 润色后的短篇小说内容，包含系统提示、写作要求和输入输出部分。

    """
    prompt_sys = "你是一名网络小说作家，擅长润色小说。\n\n"
    prompt_ins = '根据**写作要求**及**短篇小说的特点**，润色输入的内容，使其更像短篇小说。\n\n**写作要求**\n1. 第一人称视角书写。\n2. 尽可能多地加入对话、动作描写、人物描写、细节描写等内容，使小说更加生动有趣。\n3. 不要回答和本章内容无关的任何其他文字，如带点的标题, 第x章等。\n4. 作为中间章节，要保持与前面情节的一致性。\n5.你需要记住<人物介绍>中人物的特点和<故事梗概>中的全文故事情节，保证原本的故事发展顺序和情节内容。\n6.尽量不要复述上文的语句。\n\n**短篇小说的特点**\n1. 结构和焦点：短篇小说由于篇幅限制，结构通常更为紧凑，焦点集中。它们倾向于通过一个清晰的、集中的情节来传达强烈的情感或揭示人性的某个方面，往往以一个意想不到的转折或启示作为高潮。\n2. 角色发展：在短篇小说中，角色的发展空间相对有限。作者需要在短时间内建立角色，并通过精准的细节和对话来展示角色的性格。这意味着短篇小说中的角色往往更加集中于表达特定的主题或情感。\n3. 主题和象征：短篇小说经常利用象征和隐喻来加深主题的表达，这些技巧帮助压缩故事的情感和哲学深度，使得短篇小说即便篇幅短小也能留下深刻的印象。\n4. 叙述方式：短篇小说的叙述方式通常更为直接和集中，旨在迅速建立情境并引导读者进入故事核心。短篇小说往往采用更加精炼和象征性的语言。\n5. 语言表达：口语化、少用文学性强的四字词语等。\n\n<人物介绍>\n{}\n\n<故事梗概>\n{}\n\n'
    prompt_input = "输入: \n\n{}\n\n输出:\n\n"

    cur_ins = prompt_ins.format(role_info, story_info)
    cur_input = prompt_input.format(story_input)
    return prompt_sys + cur_ins + cur_input


if __name__ == "__main__":
    eval()
