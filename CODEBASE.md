# CODEBASE.md — myConfigs

## Purpose
Personal dotfiles and bootstrap scripts for Linux/macOS/Windows workstations and homelab servers. All configs are symlinked into place by `install.sh`.

## Entry Point
- **`install.sh`** — Main installer, CLI dispatcher. Detects OS/distro and runs component sub-commands (`init`, `zsh`, `vim`, `git`, `docker`, etc.). Uses `case $1` dispatch at line 711.

## Architecture
- **Symlink deployment**: Files live in `~/myConfigs/<category>/<file>` and are symlinked to canonical locations (`~/.zshrc`, `~/.config/nvim`, etc.). Editing repo files instantly affects live configs.
- **Hardcoded base path**: `$HOME/myConfigs` assumed everywhere. Do not rename/clone elsewhere.
- **Multi-OS dispatch**: OS detected from `/etc/os-release`, `$WINDIR`, or `sw_vers`. Package manager chosen accordingly (apt/yum/dnf/pacman/brew/choco). See `install.sh:20-63`.
- **Git submodules**: `kernel` (Ubuntu mainline kernel updater), `system/ps_mem` (memory profiler), `logitech/k380-function-keys-conf`.
- **CI**: `.drone.yml` — on push to `master`, syncs `install.sh` to a MinIO bucket.

## Key Modules

### Shell (`shell/`)
- **zsh/**: `.zshrc` variants (zinit, oh-my-zsh, p10k, starship, Windows). `install.sh` installs zsh and symlinks configs.
- **bash/**: `.bashrc`, `.bash_aliases`, `.bash_profile`.
- **profile**: Generic `.profile` for login shells.
- **fish/**: `config.fish` + `install.sh`.
- **starship/**: `starship.toml` + mingw variant.
- **tmux/**: `tmux.conf`, plugin config, base config, session launcher.
- **zellij/**: Zellij terminal multiplexer configs.
- **scripts/**: Numbered dot sourcing scripts (00-environment, 01-colors, 02-functions, 03-programs, 04-keybindings, 05-themes, 06-aliases, 99-customize) — sourced in order by shell init.
- **completion/**: Shell completion files for ag, cmake, composer, docker, emote, hub, knife, node, openssl, pass, pb, xllx.

### Vim/Neovim (`vim/`)
- **nvchad/**: NvChad config — `init.lua`, `lua/` directory, `lazy-lock.json`. Symlinked to `~/.config/nvim`.
- **lvim/**: LunarVim `config.lua`.
- **astronvim/**: AstroNvim `user/` config.
- **ideavimrc**: IntelliJ IDEA Vim emulation config.
- `install.sh`: Installs/upgrades Neovim AppImage from GitHub releases.

### Git (`git/`)
- **install.sh**: Installs/upgrades git + delta diff viewer.
- **alias.sh**: Git aliases.
- **scripts**: `git-migrate`, `git-new-workdir`, `git-sync`, `gitproxy`, `repos.sh`, `change_commit_author.sh`.
- `gitconfig`: Personal git config (user, aliases, delta, etc.).

### X11/Desktop (`X11/`)
- **alacritty/**, **kitty/**, **wezterm/**: Terminal emulator configs.
- **i3/**, **sway/**, **regolith/**: Window manager configs.
- **rofi/**: Application launcher config.
- **waybar/**: Wayland status bar config.
- **gtk/**: GTK theme settings.
- **fonts/**, **themes/**: Font packages, Xresources color themes.
- **rxvt/**: URxvt config.
- **cmus/**: Audio player config.
- **desktop/**: `.desktop` entries.
- **dual-monitor/**, **backup.sh**, **watch.sh**: Display and automation scripts.
- **Xresources**: Master Xresources, loaded via `xrdb`.

### Development Languages
| Module | `install.sh` pattern | Notes |
|--------|----------------------|-------|
| **python/** | Source `python/install.sh` → `_install_python` | Installs pyenv/pipx/pipenv |
| **node.js/** | Source `node.js/install.sh` → `_install_node` | nvm/node/npm |
| **rust/** | Source `rust/install.sh` → `_install_rust` | rustup/cargo |
| **golang/** | Source `golang/install.sh` → `_install_golang` | Go via tarball |
| **ruby/** | Source `ruby/install.sh` → `_install_ruby` | rbenv |
| **lua/** | Source `lua/install.sh` → `_install_lua` | Lua/luarocks |

### Infrastructure
- **docker/**: Docker/containerd install, daemon.json, proxy.conf, k8s image sync script, offline containerd installer, QEMU binfmt check.
- **k8s/**: Krew install, Cilium init, k9s config, host templates, netplan template, `node-init.sh`.
- **samba/**: `smb.conf` for Samba file sharing.
- **ssh/**: SSH config.
- **system/**: Ubuntu/CentOS systemd units, ps_mem submodule.

### Tooling & Utilities
- **keyring/**: GNOME keyring config for i3/mutt.
- **mail/**: mutt, msmtp, mbsync, goobook, offlineimap, sup configs.
- **byobu/**: Byobu tmux config (install.sh → `_install_byobu`).
- **mpd/**: Music Player Daemon + ncmpcpp config.
- **bpytop/**: bpytop config.
- **ctags/**: Universal Ctags install.
- **eclipse/**: Eclipse launcher + config.
- **oracle/**: Oracle SQL config + tnsnames.
- **youtube-dl/**: yt-dlp config.
- **mac/**: macOS-specific (iTerm2, chunkwm, kitty).
- **misc/**: `calibre.sh`, `composeKey.sh`, `ocr.sh`, `projector.sh`, `route.sh`.
- **razer/**: Razer mouse acceleration fix.
- **logitech/**: k380 function keys conf (submodule).
- **proxy.sh**: System proxy toggle script.

### OpenCode Sub-project (`ai/opencode/`)
Self-contained npm project (see its own `package.json`). Contains:
- **commands/**: Custom slash commands (`commit.md`, `changelog.md`, `codebase.md`, `issues.md`, `learn.md`, `spellcheck.md`, `ai-deps.md`, `rmslop.md`, `release.md`).
- **agents/**: Custom agents (`translator.md`, `triage.md`, `duplicate-pr.md`).
- **tools/**: GitHub automation (`github-triage.ts`, `github-pr-search.ts`).
- **plugins/**: OpenTUI/Solid.js plugin (`tui-smoke.tsx`).
- **glossary/**: Locale glossaries for translator agent (16 languages).
- **rules/**: Go coding standards (`go.mdc`).
- **themes/**: TUI theme (`mytheme.json`).
- `tui.json`: OpenTUI app config.

### Root Scripts
- **change_font.sh**: Interactive font selector (Input Mono, Iosevka, Fira Code, Sarasa Mono, etc.) — installs & sets Xresources font.
- **change_theme.sh**: Interactive color theme selector — updates i3, vim, Xresources, mutt themes simultaneously.
- **check.js**: Utility script.
- **exptab.sh**: Utility script.
- **proxy.sh**: System proxy toggle.

## Conventions
- Shell: fold markers (`# {{{` / `# }}}`), color vars (`$COLOR`, `$COLOR1`, `$COLOR2`), underscore-prefixed helpers (`_install_*`), LF line endings via `.gitattributes`.
- Git: Conventional Commits (`<prefix>(<scope>): summary`). Remotes: `origin` (GitHub), `gitea` (self-hosted).
