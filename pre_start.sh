#!/bin/bash
# Pre-start script for Wan 2.2 Animate Serverless Worker

NV_BASE="/runpod-volume/runpod-slim/ComfyUI"
NV_INPUT="$NV_BASE/input"
NV_OUTPUT="$NV_BASE/output"
NV_CUSTOM_NODES="$NV_BASE/custom_nodes"
COMFY_INPUT="/comfyui/input"
COMFY_CUSTOM_NODES="/comfyui/custom_nodes"

# Symlink input directory
if [ -d "$NV_INPUT" ]; then
  echo "INFO: Symlinking input files from Network Volume..."
  ln -sf "$NV_INPUT"/* "$COMFY_INPUT"/ 2>/dev/null || true
fi

# Symlink output directory
if [ -d "$NV_OUTPUT" ]; then
  echo "INFO: Symlinking output files from Network Volume..."
  find "$NV_OUTPUT" -maxdepth 2 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.mp4" -o -name "*.webm" \) \
    -exec ln -sf {} "$COMFY_INPUT"/ \; 2>/dev/null || true
fi

# Symlink custom nodes from Network Volume
if [ -d "$NV_CUSTOM_NODES" ]; then
  echo "INFO: Symlinking custom nodes from Network Volume..."
  for node_dir in "$NV_CUSTOM_NODES"/*/; do
    node_name=$(basename "$node_dir")
    if [ ! -e "$COMFY_CUSTOM_NODES/$node_name" ]; then
      ln -sf "$node_dir" "$COMFY_CUSTOM_NODES/$node_name" 2>/dev/null || true
    fi
  done
fi

exec "$@"
