source $BYOBU_PREFIX/share/byobu/profiles/tmux
set-environment -g TMUX_PLUGIN_MANAGER_PATH '~/.config/byobu/plugins/'
source $HOME/myConfigs/shell/tmux/tmux-base.conf

set -g @tpm_plugins '\
  tmux-plugins/tpm \
  tmux-plugins/tmux-sensible \
  tmux-plugins/tmux-logging \
  sainnhe/tmux-fzf \
'

run '~/.config/byobu/plugins/tpm/tpm'
