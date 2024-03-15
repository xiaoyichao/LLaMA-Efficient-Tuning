#!/bin/bash
cd /root/paddlejob/workspace/env_run/models

cat << EOF > ./Qwen1.5-113B/config.json
{
  "_name_or_path": "./models/Qwen1.5-113B",
  "architectures": [
    "Qwen2Model"
  ],
  "attention_dropout": 0.0,
  "bos_token_id": 151643,
  "eos_token_id": 151643,
  "hidden_act": "silu",
  "hidden_size": 8192,
  "initializer_range": 0.02,
  "intermediate_size": 24576,
  "max_position_embeddings": 32768,
  "max_window_layers": 70,
  "model_type": "qwen2",
  "num_attention_heads": 64,
  "num_hidden_layers": 128,
  "num_key_value_heads": 64,
  "rms_norm_eps": 1e-06,
  "rope_theta": 1000000.0,
  "sliding_window": 32768,
  "tie_word_embeddings": false,
  "torch_dtype": "float32",
  "transformers_version": "4.37.2",
  "use_cache": true,
  "use_sliding_window": false,
  "vocab_size": 152064
}
EOF

cp ./Qwen1.5-72B/configuration.json ./Qwen1.5-113B/
cp ./Qwen1.5-72B/generation_config.json ./Qwen1.5-113B/
cp ./Qwen1.5-72B/merges.txt ./Qwen1.5-113B/
cp ./Qwen1.5-72B/README.md ./Qwen1.5-113B/
cp ./Qwen1.5-72B/tokenizer_config.json ./Qwen1.5-113B/
cp ./Qwen1.5-72B/tokenizer.json ./Qwen1.5-113B/
cp ./Qwen1.5-72B/vocab.json ./Qwen1.5-113B/