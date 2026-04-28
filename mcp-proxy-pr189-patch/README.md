# mcp-proxy PR #189 patch

Fixes progress notification relay from stdio subprocess → SSE client.

## Problem

`mcp-proxy` 0.11.0 strips `req.params.meta` in `_call_tool` and never wires a
server→client progress forwarder. Progress notifications from the subprocess
are swallowed — the SSE client sees nothing after the initial tool call.

## Fix

From unmerged PR #189 (sparfenyuk/mcp-proxy). Applied 2026-04-27 to:

```
~/.local/lib/python3.12/site-packages/mcp_proxy/proxy_server.py
```

Key changes:
- `import sys` added at top
- `_call_tool` reads `request_ctx` from `mcp.server.lowlevel.server`
- Extracts `meta_dict` from `req.params.meta`
- Defines `progress_forwarder` that calls `ctx.session.send_progress_notification`
- Passes `meta=meta_dict` and `progress_callback=progress_forwarder` to `remote_app.call_tool`

## Re-apply after pip upgrade

If `mcp-proxy` is upgraded:

```bash
pip install mcp-proxy
cp proxy_server.py ~/.local/lib/python3.12/site-packages/mcp_proxy/proxy_server.py
```

Check if the upstream version already includes the fix before patching.
Upstream PR: https://github.com/sparfenyuk/mcp-proxy/pull/189
