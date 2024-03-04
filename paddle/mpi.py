import re
import subprocess

file_path = "/root/paddlejob/workspace/hostfile"  # 替换为文件的实际路径

with open(file_path, "r") as file:
    data = file.read()

ip_addresses = re.findall(r"\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}", data) # 可优化

demand_run = "mpirun -np 1 ssh {} 'bash -s' < /root/paddlejob/workspace/env_run/paddle/conf.sh"

# 启动并行进程执行 demand_run
run_processes = []
for ip in ip_addresses:
    command = demand_run.format(ip)
    print(command)
    process = subprocess.Popen(command, shell=True)
    run_processes.append(process)

# 等待所有 demand_run 进程完成
for process in run_processes:
    process.communicate()