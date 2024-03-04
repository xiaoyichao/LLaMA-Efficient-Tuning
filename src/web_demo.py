from llmtuner import create_web_demo
import os

os.environ["CUDA_VISIBLE_DEVICES"] = "1"

def main():
    demo = create_web_demo()
    demo.queue()
    demo.launch(server_name="0.0.0.0", share=False, inbrowser=True)


if __name__ == "__main__":
    main()
