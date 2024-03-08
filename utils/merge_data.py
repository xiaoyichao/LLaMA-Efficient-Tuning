
'''
合并多个json文件
'''
import json
import random


def merge_json_data(json_file_list, out_file='data/train/short_story.json'):
    """Merges JSON data from two files and optionally shuffles and writes the result.

    Args:
        json_file: Path to the first JSON file.
        json_file2: Path to the second JSON file.
        out_file: Path to the output file (optional). Defaults to 'data/train/short_story.json'

    Returns:
        The merged JSON data as a list of dictionaries.
    """
    merge_data = []
    for json_file in json_file_list:
        with open(json_file) as f:
            data = json.load(f)
        print("当前data的数据长度",len(data))
        merge_data.extend(data)

    # Shuffle the merged data for randomization
    random.shuffle(merge_data)

    # Write to output file if specified
    with open(out_file, 'w', encoding='utf-8') as json_file:
        json.dump(merge_data, json_file, indent=2, ensure_ascii=False)
    print("合并的数据长度",len(merge_data))
    print('done!')
#   return data


if __name__ == '__main__':
    json_file_list = ['data/train/novel_all_240305.json', 'data/train/polish_his_0308.json', 'data/oaast_sft_zh.json']
    # json_file_list = ['data/oaast_sft_zh.json']
    data = merge_json_data(json_file_list, 'data/train/novel_all.json')

    