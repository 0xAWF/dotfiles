# oh-my-zsh setup 
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# aliases 
# alias vim="nvim"
alias v="nvim"
alias lg="lazygit"
alias o="open"
alias wtr="curl http://wttr.in/Kerteminde"
alias cal="icalbuddy eventsToday"
alias rustBook="rustup doc --book"
alias eTerm="nvim ~/Library/Application\ Support/com.mitchellh.ghostty/config" 
alias getAlias="grep -w 'alias' ~/.zshrc"
alias brave="open -a 'Brave Browser.app'"

function goRemoteUrl() {
    local url
    url=$(git remote get-url origin)

    if [[ "$url" == git@github.com:* ]]; then
        url=${url#git@github.com:}
        url=${url%.git}
        url="https://github.com/$url"
    fi

    if [[ "$url" == https://github.com/* ]]; then
        url=${url%.git}
    fi

    open "$url"
}

## Bash
# function goRemoteUrl() {
#     local url
#     url=$(git remote get-url origin 2>/dev/null)
#
#     if [[ "$url" == git@github.com:* ]]; then
#         url=${url#git@github.com:}
#         url=${url%.git}
#         url="https://github.com/$url"
#     fi
#
#     if [[ "$url" == https://github.com/* ]]; then
#         url=${url%.git}
#     fi
#
# Prefer wslview (part of wslu) if available
 #    if command -v wslview >/dev/null 2>&1; then
 #        wslview "$url"
 #    else
 #        # fallback to Windows default browser
 #        url_win=$(echo "$url" | sed 's|/|\|g')
 #        cmd.exe /c start "" "$url_win" >/dev/null 2>&1
 #    fi
 # }


function smart_open_widget() {
  local target
  target=$(fd -t d . --exclude .git --exclude node_modules --exclude venv --exclude 'Library' | fzf) || return 

  [[ -z "$target" ]] && return
  cd "$target" 
}
bindkey "^f" smart_open_widget

zle -N smart_open_widget
bindkey "^f" smart_open_widget

export JAVA_HOME="/opt/homebrew/opt/openjdk@21"
export PATH="$JAVA_HOME/bin:$PATH"
export CPPFLAGS="-I$JAVA_HOME/include"

# manpage highlighting
eval "$(batman --export-env)"
export PATH="/opt/homebrew/opt/postgresql@13/bin:$PATH"


#python3 paths
export LDFLAGS="-L/opt/homebrew/opt/tcl-tk/lib"
export CPPFLAGS="-I/opt/homebrew/opt/tcl-tk/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/tcl-tk/lib/pkgconfig"

eval "$(pyenv init --path)"
eval "$(pyenv init -)"
export PATH="$PATH:$(brew --prefix john-jumbo)/share/john"
export PATH="$HOME/.local/bin:$PATH"

