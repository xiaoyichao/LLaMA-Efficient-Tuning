'''
把短篇小说处理成预训练的数据
'''
import pandas as pd
import os

def get_dataset(excel_path):
    """
    从指定路径的Excel文件中读取'章节正文'列数据，并将其返回为一个列表。

    Args:
    excel_path: Excel文件路径

    Returns:
    一个包含'章节正文'列所有数据的列表。

    """
    df = pd.read_excel(excel_path)

    chapter_text = df["章节正文"].tolist()
    novel_name = df["小说名称"].tolist()

    return novel_name, chapter_text


def process_data(novel_name_list, chapter_text_list, out_file):
    """
    将章节文本按照小说名称进行分组，并写入到文件中。
    
    Args:
        novel_name_list (list): 小说名称列表。
        chapter_text_list (list): 章节文本列表。
        out_file (str): 输出文件路径。
    
    Returns:
        None
    
    """
    tmp_novel_name = ""
    tmp_chapter_text = ""
    for novel_name, chapter_text in zip(novel_name_list, chapter_text_list):
        if tmp_novel_name != novel_name:
            if tmp_novel_name != "":
                with open(out_file, "a") as f:
                    tmp_chapter_text = tmp_chapter_text.replace("\n", "")
                    f.write(tmp_chapter_text + "\n")
                print("写入数据：", tmp_novel_name)

            tmp_novel_name = novel_name
            tmp_chapter_text = chapter_text

        else:
            tmp_chapter_text += chapter_text
        

def clearn_txt(file_path):
    """
    删除指定路径下的文件。
    
    Args:
        file_path (str): 要删除的文件路径。
    
    Returns:
        None
    
    """
    try:
        os.remove(file_path)
        print(f"已删除文件: {file_path}")
    except FileNotFoundError:
        print(f"文件不存在: {file_path}")

if __name__ == '__main__':
    out_path=  "data/train/novel_pt.txt"
    clearn_txt(out_path)
    novel_name, chapter_text = get_dataset("data/raw/知乎.xlsx")
    process_data(novel_name, chapter_text, out_path)
    novel_name, chapter_text = get_dataset("data/raw/百度_淘宝.xlsx")
    process_data(novel_name, chapter_text, out_path)