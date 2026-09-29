# mise

Global [mise-en-place](https://mise.jdx.dev) config, shared between machines
(macOS workstation + omarchy Linux). `config.toml` is symlinked to
`~/.config/mise/config.toml` by `install.sh zsh` (see `shell/zsh/install.sh`),
so editing the file here changes the live configuration immediately.

## What this replaces

The tool-installation half of `shell/zsh/zshrc.zinit`:

| before (zinit)                                              | now                                        |
| ----------------------------------------------------------- | ------------------------------------------ |
| `from'gh-r' as'program'` ices (fd, bat, k9s, lazygit, ...)  | `[tools]` entries                          |
| vendor installer hooks (kubectl, helm, uv, opencode, ...)   | `[tools]` entries (`aqua:` / `github:`)    |
| sdkman (java / maven / gradle), n (node), asdf              | `core:` backends in `[tools]`              |
| `if [[ "$(uname -o)" != Msys/Darwin ]]` guards              | the `os` tool option                       |
| `atload` aliases and `pass` key loading                     | `shell/scripts/02-functions.script`, `06-aliases.script` |

zinit is still there, but only for what it is good at: loading zsh plugins (OMZ
libs, fzf-tab, autosuggestions, fast-syntax-highlighting, p10k, ...). mise does
not do that.

## Daily use

```sh
mise ls                       # everything in the config + install status
mise ls --current             # what is selected for the current directory
mise install                  # install everything declared (after editing)
mise upgrade                  # update within the declared version requests
mise use -g <tool>@<version>  # add/change a global tool, then commit this file
mise use <tool>@<version>     # per-project: writes ./mise.toml
mise exec -- <cmd>            # one-off, for scripts/CI (no shell hooks involved)
mise doctor                   # when activation behaves oddly
```

`mise activate zsh` re-evaluates `$PATH`, `$JAVA_HOME`, ... on every prompt and
on `cd`, so tools and JDKs follow the directory. Non-interactive shells (bash
scripts, cron, CI) do **not** get that: use `mise exec -- ...` there, or put
`$HOME/.local/share/mise/shims` on `PATH`.

## Platform differences

Use the `os` tool option instead of shell conditionals, e.g.

```toml
eza = { version = "latest", os = ["linux"] }   # macOS gets eza from Homebrew
```

## Deliberate version pins

| tool   | pin     | why                                                             |
| ------ | ------- | --------------------------------------------------------------- |
| `helm` | `3`     | 3.22.0 was in use; `latest` is 4.x, a major bump                |
| `gradle` | `8`   | 8.12.1 was in use; `latest` is 9.x, a major bump                |

Bump them on purpose, not as a side effect of an upgrade.

## One-time follow-ups after switching a machine

- **node**: global npm packages must be reinstalled under the mise-managed node
  (the old ones live under `~/.n`):

  ```sh
  npm i -g @anthropic-ai/claude-code @deepseek-ai/dsh pnpm gulp http-server wedecode
  corepack enable
  ```

  `dsh` stays npm-managed on purpose: npm publishes it as prereleases only
  (`0.1.7-rc.x`, `0.2.0-rc.1`) and mise's npm backend cannot resolve those.

  Note: npm globals installed this way live **inside the node version directory**
  (`~/.local/share/mise/installs/node/<version>/lib/node_modules`), so a
  `mise upgrade node` to a new major/patch moves `installs/node/lts` to the new
  version and the global CLI disappears (neither the direct path nor the shim
  can find it). Re-run the `npm i -g ...` list after a node upgrade.

- **hardcoding a path to a mise tool** (editor/IDE config, script, systemd unit,
  MCP server command): use the shim `~/.local/share/mise/shims/<tool>`. It is the
  supported entry point for contexts that never load your shell config, and it
  resolves the version for the current directory. Do not hardcode
  `~/.local/share/mise/installs/...`: that is internal layout (`latest` / `lts`
  are symlinks mise repoints on upgrade).

- **java / macOS**: `mise activate` exports `JAVA_HOME`, but GUI apps that use
  `/usr/libexec/java_home` (IDEs, installers) do not see mise JDKs. To register
  the selected JDK, see "macOS JAVA_HOME Integration" in the mise Java docs
  (symlink `$(mise where java)/Contents` into `/Library/Java/JavaVirtualMachines`).
  IntelliJ: add `~/.local/share/mise/installs/java/*` as SDKs, or use the
  Gradle toolchain env hook below.

- **gradle toolchains**: in `gradle.properties`,
  `org.gradle.java.installations.fromEnv=JAVA_HOME` makes Gradle detect the
  mise-selected JDK.

- **now redundant** (can be removed once the new setup is verified):
  `~/.sdkman` (1.7G), `~/.asdf`, `~/.n`, `~/.local/bin/{uv,kubectl}`,
  `/usr/local/bin/{helm,talosctl}`.

- **dropped tools**: `keadm` and `micromamba` are no longer managed or used.
  Their data is still on disk and can be deleted when convenient:
  `~/.micromamba` (3.5G conda root, contains `envs/`) and
  `~/.local/bin/micromamba` (14M).

## Verifying a migration step

```sh
zsh -n ~/myConfigs/shell/zsh/zshrc.zinit          # syntax
bash -n ~/myConfigs/shell/scripts/*.script
mise registry <name>                              # which backend a name uses
mise ls-remote <name>                             # versions a backend offers
mise exec -- <name> --version                     # the binary actually works
zprof                                             # after `zmodload zsh/zprof` in zshrc
```
