import re
import os

for p in ['/handler.py', '/src/handler.py']:
    if os.path.exists(p):
        try:
            with open(p, 'r') as f:
                code = f.read()
            code = re.sub(r"if\s+['\"]images['\"]\s+in\s+node_output:", 'if any(k in node_output for k in ["images", "gifs", "videos"]):', code)
            code = re.sub(r"node_output\[['\"]images['\"]\]", '(node_output.get("images") or node_output.get("gifs") or node_output.get("videos"))', code)
            code = re.sub(r"node_output\.get\(['\"]images['\"]\)", '(node_output.get("images") or node_output.get("gifs") or node_output.get("videos"))', code)
            with open(p, 'w') as f:
                f.write(code)
            print('Successfully patched handler:', p)
        except Exception as e:
            print('Error patching handler:', p, e)
