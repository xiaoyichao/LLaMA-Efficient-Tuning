def gen_character():
    """
    生成人物
    """
    pass

def gen_plot():
    """
    生成章节概要
    """
    pass

def gen_story():
    """
    生成故事
    """
    prompt = """I need you to write a part of a novel. You will receive a inout in JSON format containing information about the novel you are wrtiting. You need to follow the steps below to complete your thinking and writing process.
    1. Learn about the backgrounds and relationships of the main characters in the novel from the "人物设定" field.
    2. Grasp the current story development from the "前序情节" field.
    3. Familiarize yourself with the language style of the novel from the "上一部分正文" field.
    4. Expand the plot summary in the "当前情节" field into the main text of the novel.
    Reminder:
    You should keep the continuity of what your write with the content in the "上一部分正文" field.
    Avoid repeating content from the "上一部分正文" field.
    Do not include plots beyond what is described in the "当前情节" field.
    Write the novel in the view described in the "人称视角" field.
    Write the novel in Chinese.

    Here is the input:
    {
    "人称视角": "江发财的第一人称视角“我”",
    "人物设定": "1. 江发财：本作主角，农民出身的大学生。他坚韧不拔、机智勇敢，在面对困难时总能保持乐观态度。他揭露了孙轩虚假的身份，并成功地打造了自己的事业。
2. 孙轩：富二代室友，实际上是食堂管理员孙嫂的儿子。他虚伪、阴险、自私，并且经常欺凌江发财。最后因为赌博陷入困境，堕落至乞丐。
3. 张小枫、李钱：孙轩的狗腿子，善于奉承并对江发财进行歧视和嘲笑。
4. 蔡强：江发财在大学期间结识的好朋友。他忠诚可靠，并与江发财一起创业成功。
5. 孙嫂：食堂管理员，也是孙轩的母亲。她善良但稍显无知，在得知真相后感到深深愧疚并回到老家种地。",
    "前序情节": "新生江发财在大一开学时来到宿舍，遇到了富二代室友孙轩和两个狗腿子张小枫、李钱。他们对江发财的农民身份嘲笑不已，甚至因为他的行李箱“带泥巴”而让孙轩“晕倒”。尽管受到歧视和嘲笑，江发财依然保持随和态度，准备开始他的大学生活。而孙轩则继续炫耀自己的贵族生活，引得张小枫和李钱无比崇拜。",
    "当前情节": "在一早起床后，主角发现同学孙轩的桌子上有他父母的合影，误以为父母瞒着他养了私生子。他质问父母后被否认，同时揭示出家族在澳洲、荷兰拥有大量农场和牧场的事实。",
    "上一部分正文": "底下一声声地恭维打破了安静。
“天啊，跟着少爷有肉吃。”
“对啊，我们这么快就享福了。谢谢少爷。”
这时候，宿舍才逐渐安静了下来。
而我一夜好梦。",
}
    Now, you can start to write the novel.
    """

def beautify_story():
    """
    生成故事
    """
    prompt = """"""