if status is-interactive
    # Commands to run in interactive sessions can go here
    source $HOME/myConfigs/shell/scripts/00-environment.fish
    source $HOME/myConfigs/shell/scripts/02-functions.fish
    source $HOME/myConfigs/shell/scripts/03-programs.fish
    source $HOME/myConfigs/shell/scripts/04-keybindings.fish
    source $HOME/myConfigs/shell/scripts/06-aliases.fish

    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    if test -f /opt/runtimes/miniconda3/Scripts/conda.exe
        eval /opt/runtimes/miniconda3/Scripts/conda.exe "shell.fish" "hook" $argv | source
    else
        if test -f "/opt/runtimes/miniconda3/etc/fish/conf.d/conda.fish"
            . "/opt/runtimes/miniconda3/etc/fish/conf.d/conda.fish"
        else
            set -x PATH "/opt/runtimes/miniconda3/bin" $PATH
        end
    end
    # <<< conda initialize <<<
end
