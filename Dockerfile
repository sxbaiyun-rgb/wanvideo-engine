FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

WORKDIR /workspace

# 安装系统必备的剪辑和编译工具
RUN apt-get update && apt-get install -y git wget ffmpeg libgl1-mesa-glx

# 核心克隆：拉取 ComfyUI 本体
RUN git clone https://github.com/comfyanonymous/ComfyUI.git
WORKDIR /workspace/ComfyUI
RUN pip install -r requirements.txt

# 核心克隆：拉取您需要的自定义神仙节点
WORKDIR /workspace/ComfyUI/custom_nodes
RUN git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
RUN git clone https://github.com/kijai/ComfyUI-KJNodes.git

# 安装数字人节点的特殊 Python 依赖
WORKDIR /workspace/ComfyUI/custom_nodes/ComfyUI-WanVideoWrapper
RUN pip install -r requirements.txt
RUN pip install runpod requests

# 把我们的图纸和大脑装进集装箱
COPY handler.py /workspace/handler.py
COPY workflow_api.json /workspace/workflow_api.json

# 强行降级 NumPy 以解决版本冲突
RUN pip install "numpy<2"

# 强行升级 PyTorch 核心引擎以支持最新的 14B 视频加速包
RUN pip install "torch>=2.4.0" torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu118

WORKDIR /workspace
CMD ["python", "-u", "handler.py"]
