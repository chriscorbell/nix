{
  visual,
  rsCommand,
  rsuCommand,
  useDarwinOptions ? false,
}:
{ config, lib, pkgs, ... }:
let
  rs = rsCommand config;
  rsu = rsuCommand config;
  shellAliases = {
    l = null;
    ll = null;
    ls = "eza -al --icons=always";
    grep = "grep --color=auto";
    gs = "git status";
    ga = "git add .";
    gc = "git commit -m";
    gp = "git pull";
    cn = "nano ~/.config/nix/flake.nix";
    ld = "lazydocker";
    lg = "lazygit";
    rs = rs;
    rsu = rsu;
    cat = "bat --theme ansi -pp";
  };
  darwinShellAliases = builtins.removeAttrs shellAliases [ "l" "ll" ];
in
{
  environment.shellAliases = if useDarwinOptions then darwinShellAliases else { };

  programs.zsh =
    {
      enable = true;
      enableCompletion = true;
      promptInit = "";
      interactiveShellInit = ''
        export EDITOR=nano
        export VISUAL=${visual}
        export PAGER=less

        gacp() {
          git add .
          git commit -m "$*"
          branch=$(git rev-parse --abbrev-ref HEAD) || return 1
          git push origin "$branch"
        }

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
    )
    // lib.optionalAttrs (!useDarwinOptions) {
      inherit shellAliases;
    };
}
