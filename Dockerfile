# ==============================================================================
# AIDC V7.0 黄金底座 (无损极限瘦身版)
# 核心原则：环境 100% 锁定，0 删减，仅通过层叠压缩与零缓存技术抽干体积水分
# ==============================================================================

# 1. 采用 RunPod 官方的 PyTorch 底座 (保持原样，稳定根基)
FROM runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04

# 2. 系统底层依赖层 (无损瘦身优化)
# [极客级优化]: 
# - 增加 --no-install-recommends 拒绝 Ubuntu 偷偷安装无关紧要的捆绑包。
# - 结尾增加 apt-get clean 和 rm -rf，在快照生成前瞬间抹除几百MB的系统安装包缓存。
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg git wget libgl1-mesa-glx libsndfile1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 3. 核心显卡、算力引擎与 OmniVoice 注入层 (极限瘦身核心，防止 80G 惨案)
# [极客级优化]: 
# - 将原先分散的 4 个 RUN 指令（卸载旧卡、装 cu128、装依赖、装 omnivoice）强制合并为 1 个，防止产生多层冗余的镜像历史快照！
# - 强制全局引入 --no-cache-dir，让 pip "边下边解压边删除"，绝不在底层硬盘留存巨大的 .whl 临时文件！
RUN pip uninstall torch torchvision torchaudio -y \
    && pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128 \
    && pip install --no-cache-dir "numpy<2.0.0" \
    && pip install --no-cache-dir torchsde imageio-ffmpeg sageattention onnx opencv-python-headless rotary-embedding-torch \
    && pip install --no-cache-dir --no-deps omnivoice

# 4. 将您的其他“黄金基因”复制进镜像 (保持原样)
COPY requirements.txt /requirements.txt

# 5. 让镜像在打包时，一次性把剩余依赖全装好 (保持原样，您原本这句写得非常规范)
RUN pip install --no-cache-dir -r /requirements.txt
