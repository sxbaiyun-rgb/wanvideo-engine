# 1. 采用 RunPod 官方的 PyTorch 底座
FROM runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04

# 2. 安装处理音视频必备的底层系统组件
RUN apt-get update && apt-get install -y ffmpeg git wget libgl1-mesa-glx

# 3. 【核心进化：5090 满血驱动】先卸载自带的老旧版本，再强制打入适配 50系最新架构的 CUDA 12.8 (cu128) 引擎！
RUN pip uninstall torch torchvision torchaudio -y \
    && pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128 \
    && pip install --upgrade numpy \
    && pip install torchsde imageio-ffmpeg sageattention onnx opencv-python-headless rotary-embedding-torch

# 4. 将您的其他“黄金基因”复制进镜像
COPY requirements.txt /requirements.txt

# 5. 让镜像在打包时，一次性把剩余依赖全装好
RUN pip install --no-cache-dir -r /requirements.txt
