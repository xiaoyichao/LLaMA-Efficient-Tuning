from transformers import AutoModelForCausalLM, AutoTokenizer
import os

os.environ["CUDA_VISIBLE_DEVICES"] = "1"
device = "cuda" # 加载模型的设备

model_path = "checkpoints/oaast_sft_zh/Qwen1.5-0.5B-Chat_20240308_120258"

model = AutoModelForCausalLM.from_pretrained(
    model_path,
    device_map="auto"
)
tokenizer = AutoTokenizer.from_pretrained(model_path)

prompt = "给我介绍一下大型语言模型。"
messages = [
    {"role": "system", "content": "你是一个有用的助手。"},
    {"role": "user", "content": prompt}
]
text = tokenizer.apply_chat_template(
    messages,
    tokenize=False,
    add_generation_prompt=True
)
model_inputs = tokenizer([text], return_tensors="pt").to(device)

generated_ids = model.generate(
    model_inputs.input_ids,
    max_new_tokens=512
)
generated_ids = [
    output_ids[len(input_ids):] for input_ids, output_ids in zip(model_inputs.input_ids, generated_ids)
]

response = tokenizer.batch_decode(generated_ids, skip_special_tokens=True)[0]
print(response)
