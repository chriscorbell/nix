{
  visual,
  rsCommand,
  rsuCommand,
  useDarwinOptions ? false,
}:
{ config, pkgs, ... }:
let
  rs = rsCommand config;
  rsu = rsuCommand config;
in
{
  programs.zsh =
    {
      enable = true;
      enableCompletion = true;
      promptInit = "";
      interactiveShellInit = ''
        export EDITOR=nano
        export VISUAL=${visual}
        export PAGER=less

        alias ls='eza -al --icons=always'
        alias grep='grep --color=auto'
        alias gs='git status'
        alias ga='git add .'
        alias gc='git commit -m'
        alias gp='git pull'
        alias cn='nano ~/.config/nix/flake.nix'
        alias rs='${rs}'
        alias cat='bat --theme ansi -pp'

        gacp() {
          git add .
          git commit -m "$*"
          branch=$(git rev-parse --abbrev-ref HEAD) || return 1
          git push origin "$branch"
        }

        alias rsu='${rsu}'

        eval "$(${pkgs.atuin}/bin/atuin init zsh)"
        eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
      ''
      + (
        if useDarwinOptions then
          ""
        else
          ''
            eval "$(${pkgs.starship}/bin/starship init zsh)"
          ''
      );
    }
    // (
      if useDarwinOptions then
        {
          enableAutosuggestions = true;
          enableSyntaxHighlighting = true;
          promptInit = ''
            eval "$(${pkgs.starship}/bin/starship init zsh)"
          '';
        }
      else
        {
          autosuggestions.enable = true;
          syntaxHighlighting.enable = true;
        }
    );
}
