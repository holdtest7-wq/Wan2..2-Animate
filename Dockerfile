# Wan 2.2 Animate — RunPod Serverless Dockerfile
# Models and custom nodes live on the RunPod Network Volume.
#
# Network Volume mount points:
#   GPU Pod:    /workspace/runpod-slim/ComfyUI/
#   Serverless: /runpod-volume/runpod-slim/ComfyUI/

FROM runpod/worker-comfyui:5.8.4-base

# Build-time tokens for gated downloads (if needed)
ARG HF_TOKEN=""

# Install required system & python packages directly into the RunPod virtual environment (/opt/venv)
RUN /opt/venv/bin/pip install --no-cache-dir \
    onnxruntime-gpu \
    torchvision \
    "dghs-imgutils[gpu]" \
    matplotlib \
    rotary-embedding-torch \
    diffusers \
    opencv-python-headless \
    scipy \
    einops \
    lark \
    timm \
    piexif \
    accelerate \
    gguf

# Install all required custom nodes for Wan 2.2 Animate
RUN git clone https://github.com/kijai/ComfyUI-segment-anything-2 /comfyui/custom_nodes/ComfyUI-segment-anything-2
RUN git clone https://github.com/kijai/ComfyUI-WanAnimatePreprocess /comfyui/custom_nodes/ComfyUI-WanAnimatePreprocess
RUN git clone https://github.com/kijai/ComfyUI-KJNodes /comfyui/custom_nodes/ComfyUI-KJNodes
RUN git clone https://github.com/kijai/ComfyUI-WanVideoWrapper /comfyui/custom_nodes/ComfyUI-WanVideoWrapper
RUN git clone https://github.com/Fannovel16/comfyui_controlnet_aux /comfyui/custom_nodes/comfyui_controlnet_aux
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite /comfyui/custom_nodes/ComfyUI-VideoHelperSuite
RUN git clone https://github.com/rgthree/rgthree-comfy /comfyui/custom_nodes/rgthree-comfy
RUN git clone https://github.com/Fannovel16/ComfyUI-Frame-Interpolation /comfyui/custom_nodes/ComfyUI-Frame-Interpolation

# Map extra model search paths to the Network Volume
COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml

# Replace handler.py with our modified version that supports gifs/videos output keys
# (VHS_VideoCombine outputs under 'gifs' key which the stock handler ignores)
COPY handler.py /handler.py

# Pre-start script to symlink images and custom nodes
COPY pre_start.sh /pre_start.sh
RUN chmod +x /pre_start.sh

# Optimize RAM usage
RUN sed -i 's/python -u \/comfyui\/main.py --disable-auto-launch/python -u \/comfyui\/main.py --disable-auto-launch --cache-none/g' /start.sh

ENTRYPOINT ["/pre_start.sh"]
CMD ["/start.sh"]

