import requests
from multiprocessing import Pool
import time

def sub_query(model, messages):
    session = requests.Session()
    json_data = {"model": model, "messages": messages}
    try:
        response = session.post(url, json=json_data)
        response.raise_for_status()
        res_text = response.json()
        final_response = res_text.get('choices', [{}])[0].get('message', {}).get('content')
        return final_response
    except (requests.exceptions.RequestException, ValueError):
        return None


def query_qwen(model_name, system_message, query_list, pool_num):
    response_list = []
    with Pool(pool_num) as pool:
        for query in query_list:
            messages = [{"role": "system", "content": system_message}, {"role": "user", "content": query}]
            async_result = pool.apply_async(func=sub_query, args=(model_name, messages))
            response_list.append(async_result)

        results = [ar.get() for ar in response_list]
        return results


if __name__ == '__main__':
    start_time = time.time()

    ip_address, port = '10.96.202.19', 8000
    url = 'http://%s:%d/v1/chat/completions' % (ip_address, port)

    model_name = "Qwen1.5-0.5B"
    system_message = "请你记住你的职业是学生。"
    query_list = ["你是什么职业？", "你是一名程序员吗？", "你是一名医生吗？", "你是一名学生吗？"]
    pool_num = 4

    responses = query_qwen(model_name, system_message, query_list, pool_num)
    
    for i, response in enumerate(responses, start=1):
        print(f'回答{i}:')
        print(response)
        print('=' * 100)
    
    end_time = time.time()
    print(f'耗时：{end_time - start_time}')
