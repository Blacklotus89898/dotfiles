#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias blacklotus='neofetch --ascii ~/mySauce/pinklotus.txt'
alias vgrep='rg --line-number --no-heading --color=always "" \
| fzf --ansi \
      --delimiter : \
      --preview "bat --style=numbers --color=always {1} --highlight-line {2}" \
| awk -F: "{print \"+\" \$2, \$1}" \
| xargs nvim'

vfgrep() {
  local file
  local result

  # Step 1: pick file
  file=$(fzf --prompt="File > " \
    --preview 'bat --style=numbers --color=always {}') || return

  # Step 2: grep inside file and pick line
  result=$(rg --line-number --color=always "" "$file" |
    fzf --ansi \
      --delimiter : \
      --prompt="Line > " \
      --preview 'bat --style=numbers --color=always '"$file"' --highlight-line {2}') || return

  # Step 3: open in nvim at line
  local line
  line=$(echo "$result" | cut -d: -f2)

  nvim +"$line" "$file"
}

. "$HOME/.cargo/env"
source /usr/share/nvm/init-nvm.sh

# Alias for copypaste
alias c="xclip -selection clipboard"
alis v="xclip -selection clipboard -o"
