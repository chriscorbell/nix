{ self, pkgs, ... }:
let
  username = "chris";
  homeDir = "/Users/${username}";
  direnvFixed = pkgs.direnv.overrideAttrs (old: {
    env = (old.env or { }) // {
      CGO_ENABLED = "1";
    };
  });
in
{
  imports = [
    ../../modules/shared/terminal-packages.nix
    ../../modules/shared/starship.nix
    (import ../../modules/shared/mk-zsh.nix {
      visual = "code";
      rsCommand = _: "sudo darwin-rebuild switch --flake ~/.config/nix#mbp";
      rsuCommand = _: "cd ~/.config/nix && nix flake update && sudo darwin-rebuild switch --flake ~/.config/nix#mbp";
      useDarwinOptions = true;
    })
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  environment.systemPackages = with pkgs; [
    age
    delta
    direnvFixed
    doggo
    dua
    dust
    entr
    fastfetch
    fortune
    gnugrep
    gnupg
    htop
    hyperfine
    iperf3
    iproute2mac
    nano
    ncdu
    nodejs_24
    rclone
    sops
    vim
    watchexec
    zellij
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  environment.etc."nanorc".text = ''
    include "${pkgs.nano}/share/nano/*.nanorc"
    include "${pkgs.nano}/share/nano/extra/*.nanorc"

    syntax "nix" "\.nix$" "flake\.lock$"
    header "^#!.*\bnix-shell\b"
    color brightblue "\<(let|in|if|then|else|with|rec|inherit|assert)\>"
    color brightblue "\<(import|builtins|true|false|null)\>"
    color brightcyan "\<(inputs|outputs)\>"
    color brightgreen "\"([^\"\\]|\\.)*\""
    color brightgreen "'([^'\\]|\\.)*'"
    color yellow "(^|[[:space:]])#.*$"
    color brightmagenta "\<(pkgs|lib|config|self|stdenv)\>"
    color brightred "(/[^[:space:];\)\]}]+)+"
    color cyan "[-[:alnum:]_+.]+[[:space:]]*="
  '';

  environment.etc."auto_master".text = ''
    #
    # Automounter master map
    #
    +auto_master
    /home               auto_home   -nobrowse,hidefromfinder
    /Network/Servers    -fstab
    /-                  -static
    /-                  auto_nas
  '';

  environment.etc."auto_nas".text = ''
    /Volumes/data-lan -fstype=nfs,resvport,tcp 10.0.0.21:/tank/data
    /Volumes/data-tailscale -fstype=nfs,resvport,tcp 100.64.45.93:/tank/data
  '';

  environment.etc."pf.conf".text = ''
    scrub-anchor "com.apple/*"
    nat-anchor "com.apple/*"
    rdr-anchor "com.apple/*"
    dummynet-anchor "com.apple/*"
    anchor "com.apple/*"
    anchor "nix-ssh"
    load anchor "com.apple" from "/etc/pf.anchors/com.apple"
    load anchor "nix-ssh" from "/etc/pf.anchors/nix-ssh"
  '';

  environment.etc."pf.anchors/nix-ssh".text = ''
    pass in quick on lo0 proto tcp from any to any port 22
    pass in quick inet proto tcp from 100.64.0.0/10 to any port 22 keep state
    pass in quick inet6 proto tcp from fd7a:115c:a1e0::/48 to any port 22 keep state
    block in quick proto tcp from any to any port 22
  '';

  homebrew = {
    enable = true;
    enableZshIntegration = true;
    vscode = [
      "bbenoist.nix"
      "catppuccin.catppuccin-vsc-icons"
      "codexbuild.codex-build"
      "ms-azuretools.vscode-containers"
      "ms-vscode-remote.remote-ssh"
      "ms-vscode-remote.remote-ssh-edit"
      "ms-vscode.remote-explorer"
      "openai.chatgpt"
      "tamasfe.even-better-toml"
    ];
    casks = [
      "adobe-creative-cloud"
      "affinity"
      "bambu-studio"
      "betterdisplay"
      "caffeine"
      "claude"
      "claude-code"
      "codex"
      "codex-app"
      "discord"
      "docker-desktop"
      "ente-auth"
      "font-inter"
      "font-jetbrains-mono-nerd-font"
      "ghostty"
      "google-chrome"
      "helium-browser"
      "iina"
      "karabiner-elements"
      "localsend"
      "maccy"
      "microsoft-edge"
      "microsoft-excel"
      "microsoft-powerpoint"
      "microsoft-teams"
      "microsoft-word"
      "motu-m-series"
      "moonlight"
      "obs"
      "proton-mail"
      "protonvpn"
      "raycast"
      "rectangle"
      "steam"
      "stremio"
      "tailscale-app"
      "telegram-desktop"
      "visual-studio-code"
      "windows-app"
      "wispr-flow"
      "zen"
      "zoom"
    ];
    onActivation.autoUpdate = true;
    onActivation.cleanup = "zap";
    onActivation.upgrade = true;
  };

  security.sudo.extraConfig = ''
    ${username} ALL = (ALL) NOPASSWD: ALL
  '';

  services.openssh.enable = true;

  launchd.daemons.nfs-mount-triggers = {
    serviceConfig = {
      Label = "org.nix-darwin.nfs-mount-triggers";
      ProgramArguments = [
        "/bin/sh"
        "-c"
        "mkdir -p /Volumes/data-lan /Volumes/data-tailscale && /usr/sbin/automount -vc"
      ];
      RunAtLoad = true;
    };
  };

  system.activationScripts.postActivation.text = ''
    ln -sf /etc/static/zshrc /etc/zshrc
    ln -sf /etc/static/zprofile /etc/zprofile

    sudo --user=${username} touch ${homeDir}/.hushlogin

    /sbin/pfctl -f /etc/pf.conf
    if ! /sbin/pfctl -s info | grep -q "Status: Enabled"; then
      /sbin/pfctl -E
    fi

    mkdir -p /Volumes/data-lan
    mkdir -p /Volumes/data-tailscale
    automount -vc || true

    sudo --user=${username} mkdir -p ${homeDir}/.config/ghostty
    cat > ${homeDir}/.config/ghostty/config <<'EOF'
    font-family = "JetBrainsMono Nerd Font Mono"
    font-size = 16
    theme = Aizen Dark
    shell-integration-features = ssh-terminfo,ssh-env,sudo
    window-padding-x = 16
    EOF
    chown ${username}:staff ${homeDir}/.config/ghostty/config

    sudo --user=${username} mkdir -p ${homeDir}/.config/karabiner
    cat > ${homeDir}/.config/karabiner/karabiner.json <<'EOF'
    {
      "global": {
        "check_for_updates_on_startup": true,
        "show_in_menu_bar": true,
        "show_profile_name_in_menu_bar": false
      },
      "profiles": [
        {
          "name": "Default profile",
          "selected": true,
          "virtual_hid_keyboard": {
            "keyboard_type_v2": "ansi"
          },
          "complex_modifications": {
            "rules": [
              {
                "description": "Caps Lock to Hyper when held, Escape when tapped",
                "manipulators": [
                  {
                    "type": "basic",
                    "from": {
                      "key_code": "caps_lock",
                      "modifiers": {
                        "optional": [ "any" ]
                      }
                    },
                    "to": [
                      {
                        "key_code": "left_shift",
                        "modifiers": [
                          "left_command",
                          "left_control",
                          "left_option"
                        ]
                      }
                    ],
                    "to_if_alone": [
                      {
                        "key_code": "escape"
                      }
                    ]
                  }
                ]
              },
              {
                "description": "Hyper app launch shortcuts",
                "manipulators": [
                  {
                    "type": "basic",
                    "from": {
                      "key_code": "t",
                      "modifiers": {
                        "mandatory": [
                          "command",
                          "control",
                          "option",
                          "shift"
                        ]
                      }
                    },
                    "to": [
                      {
                        "shell_command": "open -a Ghostty"
                      }
                    ]
                  },
                  {
                    "type": "basic",
                    "from": {
                      "key_code": "return_or_enter",
                      "modifiers": {
                        "mandatory": [
                          "command",
                          "control",
                          "option",
                          "shift"
                        ]
                      }
                    },
                    "to": [
                      {
                        "shell_command": "open -a Zen"
                      }
                    ]
                  },
                  {
                    "type": "basic",
                    "from": {
                      "key_code": "v",
                      "modifiers": {
                        "mandatory": [
                          "command",
                          "control",
                          "option",
                          "shift"
                        ]
                      }
                    },
                    "to": [
                      {
                        "shell_command": "open -a 'Visual Studio Code'"
                      }
                    ]
                  }
                ]
              }
            ]
          }
        }
      ]
    }
    EOF
    chown ${username}:staff ${homeDir}/.config/karabiner/karabiner.json

    sudo --user=${username} mkdir -p "${homeDir}/Library/Application Support/Code/User"
    cat > "${homeDir}/Library/Application Support/Code/User/settings.json" <<'EOF'
    {
      "workbench.sideBar.location": "right",
      "workbench.activityBar.location": "top",
      "window.autoDetectColorScheme": true,
      "editor.minimap.enabled": false,
      "workbench.startupEditor": "none",
      "editor.fontFamily": "'JetBrainsMono Nerd Font'",
      "editor.smoothScrolling": true,
      "editor.cursorSmoothCaretAnimation": "on",
      "workbench.list.smoothScrolling": true,
      "terminal.integrated.smoothScrolling": true,
      "editor.cursorBlinking": "smooth",
      "editor.fontSize": 14,
      "editor.minimap.sectionHeaderFontSize": 12,
      "chat.editor.fontSize": 14,
      "chat.fontSize": 14,
      "debug.console.fontSize": 14,
      "scm.inputFontSize": 14,
      "terminal.integrated.fontSize": 14,
      "chat.viewSessions.orientation": "stacked",
      "editor.stickyScroll.enabled": false,
      "chat.mcp.gallery.enabled": true
    }
    EOF
    chown ${username}:staff "${homeDir}/Library/Application Support/Code/User/settings.json"

    sudo --user=${username} mkdir -p "${homeDir}/Library/Group Containers/group.com.docker"
    if [ -f "${homeDir}/Library/Group Containers/group.com.docker/settings-store.json" ]; then
      tmpfile="$(mktemp)"
      ${pkgs.jq}/bin/jq '.AutoStart = false' "${homeDir}/Library/Group Containers/group.com.docker/settings-store.json" > "$tmpfile"
      mv "$tmpfile" "${homeDir}/Library/Group Containers/group.com.docker/settings-store.json"
    else
      cat > "${homeDir}/Library/Group Containers/group.com.docker/settings-store.json" <<'EOF'
    {
      "AutoStart": false
    }
    EOF
    fi
    chown ${username}:staff "${homeDir}/Library/Group Containers/group.com.docker/settings-store.json"

    launchctl asuser "$(id -u -- ${username})" sudo --user=${username} -- defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 '
    <dict>
      <key>enabled</key><false/>
      <key>value</key>
      <dict>
        <key>parameters</key>
        <array>
          <integer>32</integer>
          <integer>49</integer>
          <integer>262144</integer>
        </array>
        <key>type</key>
        <string>standard</string>
      </dict>
    </dict>'

    launchctl asuser "$(id -u -- ${username})" sudo --user=${username} -- defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 '
    <dict>
      <key>enabled</key><false/>
      <key>value</key>
      <dict>
        <key>parameters</key>
        <array>
          <integer>32</integer>
          <integer>49</integer>
          <integer>786432</integer>
        </array>
        <key>type</key>
        <string>standard</string>
      </dict>
    </dict>'
  '';

  system.primaryUser = username;
  system.defaults = {
    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      "com.apple.swipescrolldirection" = false;
    };

    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.5;
      mru-spaces = false;
      show-recents = false;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    trackpad.Clicking = true;
  };

  nix = {
    gc.automatic = true;
    optimise.automatic = true;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  system.stateVersion = 6;
}
