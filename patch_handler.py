import os
import re

print("--- Searching filesystem for handler.py ---")
found_handlers = []
for search_root in ["/", "/comfyui", "/src", "/workspace"]:
    if os.path.exists(search_root):
        for root, dirs, files in os.walk(search_root):
            if "node_modules" in root or ".git" in root or "/proc" in root or "/sys" in root:
                continue
            if "handler.py" in files:
                fp = os.path.join(root, "handler.py")
                if fp not in found_handlers:
                    found_handlers.append(fp)

print("Found handler files:", found_handlers)

for p in found_handlers:
    try:
        with open(p, 'r') as f:
            code = f.read()

        # 1. Catch gifs, videos, video, animated alongside images
        code = code.replace(
            'if "images" in node_output:',
            'media_key = next((k for k in ["images", "gifs", "videos", "video", "animated"] if k in node_output), None)\n            if media_key is not None:'
        )

        code = code.replace(
            'for image_info in node_output["images"]:',
            'for image_info in node_output[media_key]:'
        )

        code = code.replace(
            'other_keys = [k for k in node_output.keys() if k != "images"]',
            'other_keys = [k for k in node_output.keys() if k not in ["images", "gifs", "videos", "video", "animated"]]'
        )

        # 2. Add bulletproof fallback scanner for MP4 files before returning
        fallback_code = """
    if not output_data:
        import glob
        print("worker-comfyui - Fallback scanning output directories for MP4 files...")
        out_dirs = ["/comfyui/output", "/runpod-volume/runpod-slim/ComfyUI/output", "/output", "./output"]
        for od in out_dirs:
            if os.path.exists(od):
                mp4s = sorted(glob.glob(os.path.join(od, "*.mp4")), key=os.path.getmtime, reverse=True)
                if mp4s:
                    import base64
                    target_mp4 = mp4s[0]
                    print(f"worker-comfyui - Fallback found MP4 video: {target_mp4}")
                    with open(target_mp4, "rb") as f:
                        b64 = base64.b64encode(f.read()).decode("utf-8")
                    output_data.append({"filename": os.path.basename(target_mp4), "data": b64, "type": "output"})
                    break
"""
        if 'if not output_data and errors:' in code and 'Fallback scanning' not in code:
            code = code.replace(
                'if not output_data and errors:',
                fallback_code + '\n    if not output_data and errors:'
            )

        with open(p, 'w') as f:
            f.write(code)
        print("✅ Successfully patched", p, "with universal media collector and fallback scanner")
    except Exception as e:
        print("Error patching", p, e)
