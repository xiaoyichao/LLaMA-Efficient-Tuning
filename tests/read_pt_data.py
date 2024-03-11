'''
读取预训练的数据
'''

with open('data/wiki_demo.txt', 'r') as f:
    """
    现在看，预训练的数据，就是一个数据放一行。t
    """    
    data = f.read()
    data = data.split('\n')
    print(len(data))


import pandas as pd

df = pd.read_excel('your_excel_file.xlsx')

chapter_text = df['章节正文'].tolist()

for text in chapter_text:
    if text is not None:
        print(text)
