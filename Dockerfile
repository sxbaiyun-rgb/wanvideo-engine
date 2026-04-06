# 1. 采用 RunPod 官方的 PyTorch 极速底座
FROM runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04

# 2. 安装处理音视频必备的底层系统组件
RUN apt-get update && apt-get install -y ffmpeg git wget libgl1-mesa-glx

# 3. 将您的“黄金基因”复制进镜像
COPY requirements.txt /requirements.txt

# 4. 让镜像在打包时，一次性把所有依赖全装好
RUN pip install --no-cache-dir -r /requirements.txt
