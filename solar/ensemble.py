'''
solar 模型的思路，集联模型
'''

import torch
from transformers import AutoModel


def total_params(model):
    """
    计算模型参数总数
    
    Args:
        model (torch.nn.Module): 待计算参数总数的模型
    
    Returns:
        int: 模型参数总数
    
    """
    total_params = sum(p.numel() for p in model.parameters())
    print(f"Total Parameters: {total_params}")


def modify_and_merge_models(model_path):

    # 加载预训练的模型
    print("Loading model...")
    model_head = AutoModel.from_pretrained(model_path)
    total_params(model_head)

    print("第一个模型加载完成")
    model_tail = AutoModel.from_pretrained(model_path)
    print("第二个模型加载完成")
    # 去掉前16层和后16层
    modified_layers_tail = model_head.layers[16:]  # 去掉前16层
    modified_layers_head = model_tail.layers[:-16]  # 去掉后16层

    # 将剩下的层合并
    merged_layers = torch.nn.ModuleList(modified_layers_head + modified_layers_tail)

    # 创建一个新的模型以存储合并后的层
    print("创建一个新的模型以存储合并后的层, Loading model...")
    merged_model = AutoModel.from_pretrained(model_path)  # 重新加载一个模型作为基础
    merged_model.layers = merged_layers  # 用合并后的层替换

    total_params(merged_model)

    return merged_model

def save_model(model, save_path):
    """
    保存模型到本地
    
    Args:
        model (object): 需要保存的模型对象
        save_path (str): 保存模型的路径
    
    Returns:
        None
    
    """
    model.save_pretrained(save_path)
    print("模型保存完成")

if __name__ == "__main__":
    # 模型路径
    model_path = "./models/Qwen1.5-72B"
    save_path = "./models/Qwen1.5-113B"

    # 修改和合并模型
    merged_model = modify_and_merge_models(model_path)

    # 保存模型
    save_model(merged_model, save_path)


