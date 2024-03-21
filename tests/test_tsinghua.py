data_path = "/home/work/wenku_yq/weitianjun/data/thunovel/raw/THUNovel_15.jsonl"
import json


def test_tsinghua():
    with open(data_path, "r") as f:
        lines = f.read().split("\n")
        for line in lines:
            print(json.loads(line)["text"])


test_tsinghua()
