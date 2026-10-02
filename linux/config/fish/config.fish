### --- PATH & ENVIRONMENT (Keep these at the top) ---
set PATH /usr/bin:/usr/local/bin $PATH
set -gx TERMINAL alacritty
set -gx XTERM alacritty

# Bun setup
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# Remove welcome greeting.
set -g fish_greeting

### --- INTERACTIVE CONFIG ---
if status is-interactive
    # 1. DEFINE WALLPAPER COLORS (Indigo/Coral Palette) - de tu config anterior
    set -l foreground d9e0ee
    set -l selection  434c5e
    set -l comment    626b7c
    set -l red        f25056
    set -l cyan       89dceb
    set -l blue       7082a0

    # 2. APPLY COLORS TO FISH INTERFACE
    set -g fish_color_normal $foreground
    set -g fish_color_command $cyan --bold
    set -g fish_color_quote $blue
    set -g fish_color_redirection $foreground
    set -g fish_color_end $red
    set -g fish_color_error $red
    set -g fish_color_param $foreground
    set -g fish_color_comment $comment
    
    # 3. PAGER COLORS
    set -g fish_pager_color_progress $comment
    set -g fish_pager_color_prefix $cyan
    set -g fish_pager_color_completion $foreground
    set -g fish_pager_color_description $comment
    set -g fish_pager_color_selected_background --background=$selection

    # 4. DOTFILES XFCE 2026 - System info (neofetch o fastfetch)
    if command -q neofetch
        neofetch
    else if command -q fastfetch
        fastfetch
    end

    # 5. Starship prompt (del dotfile)
    starship init fish | source
end
