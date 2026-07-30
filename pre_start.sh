#!/bin/bash

# Symlink input directory to network volume if it exists
if [ -d "/runpod-volume/runpod-slim/ComfyUI/input" ]; then
    rm -rf /comfyui/input
    ln -s /runpod-volume/runpod-slim/ComfyUI/input /comfyui/input
fi

# Symlink output directory to network volume if it exists
if [ -d "/runpod-volume/runpod-slim/ComfyUI/output" ]; then
    rm -rf /comfyui/output
    ln -s /runpod-volume/runpod-slim/ComfyUI/output /comfyui/output
fi

# Link required custom nodes from network volume if they exist
NETWORK_NODES="/runpod-volume/runpod-slim/ComfyUI/custom_nodes"
if [ -d "$NETWORK_NODES" ]; then
    for node_dir in "$NETWORK_NODES"/*; do
        if [ -d "$node_dir" ]; then
            node_name=$(basename "$node_dir")
            if [ ! -d "/comfyui/custom_nodes/$node_name" ] && [ ! -L "/comfyui/custom_nodes/$node_name" ]; then
                ln -s "$node_dir" "/comfyui/custom_nodes/$node_name"
            fi
        fi
    done
fi

# Dynamically patch /handler.py at startup to capture gifs and videos from VHS_VideoCombine
if [ -f "/patch_handler.py" ]; then
    python3 /patch_handler.py || true
fi

exec "$@"
