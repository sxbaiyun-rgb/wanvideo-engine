import runpod
import json
import urllib.request
import subprocess
import time
import os
import requests

# 1. 魔法连接：把您的 100G 网络硬盘挂载到引擎里
if os.path.exists("/runpod-volume/models"):
    os.system("rm -rf /workspace/ComfyUI/models")
    os.system("ln -s /runpod-volume/models /workspace/ComfyUI/models")
    print("云端模型库挂载成功！")

# 2. 启动 ComfyUI 引擎后台
print("正在点火启动 ComfyUI...")
subprocess.Popen(["python", "ComfyUI/main.py", "--port", "8188", "--disable-auto-launch"])
time.sleep(15) # 等待引擎预热

def upload_video(filepath):
    # 临时为您对接的免费视频托管服务，返回可供用户下载的直链
    print("视频生成完毕，正在上传云端...")
    with open(filepath, 'rb') as f:
        response = requests.post('https://tmpfiles.org/api/v1/upload', files={'file': f})
    if response.status_code == 200:
        url = response.json()['data']['url']
        return url.replace('tmpfiles.org/', 'tmpfiles.org/dl/')
    return "Upload failed"

def handler(job):
    job_input = job['input']
    image_url = job_input.get('image_url')
    audio_url = job_input.get('audio_url')

    if not image_url or not audio_url:
        return {"error": "缺少照片或音频链接！"}

    print("接收到前端任务，正在下载用户素材...")
    os.makedirs("/workspace/ComfyUI/input", exist_ok=True)
    urllib.request.urlretrieve(image_url, "/workspace/ComfyUI/input/temp_image.png")
    urllib.request.urlretrieve(audio_url, "/workspace/ComfyUI/input/temp_audio.mp3")

    print("正在注入灵魂图纸...")
    with open('/workspace/workflow_api.json', 'r', encoding='utf-8') as f:
        workflow = json.load(f)

    # 动态替换节点数据 (Node 284是图片，125是音频)
    workflow["284"]["inputs"]["image"] = "temp_image.png"
    workflow["125"]["inputs"]["audio"] = "temp_audio.mp3"

    print("任务已推入显卡，开始暴力渲染...")
    p = json.dumps({"prompt": workflow}).encode('utf-8')
    req = urllib.request.Request("http://127.0.0.1:8188/prompt", data=p)
    urllib.request.urlopen(req)

    output_dir = "/workspace/ComfyUI/output"
    os.system(f"rm -rf {output_dir}/*") # 清理旧文件

    video_file = None
    while True:
        for f in os.listdir(output_dir):
            if f.endswith("-audio.mp4"):
                video_file = os.path.join(output_dir, f)
                break
        if video_file:
            break
        time.sleep(10) # 每10秒巡逻一次

    final_url = upload_video(video_file)
    return {"status": "success", "video_url": final_url}

# 开启 Serverless 监听
runpod.serverless.start({"handler": handler})