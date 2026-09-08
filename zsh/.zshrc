ZSH="/usr/share/oh-my-zsh/"
export ZSH="/usr/share/oh-my-zsh/"
# prompt: starship (falls back to a plain prompt if not installed)
ZSH_THEME=""
plugins=(git)

ZSH_CACHE_DIR="$HOME/.cache/oh-my-zsh"
if [[ ! -d "$ZSH_CACHE_DIR" ]]; then
  mkdir "$ZSH_CACHE_DIR"
fi

source "$ZSH"/oh-my-zsh.sh
. /usr/share/nvm/init-nvm.sh

alias yeet="yay -Rn"
alias yeeet="yay -Rns"
alias yeet_useless="yay -Rns $(yay -Qtdq)"

# git
alias g="git"
alias gad="git add --all"
alias gcm="git commit -m"
alias gcms="git commit -S -m"
alias gph="git push"
alias gpl="git pull"
alias gcl="git clone"
alias gin="git init"

alias gst="git status"
alias glg="git log -n 5"
alias glgr="git reflog"
alias gdf="git diff"

alias gbr="git branch"
alias gsw="git switch"
alias gch="git checkout"
alias gra="git remote add origin git@github.com:"
alias grs="git remote set-url origin git@github.com:"

# other
alias nv="nvim"
alias la="ls -alF"
alias h="history|grep"
alias c="clear" # I know about ctrl l etc.
alias logout="killall -KILL -u $USER"
alias files="nemo"
alias files.="nemo ."
alias help="cat ~/.zshrc | less"

# cd
alias ..="cd .."
alias ....="cd ../.."
alias ......="cd ../../.."
alias ........="cd ../../../.."

# grep, ultimate search around the board
alias vg='rg --line-number --no-heading --color=always "" \
| fzf --ansi \
      --delimiter : \
      --preview "bat --style=numbers --color=always {1} --highlight-line {2}" \
| awk -F: "{print \"+\" \$2, \$1}" \
| xargs nvim'

# gets file name, then search in file
vfg() {
  local file
  local result

  # Step 1: pick file
  file=$(fzf --prompt="File > " \
             --preview 'bat --style=numbers --color=always {}') || return

  # Step 2: grep inside file and pick line
  result=$(rg --line-number --color=always "" "$file" \
    | fzf --ansi \
          --delimiter : \
          --prompt="Line > " \
          --preview 'bat --style=numbers --color=always '"$file"' --highlight-line {2}') || return

  # Step 3: open in nvim at line
  local line
  line=$(echo "$result" | cut -d: -f2)

  nvim +"$line" "$file"
}

alias lg="lazygit"

alias zealapp="/usr/local/bin/zealapp &"

# Alias for copypaste
alias c="xclip -selection clipboard"
alias v="xclip -selection clipboard -o"

# Terminal dashboard: fastfetch on fresh interactive terminals only
# (not inside tmux panes, not nested shells)
if [[ $- == *i* && -z "$TMUX" && $SHLVL -eq 1 ]] && command -v fastfetch &>/dev/null; then
  fastfetch
fi


# starship prompt (https://starship.rs) — rose pine config in ~/.config/starship.toml
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
else
  PROMPT='%F{magenta}%1~%f %# '
fi
