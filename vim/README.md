# VIM Installation

## References

- [rafi/vim-config](https://github.com/rafi/vim-config)
- [xero/dotfiles](https://github.com/xero/dotfiles)

## Prerequisites

- Lua, Pypthon, Python3, Ruby, Perl
- If don't have Ruby installed,
  [yaml2json](https://github.com/SoftwearDevelopment/large-yaml2json-json2yaml)
  shoudl be installed, or use PyYAML: `pip3 install --user --upgrade PyYAML`
- Linters:
  - Node.js based linters:

    ```sh
    npm -g install jshint jsxhint jsonlint stylelint sass-lint
    npm -g install raml-cop markdownlint-cli write-good
    ```

  - Python based linters:

    ```sh
    pip install --user pycodestyle pyflakes flake8 vim-vint proselint yamllint
    ```

- ag (The Silver Searcher): [ggreer/the_silver_searcher](https://github.com/ggreer/the_silver_searcher)
- `cscope`, `exuberant ctags`

## Installation

### Ubuntu

1. Install vim & neovim:

  ```sh
  # Add this PPA if you want to install latest vim release on Ubuntu earlier than 17.04
  sudo add-apt-repository ppa:jonathonf/vim
  sudo apt-get install vim-gtk

  # Insall NeoVim latest unstable development repo
  sudo add-apt-repository ppa:neovim-ppa/unstable
  sudo apt-get insall neovim
  ```

1. Link setting files to ~/.vim

  ```sh
  ln -sf ~/git/myConfigs/vim ~/.vim
  ln -sf ~/.vim ~/.config/nvim
  ```

### Windows

1. Prerequisites

    - [NeoVim](https://neovim.io/)
    - [Python3](https://www.python.org/downloads/)
    - [VirtualEnv](https://virtualenv.pypa.io/en/stable/)

    Make sure their executables are in `%PATH%`.

1. NeoVim configuration files

  Run `install.bat` to initialize them.

1. Python environments

    Intall python3 to, for example, `I:\Python37`, run commands below:

    ```sh
    pip install virtualenv
    md %userprofile%\.cache\vim\env
    virtaulenv --system-site-pacakges %userprofile%\.cache\vim\env\neovim3
    ```

    In `%userprofile%\.cache\vim\env\neovim3\Scripts`, run `activate.bat` to activate this virtualenv, then:

    ```sh
    pip install neovim PyYAML pycodestyle pyflakes flake8 vim-vint proselint yamllint
    ```

## Custom Key-mappings## Custom Key-mappings

Note that,

- Leader key is set as <kbd>Space</kbd>
- Local-leader is set as <kbd>;</kbd> and used for navigation and search mostly
  (Denite and Defx)

### General

| Key   | Mode | Action
| ----- |:----:| ------------------
| `Space` | _All_ | **Leader**
| `;` | _All_ | **Local Leader**
| Arrows | Normal | Resize splits (* Enable `g:elite_mode` in `.vault.vim`)
| `;`+`c` | Normal | Open context-menu
| `Backspace` | Normal | Match bracket (%)
| `gK` | Normal | Open Zeal or Dash on some file-types
| `Y` | Normal | Yank to the end of line (y$)
| `<Return>` | Normal | Toggle fold (za)
| `S`+`<Return>` | Normal | Focus the current fold by closing all others (zMza)
| `S`+`<Return>` | Insert | Start new line from any cursor position (C-o)
| `hjkl` | Normal | Smart cursor movements (g/hjkl)
| `Ctrl`+`f` | Normal | Smart page forward (C-f/C-d)
| `Ctrl`+`b` | Normal | Smart page backwards (C-b/C-u)
| `Ctrl`+`e` | Normal | Smart scroll down (3C-e/j)
| `Ctrl`+`y` | Normal | Smart scroll up (3C-y/k)
| `Ctrl`+`q` | Normal | Remap to `Ctrl`+`w`
| `Ctrl`+`x` | Normal | Rotate window placement
| `!` | Normal | Shortcut for `:!`
| `<` | Visual | Indent to left and re-select
| `>` | Visual | Indent to right and re-select
| `Tab` | Visual | Indent to right and re-select
| `Shift`+`Tab` | Visual | Indent to left and re-select
| `gh` | Normal | Show highlight groups for word
| `gp` | Normal | Select last paste
| `Q` | Normal | Start/stop macro recording
| `gQ` | Normal | Play macro 'q'
| `<Leader>`+`j`/`k` | Normal/Visual | Move lines down/up
| `<leader>`+`cp` | Normal | Duplicate paragraph
| `<leader>`+`cn`/`cN` | Normal/Visual | Change current word in a repeatable manner
| `sg` | Visual | Replace within selected area
| `Ctrl`+`a` | Command | Navigation in command line
| `Ctrl`+`b` | Command | Move cursor backward in command line
| `Ctrl`+`f` | Command | Move cursor forward in command line
| `Ctrl`+`r` | Visual | Replace selection with step-by-step confirmation
| `<leader>`+`cw` | Normal | Remove all spaces at EOL
| `<leader>`+`<leader>` | Normal | Enter visual line-mode
| `<leader>`+`os` | Normal | Load workspace session
| `<leader>`+`se` | Normal | Save current workspace session
| `<leader>`+`d` | Normal/Visual | Duplicate line or selection
| `<leader>`+`S` | Normal/Visual | Source selection
| `<leader>`+`ml` | Normal | Append modeline

### File Operations

| Key   | Mode | Action
| ----- |:----:| ------------------
| `<leader>`+`cd` | Normal | Switch to the directory of opened buffer (:lcd %:p:h)
| `<leader>`+`w` | Normal/Visual | Write (:w)
| `<leader>`+`y` / `<leader>`+`Y` | Normal | Copy (relative / absolute) file-path to clipboard
| `Ctrl`+`s` | _All_ | Write (:w)

### Editor UI

| Key   | Mode | Action
| ----- |:----:| ------------------
| `<leader>`+`ti` | Normal | Toggle indentation lines
| `<leader>`+`ts` | Normal | Toggle spell-checker (:setlocal spell!)
| `<leader>`+`tn` | Normal | Toggle line numbers (:setlocal nonumber!)
| `<leader>`+`tl` | Normal | Toggle hidden characters (:setlocal nolist!)
| `<leader>`+`th` | Normal | Toggle highlighted search (:set hlsearch!)
| `<leader>`+`tw` | Normal | Toggle wrap (:setlocal wrap! breakindent!)
| `g0` | Normal | Go to first tab (:tabfirst)
| `g$` | Normal | Go to last tab (:tablast)
| `g5` | Normal | Go to previous tab (:tabprevious)
| `Ctrl`+`j` | Normal | Move to split below
| `Ctrl`+`k` | Normal | Move to upper split
| `Ctrl`+`h` | Normal | Move to left split
| `Ctrl`+`l` | Normal | Move to right split
| `*` | Visual | Search selection forwards
| `#` | Visual | Search selection backwards
| `]`+`c`/`q` | Normal | Next on location/quickfix list
| `]`+`c`/`q` | Normal | Previous on location/quickfix list
| `s`+`h` | Normal | Toggle colorscheme background dark/light
| `s`+`-` | Normal | Lower colorscheme contrast (Support solarized8)
| `s`+`=` | Normal | Raise colorscheme contrast (Support solarized8)

### Window Management

| Key   | Mode | Action
| ----- |:----:| ------------------
| `q` | Normal | Quit window (and Vim, if last window)
| `Ctrl`+`Tab` | Normal | Next tab
| `Ctrl`+`Shift`+`Tab` | Normal | Previous tab
| `s`+`v` | Normal | Horizontal split (:split)
| `s`+`g` | Normal | Vertical split (:vsplit)
| `s`+`t` | Normal | Open new tab (:tabnew)
| `s`+`o` | Normal | Close other windows (:only)
| `s`+`b` | Normal | Previous buffer (:b#)
| `s`+`c` | Normal | Closes current buffer (:close)
| `s`+`x` | Normal | Remove buffer, leave blank window
| `<leader>`+`sv` | Normal | Split with previous buffer
| `<leader>`+`sg` | Normal | Vertical split with previous buffer

### Plugin: Denite

| Key   | Mode | Action
| ----- |:----:| ------------------
| `;`+`r` | Normal | Resumes last Denite window
| `;`+`f` | Normal | File search
| `;`+`b` | Normal | Buffers and MRU
| `;`+`d` | Normal | Directories
| `;`+`v` | Normal/Visual | Yank history
| `;`+`l` | Normal | Location list
| `;`+`q` | Normal | Quick fix
| `;`+`n` | Normal | Dein plugin list
| `;`+`g` | Normal | Grep search
| `;`+`j` | Normal | Jump points
| `;`+`u` | Normal | Junk files
| `;`+`o` | Normal | Outline tags
| `;`+`s` | Normal | Sessions
| `;`+`t` | Normal | Tag list
| `;`+`p` | Normal | Jump to previous position
| `;`+`h` | Normal | Help
| `;`+`m` | Normal | Memo list
| `;`+`z` | Normal | Z (jump around)
| `;`+`/` | Normal | Buffer lines
| `;`+`*` | Normal | Match word under cursor with lines
| `;`+`;` | Normal | Command history
| `<leader>`+`gl` | Normal | Git log (all)
| `<leader>`+`gs` | Normal | Git status
| `<leader>`+`gc` | Normal | Git branches
| `<leader>`+`gt` | Normal | Find tags matching word under cursor
| `<leader>`+`gf` | Normal | Find file matching word under cursor
| `<leader>`+`gg` | Normal/Visual | Grep word under cursor
| **Within _Denite_ window** ||
| `jj` / `kk` | Insert | Leave Insert mode
| `q` / `Escape` | Normal | Exit denite window
| `Space` | Normal | Select entry
| `Tab` | Normal | List and choose action
| `i` | Normal | Open filter input
| `dd` | Normal | Delete entry
| `p` | Normal | Preview entry
| `st` | Normal | Open in a new tab
| `sg` | Normal | Open in a vertical split
| `sv` | Normal | Open in a split
| `r` | Normal | Redraw
| `yy` | Normal | Yank
| `'` | Normal | Quick move

### Plugin: Defx

| Key   | Mode | Action
| ----- |:----:| ------------------
| `;`+`e` | Normal | Open file explorer (toggle)
| `;`+`a` | Normal | Open file explorer and select current file
| **Within _Defx_ window** ||
| `h/j/k/l` | Normal | Movement, collapse/expand, open
| `]`+`g` | Normal | Next dirty git item
| `]`+`g` | Normal | Previous dirty git item
| `w` | Normal | Toggle window size
| `N` | Normal | Create new file or directory
| `yy` | Normal | Yank selected item to clipboard
| `st` | Normal | Open file in new tab
| `sv` | Normal | Open file in a horizontal split
| `sg` | Normal | Open file in a vertical split
| `&` | Normal | Jump to project root
| `gx` | Normal | Execute associated system application
| `gd` | Normal | Open git diff on selected file
| `gl` | Normal | Open terminal file explorer
| `gr` | Normal | Grep in selected directory
| `gf` | Normal | Find files in selected directory

### Plugin: Deoplete and Emmet

| Key   | Mode | Action
| ----- |:----:| ------------------
| `Tab` | Insert/select | Smart completion
| `Enter` | Insert | Select completion or expand snippet
| `Ctrl`+`j/k/f/b/d/u` | Insert | Movement in completion pop-up
| `Ctrl`+`<Return>` | Insert | Expand Emmet sequence
| `Ctrl`+`o` | Insert | Expand snippet
| `Ctrl`+`g` | Insert | Refresh candidates
| `Ctrl`+`l` | Insert | Complete common string
| `Ctrl`+`e` | Insert | Cancel selection and close pop-up
| `Ctrl`+`y` | Insert | Close pop-up

### Plugin: Caw (comments)

| Key   | Mode | Action
| ----- |:----:| ------------------
| `gc` | Normal/visual | Prefix
| `gcc` | Normal/visual | Toggle comments
| `<leader>`+`v` | Normal/visual | Toggle single-line comments
| `<leader>`+`V` | Normal/visual | Toggle comment block

### Plugin: Edge Motion

| Key   | Mode | Action
| ----- |:----:| ------------------
| `g`+`j` | Normal/Visual | Jump to edge downwards
| `g`+`k` | Normal/Visual | Jump to edge upwards

### Plugin: Signature

| Key   | Mode | Action
| ----- |:----:| ------------------
| `m`+`/`/`?` | Normal | Show list of buffer marks/markers
| `m`+`m` | Normal | Toggle mark on current line
| `m`+`,` | Normal | Place next mark
| `m`+`-` | Normal | Purge all marks on current line
| `m`+`n` | Normal | Jump to next mark
| `m`+`p` | Normal | Jump to previous mark
| `m`+`j` | Normal | Jump to next marker
| `m`+`k` | Normal | Jump to previous marker

### Plugin: Easygit

| Key   | Mode | Action
| ----- |:----:| ------------------
| `<leader>`+`ga` | Normal | Git add current file
| `<leader>`+`gS` | Normal | Git status
| `<leader>`+`gd` | Normal | Git diff
| `<leader>`+`gD` | Normal | Close diff
| `<leader>`+`gc` | Normal | Git commit
| `<leader>`+`gb` | Normal | Git blame
| `<leader>`+`gB` | Normal | Open in browser
| `<leader>`+`gp` | Normal | Git push

### Plugin: GitGutter

| Key   | Mode | Action
| ----- |:----:| ------------------
| `[`+`g` | Normal | Jump to next hunk
| `]`+`g` | Normal | Jump to previous hunk
| `g`+`S` | Normal | Stage hunk
| `<leader>`+`gr` | Normal | Revert hunk
| `g`+`s` | Normal | Preview hunk

### Plugin: Linediff

| Key   | Mode | Action
| ----- |:----:| ------------------
| `m`+`d`+`f` | Visual | Mark lines and open diff if 2nd region
| `m`+`d`+`a` | Visual | Mark lines for diff
| `m`+`d`+`s` | Normal | Shows the diff between all the marked areas
| `m`+`d`+`r` | Normal | Removes the signs denoting the diff regions

### Misc Plugins

| Key   | Mode | Action
| ----- |:----:| ------------------
| `v` / `V` | Visual/select | Expand/reduce selection (expand-region)
| `m`+`g` | Normal | Open Magit
| `m`+`t` | Normal/Visual | Toggle highlighted word (quickhl)
| `-` | Normal | Choose a window to edit (choosewin)
| `<leader>`+`-` | Normal | Switch editing window with selected (choosewin)
| `<leader>`+`l` | Normal | Open sidemenu
| `<leader>`+`o` | Normal | Open tag-bar (:Vista)
| `<leader>`+`G` | Normal | Toggle distraction-free writing (goyo)
| `<leader>`+`gu` | Normal | Open undo-tree
| `<leader>`+`W` | Normal | VimWiki
| `<leader>`+`K` | Normal | Thesaurus
