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

    ```
    npm -g install jshint jsxhint jsonlint stylelint sass-lint
    npm -g install raml-cop markdownlint-cli write-good
    ```

  - Python based linters:

    ```
    pip install --user pycodestyle pyflakes flake8 vim-vint proselint yamllint
    ```

- ag (The Silver Searcher): [ggreer/the_silver_searcher](https://github.com/ggreer/the_silver_searcher)
- `cscope`, `exuberant ctags`

## Installation

### Ubuntu

1. Install vim & neovim:

  ```text
  # Add this PPA if you want to install latest vim release on Ubuntu earlier than 17.04
  $ sudo add-apt-repository ppa:jonathonf/vim
  $ sudo apt-get install vim-gtk

  # Insall NeoVim latest stable
  $ sudo add-apt-repository ppa:neovim-ppa/stable
  $ sudo apt-get insall neovim
  ```

1. Link setting files to ~/.vim

  ```text
  $ mkdir -p ~/.vim
  $ ln -sf ~/git/myConfigs/vim/vimrc ~/.vim/vimrc
  $ ln -sf ~/git/myConfigs/vim/colors ~/.vim/colors
  $ ln -sf ~/git/myConfigs/vim/ftplugin ~/.vim/ftplugin
  $ ln -sf ~/git/myConfigs/vim/plugin ~/.vim/plugin
  $ ln -sf ~/git/myConfigs/vim/snippets ~/.vim/snippets
  $ ln -sf ~/git/myConfigs/vim/plugins.yaml ~/.vim/plugins.yaml
  $ ln -sf ~/git/myConfigs/vim/init.vim ~/.vim/init.vim
  $ ln -sf ~/git/myConfigs/vim/vimrc.denite ~/.vim/vimrc.denite
  $ ln -sf ~/git/myConfigs/vim/vimrc.denite.menu ~/.vim/vimrc.denite.menu
  $ ln -sf ~/git/myConfigs/vim/vimrc.deoplete ~/.vim/vimrc.deoplete
  $ ln -sf ~/git/myConfigs/vim/vimrc.filetype ~/.vim/vimrc.filetype
  $ ln -sf ~/git/myConfigs/vim/vimrc.goyo ~/.vim/vimrc.goyo
  $ ln -sf ~/git/myConfigs/vim/vimrc.mappings ~/.vim/vimrc.mappings
  $ ln -sf ~/git/myConfigs/vim/vimrc.neocomplete ~/.vim/vimrc.neocomplete
  $ ln -sf ~/git/myConfigs/vim/vimrc.neovim ~/.vim/vimrc.neovim
  $ ln -sf ~/git/myConfigs/vim/vimrc.nerdtree ~/.vim/vimrc.nerdtree
  $ ln -sf ~/git/myConfigs/vim/vimrc.theme ~/.vim/vimrc.theme

  $ ln -sf ~/git/myConfigs/vim/themes/vimrc.theme.sourcerer ~/.vim/vimrc.colortheme

  $ ln -sf ~/.vim ~/.config/nvim
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
  
  ```shell
  pip install virtualenv
  md %userprofile%\.cache\vim\env
  virtaulenv --system-site-pacakges %userprofile%\.cache\vim\env\neovim3
  ```
  
  In `%userprofile%\.cache\vim\env\neovim3\Scripts`, run `activate.bat` to activate this virtualenv, then:
  
  ```shell
  pip install neovim PyYAML pycodestyle pyflakes flake8 vim-vint proselint yamllint
  ```

## Custom Key-mappings

Note that,

* Leader key is set as <kbd>Space</kbd>
* Local-leader is set as <kbd>;</kbd> and used for Denite & NERDTree

Key   | Mode | Action
----- |:----:| ------------------
`Space` | _All_ | **Leader**
`;` | _All_ | **Local Leader**
Arrows | Normal | Resize splits (* Enable `g:elite_mode` in `.vault.vim`)
`Backspace` | Normal | Match bracket (%)
`K` | Normal | Open Zeal or Dash on some file types (except Python+Vim script)
`Y` | Normal | Yank to the end of line (y$)
`<Return>` | Normal | Toggle fold (za)
`S`+`<Return>` | Normal | Focus the current fold by closing all others (zMza)
`S`+`<Return>` | Insert | Start new line from any cursor position (\<C-o>o)
`hjkl` | Normal | Smart cursor movements (g/hjkl)
`Ctrl`+`f` | Normal | Smart page forward (C-f/C-d)
`Ctrl`+`b` | Normal | Smart page backwards (C-b/C-u)
`Ctrl`+`e` | Normal | Smart scroll down (3C-e/j)
`Ctrl`+`y` | Normal | Smart scroll up (3C-y/k)
`Ctrl`+`q` | Normal | Remap to `Ctrl`+`w`
`Ctrl`+`x` | Normal | Rotate window placement
`!` | Normal | Shortcut for `:!`
`}` | Normal | After paragraph motion go to first non-blank char (}^)
`<` | Visual/Normal | Indent to left and re-select
`>` | Visual/Normal | Indent to right and re-select
`Tab` | Visual | Indent to right and re-select
`Shift`+`Tab` | Visual | Indent to left and re-select
`gh` | Normal | Show highlight group that matches current cursor
`gp` | Normal | Select last paste
`Q` | Normal | Start/stop macro recording
`gQ` | Normal | Play macro 'q'
`mj`/`mk` | Normal/Visual | Move lines down/up
`cp` | Normal | Duplicate paragraph
`cn`/`cN` | Normal/Visual | Change current word in a repeatable manner
`s` | Visual | Replace within selected area
`Ctrl`+`a` | Command | Navigation in command line
`Ctrl`+`b` | Command | Move cursor backward in command line
`Ctrl`+`f` | Command | Move cursor forward in command line
`Ctrl`+`r` | Visual | Replace selection with step-by-step confirmation
`,`+`Space` | Normal | Remove all spaces at EOL
`<leader>`+`<leader>` | Normal | Enter visual line-mode
`<leader>`+`a` | Normal | Align paragraph
`<leader>`+`os` | Normal | Load last session
`<leader>`+`se` | Normal | Save current workspace as last session
`<leader>`+`d` | Normal/Visual | Duplicate line or selection
`<leader>`+`S` | Normal/Visual | Source selection
`<leader>`+`ml` | Normal | Append modeline

### File Operations

Key   | Mode | Action
----- |:----:| ------------------
`<leader>`+`cd` | Normal | Switch to the directory of opened buffer (:lcd %:p:h)
`<leader>`+`w` | Normal/visual | Write (:w)
`<leader>`+`y` / `<leader>`+`Y` | Normal | Copy (relative / absolute) file-path to clipboard
`Ctrl`+`s` | _All_ | Write (:w)
`W!!` | Command | Write as root

### Editor UI

Key   | Mode | Action
----- |:----:| ------------------
`<leader>`+`ti` | Normal | Toggle indentation lines
`<leader>`+`ts` | Normal | Toggle spell-checker (:setlocal spell!)
`<leader>`+`tn` | Normal | Toggle line numbers (:setlocal nonumber!)
`<leader>`+`tl` | Normal | Toggle hidden characters (:setlocal nolist!)
`<leader>`+`th` | Normal | Toggle highlighted search (:set hlsearch!)
`<leader>`+`tw` | Normal | Toggle wrap (:setlocal wrap! breakindent!)
`ge` | Normal | Create a new tab (:tabnew)
`g0` | Normal | Go to first tab (:tabfirst)
`g$` | Normal | Go to last tab (:tablast)
`gp` | Normal | Go to previous tab (:tabprevious)
`gn` | Normal | Go to next tab (:tabnext)
`Ctrl`+`j` | Normal | Move to split below (\<C-w>j)
`Ctrl`+`k` | Normal | Move to upper split (\<C-w>k)
`Ctrl`+`h` | Normal | Move to left split (\<C-w>h)
`Ctrl`+`l` | Normal | Move to right split (\<C-w>l)
`*` | Visual | Search selection forwards
`#` | Visual | Search selection backwards
`<leader>`+`j` | Normal | Next on location list
`<leader>`+`k` | Normal | Previous on location list
`<leader>`+`b` | Normal | Toggle colorscheme background dark/light
`s`+`-` | Normal | Lower colorscheme contrast (Support solarized8)
`s`+`=` | Normal | Raise colorscheme contrast (Support solarized8)

### Window Management

Key   | Mode | Action
----- |:----:| ------------------
`q` | Normal | Quit window (and Vim, if last window)
`Tab` | Normal | Next window in tab
`Shift`+`Tab` | Normal | Previous window in tab
`Ctrl`+`Tab` | Normal | Next tab
`Ctrl`+`Shift`+`Tab` | Normal | Previous tab
`\`+`\` | Normal | Jump to last tab
`s`+`v` | Normal | Horizontal split (:split)
`s`+`g` | Normal | Vertical split (:vsplit)
`s`+`t` | Normal | Open new tab (:tabnew)
`s`+`o` | Normal | Close other windows (:only)
`s`+`x` | Normal | Remove buffer, leave blank window
`s`+`q` | Normal | Closes current buffer (:close)
`s`+`Q` | Normal | Removes current buffer (:bdelete)
`<leader>`+`sv` | Normal | Split with previous buffer
`<leader>`+`sg` | Normal | Vertical split with previous buffer

### Plugin: Denite

Key   | Mode | Action
----- |:----:| ------------------
`;`+`r` | Normal | Resumes last Denite window
`;`+`f` | Normal | File search
`;`+`b` | Normal | Buffers and MRU
`;`+`d` | Normal | Directories
`;`+`l` | Normal | Location list
`;`+`q` | Normal | Quick fix
`;`+`n` | Normal | Dein plugin list
`;`+`g` | Normal | Grep search
`;`+`j` | Normal | Jump points
`;`+`o` | Normal | Outline tags
`;`+`s` | Normal | Sessions
`;`+`t` | Normal | Tag under cursor
`;`+`p` | Normal | Jump to previous position
`;`+`h` | Normal | Help
`;`+`v` | Normal/Visual | Register
`;`+`z` | Normal | Z (jump around)
`;`+`;` | Normal | Command history
`;`+`/` | Normal | Buffer lines
`;`+`*` | Normal | Match line
`<leader>`+`gl` | Normal | Git log (all)
`<leader>`+`gs` | Normal | Git status
`<leader>`+`gc` | Normal | Git branches
`<leader>`+`gf` | Normal | Grep word under cursor
`<leader>`+`gg` | Normal/Visual | Grep word under cursor
| **Within _Denite_ mode** |||
`Escape` | Normal/Insert | Toggle modes
`jj` | Insert | Leave Insert mode
`qq` | Insert | Quit Denite mode
`Ctrl`+`y` | Insert | Redraw
`r` | Normal | Redraw
`st` | Normal | Open in a new tab
`sg` | Normal | Open in a vertical split
`sv` | Normal | Open in a split
`'` | Normal | Toggle mark current candidate
`X` | Normal | Toggle quick move

### Plugin: NERDTree

Key   | Mode | Action
----- |:----:| ------------------
`<leader>`+`e` | Normal | Toggle file explorer
`<leader>`+`ea` | Normal | Toggle file explorer on current file
| **Within _NERDTree_ buffers** |||
`h/j/k/l` | Normal | Movement + collapse/expand + file open
`w` | Normal | Toggle window size
`N` | Normal | Create new file or directory
`yy` | Normal | Yank selected item to clipboard
`st` | Normal | Open file in new tab
`sv` | Normal | Open file in a horizontal split
`sg` | Normal | Open file in a vertical split
`&` | Normal | Jump to project root
`gh` | Normal | Jump to user's home directory
`gd` | Normal | Open split diff on selected file
`gf` | Normal | Search in selected directory for files
`gr` | Normal | Grep in selected directory

### Plugin: Deoplete / Emmet / Neocomplete

Key   | Mode | Action
----- |:----:| ------------------
`Enter` | Insert | Select completion or expand snippet
`Tab` | Insert/select | Smart tab movement or completion
`Ctrl`+`j/k/f/b/d/u` | Insert | Movement in completion pop-up
`Ctrl`+`<Return>` | Insert | Expand Emmet sequence
`Ctrl`+`o` | Insert | Expand snippet
`Ctrl`+`g` | Insert | Refresh candidates
`Ctrl`+`l` | Insert | Complete common string
`Ctrl`+`e` | Insert | Cancel selection and close pop-up
`Ctrl`+`y` | Insert | Close pop-up

### Plugin: Commentary

Key   | Mode | Action
----- |:----:| ------------------
`<leader>`+`v` | Normal/visual | Toggle single-line comments
`<leader>`+`V` | Normal/visual | Toggle comment block

### Plugin: Edge Motion

Key   | Mode | Action
----- |:----:| ------------------
`g`+`j` | Normal/Visual | Jump to edge downwards
`g`+`k` | Normal/Visual | Jump to edge upwards

### Plugin: QuickHL

Key   | Mode | Action
----- |:----:| ------------------
`<leader>`+`,` | Normal/Visual | Toggle highlighted word

### Plugin: Expand-Region

Key   | Mode | Action
----- |:----:| ------------------
`v` | Visual/select | Expand selection
`V` | Visual/select | Reduce selection

### Plugin: Easymotion

Key   | Mode | Action
----- |:----:| ------------------
`s`+`s` | Normal | Jump to two characters from input
`s`+`d` | Normal | Jump to a character from input
`s`+`f` | Normal | Jump over-windows
`s`+`h` | Normal | Jump backwards in-line
`s`+`l` | Normal | Jump forwards in-line
`s`+`j` | Normal | Jump downwards
`s`+`k` | Normal | Jump upwards
`s`+`/` | Normal/operator | Jump to free-search
`s`+`n` | Normal | Smart next occurrence
`s`+`p` | Normal | Smart previous occurrence

### Plugin: ChooseWin

Key   | Mode | Action
----- |:----:| ------------------
`-` | Normal | Choose a window to edit
`<leader>`+`-` | Normal | Switch editing window with selected

### Plugin: Bookmarks

Key   | Mode | Action
----- |:----:| ------------------
`m`+`a` | Normal | Show list of all bookmarks
`m`+`m` | Normal | Toggle bookmark in current line
`m`+`n` | Normal | Jump to next bookmark
`m`+`p` | Normal | Jump to previous bookmark
`m`+`i` | Normal | Annotate bookmark

### Plugin: Easygit

Key   | Mode | Action
----- |:----:| ------------------
`<leader>`+`ga` | Normal | Git add current file
`<leader>`+`gS` | Normal | Git status
`<leader>`+`gd` | Normal | Git diff
`<leader>`+`gD` | Normal | Close diff
`<leader>`+`gc` | Normal | Git commit
`<leader>`+`gb` | Normal | Git blame
`<leader>`+`gB` | Normal | Open in browser
`<leader>`+`gp` | Normal | Git push

### Plugin: GitGutter

Key   | Mode | Action
----- |:----:| ------------------
`<leader>`+`hj` | Normal | Jump to next hunk
`<leader>`+`hk` | Normal | Jump to previous hunk
`<leader>`+`hs` | Normal | Stage hunk
`<leader>`+`hr` | Normal | Revert hunk
`<leader>`+`hp` | Normal | Preview hunk

### Plugin: Linediff

Key   | Mode | Action
----- |:----:| ------------------
`,`+`df` | Visual | Mark lines and open diff if 2nd region
`,`+`da` | Visual | Mark lines for diff
`,`+`ds` | Normal | Shows the diff between all the marked areas
`,`+`dr` | Normal | Removes the signs denoting the diff'ed regions

### Misc Plugins

Key   | Mode | Action
----- |:----:| ------------------
`m`+`g` | Normal | Open Magit
`<leader>`+`l` | Normal | Open sidemenu
`<leader>`+`o` | Normal | Open tag-bar
`<leader>`+`G` | Normal | Toggle distraction-free writing
`<leader>`+`gu` | Normal | Open undo tree
`<leader>`+`W` | Normal | Wiki
`<leader>`+`K` | Normal | Thesaurus
`<leader>`+`?` | Normal | Dictionary (macOS only)
