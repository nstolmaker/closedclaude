# closedclaude

Home for Claude Code / MCP proxy infrastructure — the glue layer that wires
local MCP servers up to Claude and other agents.

## Layout

```
~/dev/
├── closedclaude/       # this repo — proxy config, systemd, ddns, skill templates
├── mcp-servers/        # monorepo of MCP servers (mam inline; kb, ads-manager symlinked)
└── standalone-repos/   # independent repos (kb, ads-manager) symlinked into mcp-servers
```

## Contents

- `mcp-servers.json` (gitignored, `chmod 600`) — live proxy config with secrets.
- `mcp-servers.json.example` — sanitized template; copy to `mcp-servers.json` and fill in.
- `nginx-mcp.conf` — TLS + bearer-auth reverse proxy for `mcp.noah.space` → `127.0.0.1:4001`.
- `systemd/mcp-proxy.service` — systemd unit that runs the proxy.
- `ddns/` — Route 53 dynamic DNS updater for `mcp.noah.space` (cron every 5 min).
- `openai-image-gen/` — small CLI used by the `lp-tile-image-gen` skill.

## Bootstrap (new machine)

```bash
# clone this repo
git clone https://github.com/nstolmaker/closedclaude ~/dev/closedclaude

# populate secrets
cp ~/dev/closedclaude/mcp-servers.json.example ~/dev/closedclaude/mcp-servers.json
chmod 600 ~/dev/closedclaude/mcp-servers.json
# edit values

# clone / init sibling repos
mkdir -p ~/dev/mcp-servers ~/dev/standalone-repos
git clone https://github.com/nstolmaker/kb ~/dev/standalone-repos/kb
git clone https://github.com/nstolmaker/ads-manager ~/dev/standalone-repos/ads-manager
ln -s ../standalone-repos/kb ~/dev/mcp-servers/kb
ln -s ../standalone-repos/ads-manager ~/dev/mcp-servers/ads-manager

# install systemd unit
sudo cp ~/dev/closedclaude/systemd/mcp-proxy.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now mcp-proxy
```
