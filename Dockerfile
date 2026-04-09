# 1. 采用 RunPod 官方的 PyTorch 底座
FROM runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04

# 2. 安装处理音视频必备的底层系统组件
RUN apt-get update && apt-get install -y ffmpeg git wget libgl1-mesa-glx

# 3. 【核心进化】强行把底座的 Torch 升级到最新的 CUDA 12.1 版本，并打入所有业务需要的依赖！
RUN pip install --upgrade torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 \
    && pip install --upgrade numpy \
    && pip install torchsde imageio-ffmpeg sageattention onnx opencv-python-headless rotary-embedding-torch

# 4. 将您的其他“黄金基因”复制进镜像
COPY requirements.txt /requirements.txt

# 5. 让镜像在打包时，把剩余的依赖也一并装好
RUN pip install --no-cache-dir -r /requirements.txt
