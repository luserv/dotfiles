# Omarchy's shell tools and minimal Starship prompt.

if status is-interactive
    set -g fish_greeting

    starship init fish | source
    fzf --fish | source
end

if command -q eza
    alias ls 'eza -lh --group-directories-first --icons=auto'
    alias lsa 'eza -lah --group-directories-first --icons=auto'
    alias lt 'eza --tree --level=2 --long --icons --git'
    alias lta 'eza --tree --level=2 --long --icons --git --all'
end

if command -q fzf; and command -q bat
    function ff
        fzf --preview 'bat --style=numbers --color=always {}'
    end

    function eff
        set -l file (ff)
        test -n "$file"; and $EDITOR "$file"
    end
end

alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias g git
alias c 'opencode --auto'
alias t 'tmux attach 2>/dev/null; or tmux new -s Work'
alias h herdr

function n
    if test (count $argv) -eq 0
        command nvim .
    else
        command nvim $argv
    end
end

if command -q zoxide
    zoxide init fish | source
end

if command -q mise
    mise activate fish | source
end

function open
    xdg-open $argv >/dev/null 2>&1 &
end
