from llmtuner import run_exp
import wandb

# wandb.init(mode="online")
wandb.init(mode="offline")

def main():
    run_exp()


def _mp_fn(index):
    # For xla_spawn (TPUs)
    main()


if __name__ == "__main__":
    main()
