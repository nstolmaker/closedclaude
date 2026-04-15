# closedclaude

Home for Claude Code / MCP proxy infrastructure — the glue layer that wires
local MCP servers up to Claude and other agents.

## Layout

```
~/dev/
├── closedclaude/          # this repo — proxy config, systemd, ddns, skill templates, openai-image-gen CLI
│   ├── mcp-servers.json         # chmod 600, gitignored (live config with secrets)
│   ├── mcp-servers.json.example # sanitized template, committed
│   ├── ddns/                    # Route 53 dynamic DNS updater (cron every 5 min)
│   ├── systemd/                 # mcp-proxy.service unit
│   ├── openai-image-gen/        # CLI used by lp-tile-image-gen skill
│   └── nginx-mcp.conf           # TLS + bearer-auth reverse proxy for mcp.noah.space
├── mcp-servers/           # local monorepo (no remote yet) — path the proxy references
│   ├── mam/                     # inline server (no separate repo)
│   ├── kb -> ../standalone-repos/kb             # symlink
│   └── ads-manager -> ../standalone-repos/ads-manager  # symlink
└── standalone-repos/      # servers with their own GitHub repos
    ├── kb/                      # github.com/nstolmaker/kb
    └── ads-manager/             # github.com/nstolmaker/ads-manager
```

The symlink-at-`mcp-servers/<name>` pattern keeps proxy paths stable while
letting each standalone server live in its own independently-versioned repo.
New servers can start inline in `mcp-servers/` and graduate to `standalone-repos/`
later by moving the dir and replacing with a symlink.

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
