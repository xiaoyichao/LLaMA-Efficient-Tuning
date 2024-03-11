import pandas as pd


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
    tmp_novel_name = ""
    tmp_chapter_text = ""
    for novel_name, chapter_text in zip(novel_name_list, chapter_text_list):
        if tmp_novel_name != novel_name:
            tmp_chapter_text += chapter_text
        else:
            tmp_chapter_text = ""
            tmp_novel_name = ""
            with open(out_file, "a") as f:
                f.write(tmp_chapter_text + "\n")

if __name__ == '__main__':
    novel_name, chapter_text = get_dataset("data/raw/知乎.xlsx")
    process_data(novel_name, chapter_text, "data/train/processed_data.txt")