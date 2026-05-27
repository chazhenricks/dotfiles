for conf in "$HOME/dotfiles/zsh/"*.zsh; do 
  source "${conf}"
done
unset conf

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/chaz.henricks/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
eval "$(/opt/homebrew/bin/mise activate)"
