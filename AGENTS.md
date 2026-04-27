# AGENTS.md

## Repo purpose
Personal dotfiles and bootstrap configs for Linux/macOS/Windows workstations and homelab servers. Deployed via `install.sh`.

## Bootstrap and install commands
- Full setup: `./install.sh init`
- Minimal setup: `./install.sh init -m`
- Development setup: `./install.sh init -b`
- Individual components: `./install.sh <subcmd>` (zsh, vim, git, docker, python, node, rust, golang, k8s, …)
- Font/theming: `./change_font.sh`, `./change_theme.sh`

## Architecture
- **Symlink deployment**: `install.sh` creates symlinks from `~/myConfigs/<dir>/<file>` to canonical locations (`~/.zshrc`, `~/.config/nvim`, etc.). Editing a repo file instantly affects the live system.
- **Hardcoded base path**: `$HOME/myConfigs` is assumed throughout. Do not rename or relocate the clone.
- **Multi-OS dispatch**: OS/distro detected from `/etc/os-release`, `$WINDIR`, or `sw_vers`. Package manager chosen accordingly (apt/yum/dnf/pacman/brew/choco).

## Shell script conventions
- Fold markers: `# {{{` / `# }}}` (vim fold regions) on function and block boundaries.
- Color output via `$COLOR` / `$COLOR1` / `$COLOR2` ANSI variables.
- Internal helper functions prefixed with underscore (`_install_zsh`, `_setup_go`).
- LF line endings enforced by `.gitattributes`. Do not introduce CRLF.
- Validate shell changes with `shellcheck` (installed during bootstrap).

## Git
- **Commit style**: Conventional Commits — `<prefix>(<scope>): summary`. See recent `git log` or `ai/opencode/commands/commit.md` for the full prefix list.
- **Line endings**: LF for `*.sh`, `*.zsh`, `profile` files (`.gitattributes`).
- **Remotes**: `origin` = GitHub (`https://github.com/yusiwen/myConfigs.git`), `gitea` = self-hosted (`git@git.yusiwen.cn:yusiwen/myConfigs.git`).
- `.gitignore` only ignores `.aider*`. Watch for unintended adds.

## CI
- Drone CI (`.drone.yml`): on push to `master`, syncs `install.sh` to a MinIO bucket. No GitHub Actions.

## OpenCode sub-project (`ai/opencode/`)
Self-contained npm project with its own `package.json`. Contains:
- `commands/` — custom slash commands (commit, changelog, etc.)
- `agents/` — custom agents (translator, triage, duplicate-pr)
- `tools/` — custom GitHub automation tools
- `rules/go.mdc` — Go coding standards used across projects
- `plugins/` — TUI plugins (OpenTUI/Solid.js)
- `glossary/` — locale glossaries for the translator agent

Run `npm install` inside `ai/opencode/` before using OpenCode features.
