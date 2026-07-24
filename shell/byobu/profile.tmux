source $BYOBU_PREFIX/share/byobu/profiles/tmux
set-environment -g TMUX_PLUGIN_MANAGER_PATH '~/.config/byobu/plugins/'

set -g @tpm_plugins '\
  tmux-plugins/tpm \
  tmux-plugins/tmux-sensible \
  tmux-plugins/tmux-logging \
  sainnhe/tmux-fzf \
  tmux-plugins/tmux-resurrect \
'

run '~/.config/byobu/plugins/tpm/tpm'

source $HOME/myConfigs/shell/tmux/tmux-base.conf
