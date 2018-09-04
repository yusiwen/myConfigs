@echo off
set vim_source=I:\git\myConfigs\vim
if not exist %LOCALAPPDATA%\nvim (
md %LOCALAPPDATA%\nvim
)
mklink /D %LOCALAPPDATA%\nvim\colors %vim_source%\colors
mklink /D %LOCALAPPDATA%\nvim\ftplugin %vim_source%\ftplugin
mklink /D %LOCALAPPDATA%\nvim\plugin %vim_source%\plugin
mklink /D %LOCALAPPDATA%\nvim\snippets %vim_source%\snippets
mklink /D %LOCALAPPDATA%\nvim\spell %vim_source%\spell
mklink /D %LOCALAPPDATA%\nvim\themes %vim_source%\themes

mklink %LOCALAPPDATA%\nvim\ctags %vim_source%\ctags
mklink %LOCALAPPDATA%\nvim\ginit.vim %vim_source%\ginit.vim
mklink %LOCALAPPDATA%\nvim\init.vim %vim_source%\init.vim
mklink %LOCALAPPDATA%\nvim\plugins.yaml %vim_source%\plugins.yaml
mklink %LOCALAPPDATA%\nvim\vimrc %vim_source%\vimrc
mklink %LOCALAPPDATA%\nvim\vimrc.denite %vim_source%\vimrc.denite
mklink %LOCALAPPDATA%\nvim\vimrc.denite.menu %vim_source%\vimrc.denite.menu
mklink %LOCALAPPDATA%\nvim\vimrc.deoplete %vim_source%\vimrc.deoplete
mklink %LOCALAPPDATA%\nvim\vimrc.filetype %vim_source%\vimrc.filetype
mklink %LOCALAPPDATA%\nvim\vimrc.goyo %vim_source%\vimrc.goyo
mklink %LOCALAPPDATA%\nvim\vimrc.mappings %vim_source%\vimrc.mappings
mklink %LOCALAPPDATA%\nvim\vimrc.neocomplete %vim_source%\vimrc.neocomplete
mklink %LOCALAPPDATA%\nvim\vimrc.neovim %vim_source%\vimrc.neovim
mklink %LOCALAPPDATA%\nvim\vimrc.nerdtree %vim_source%\vimrc.nerdtree
mklink %LOCALAPPDATA%\nvim\vimrc.theme %vim_source%\vimrc.theme

mklink %LOCALAPPDATA%\nvim\vimrc.colortheme %vim_source%\themes\vimrc.theme.sourcerer

