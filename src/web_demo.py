from llmtuner import create_web_demo
import os

# os.environ["CUDA_VISIBLE_DEVICES"] = "1"
'''
python src/web_demo.py \
    --model_name_or_path checkpoints/alpaca_gpt4_zh/Qwen1.5-113B-Chat_20240307_225135 \
    --template default \
    --finetuning_type full
'''

def main():
    demo = create_web_demo()
    demo.queue()
    demo.launch(server_name="0.0.0.0", share=True, inbrowser=True)


if __name__ == "__main__":
    main()
