#!/bin/bash

# 综合性能监控脚本
echo "=== MPI + NCCL 系统性能监控 ==="
echo "开始时间: $(date)"

# 1. GPU状态
echo -e "\n=== GPU 状态 ==="
nvidia-smi --query-gpu=index,name,utilization.gpu,utilization.memory,memory.used,memory.total,temperature.gpu --format=csv

# 2. 网络接口状态
echo -e "\n=== 网络接口状态 ==="
for iface in $(ls /sys/class/net/ | grep -E '^(eth|ens|efa)'); do
    echo "接口: $iface"
    cat /sys/class/net/$iface/statistics/rx_bytes | awk '{print "  RX: " $1/1024/1024 " MB"}'
    cat /sys/class/net/$iface/statistics/tx_bytes | awk '{print "  TX: " $1/1024/1024 " MB"}'
done

# 3. CPU和内存
echo -e "\n=== CPU 和内存使用率 ==="
top -bn1 | grep "Cpu(s)" | awk '{print "CPU使用率: " $2}'
free -h | grep "Mem:" | awk '{print "内存使用: " $3 "/" $2}'

# 4. EFA状态（如果存在）
echo -e "\n=== EFA 状态 ==="
if command -v fi_info &> /dev/null; then
    fi_info -p efa | head -10
else
    echo "EFA工具未安装"
fi

# 5. NCCL环境变量
echo -e "\n=== NCCL 环境变量 ==="
env | grep NCCL | sort

echo -e "\n监控完成时间: $(date)"
