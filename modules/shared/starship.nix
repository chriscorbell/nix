{
  environment.variables.STARSHIP_CONFIG = "/etc/starship.toml";

  environment.etc."starship.toml".text = ''
    "$schema" = 'https://starship.rs/config-schema.json'

    add_newline = false
    scan_timeout = 1000

    format = """
    $os\
    $username\
    $hostname\
    $directory\
    $git_branch\
    $git_state\
    $git_status\
    $cmd_duration\
    $python\
    $character"""

    [os]
    format = '[$symbol]($style)'
    style = 'bold white'
    disabled = false

    [os.symbols]
    Alpaquita = " "
    Alpine = " "
    AlmaLinux = " "
    Amazon = " "
    Android = " "
    Arch = " "
    Artix = " "
    CachyOS = " "
    CentOS = " "
    Debian = " "
    DragonFly = " "
    Emscripten = " "
    EndeavourOS = " "
    Fedora = " "
    FreeBSD = " "
    Garuda = "󰛓 "
    Gentoo = " "
    HardenedBSD = "󰞌 "
    Illumos = "󰈸 "
    Kali = " "
    Linux = " "
    Mabox = " "
    Macos = " "
    Manjaro = " "
    Mariner = " "
    MidnightBSD = " "
    Mint = " "
    NetBSD = " "
    NixOS = " "
    Nobara = " "
    OpenBSD = "󰈺 "
    openSUSE = " "
    OracleLinux = "󰌷 "
    Pop = " "
    Raspbian = " "
    Redhat = " "
    RedHatEnterprise = " "
    RockyLinux = " "
    Redox = "󰀘 "
    Solus = "󰠳 "
    SUSE = " "
    Ubuntu = " "
    Unknown = " "
    Void = " "
    Windows = "󰍲 "

    [username]
    style_user = 'bold cyan'
    style_root = 'bold magenta'
    format = '[$user]($style)[@](bold blue)'
    disabled = false
    show_always = true

    [hostname]
    ssh_only = false
    format = '[$hostname](bold green) '
    disabled = false

    [directory]
    style = "blue"

    [character]
    success_symbol = "[❯](purple)"
    error_symbol = "[❯](red)"
    vimcmd_symbol = "[❮](green)"

    [git_branch]
    format = "[$branch]($style)"
    style = "bright-black"

    [git_status]
    format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)"
    style = "cyan"
    conflicted = "​"
    untracked = "​"
    modified = "​"
    staged = "​"
    renamed = "​"
    deleted = "​"
    stashed = "≡"

    [git_state]
    format = '\([$state( $progress_current/$progress_total)]($style)\) '
    style = "bright-black"

    [cmd_duration]
    format = "[$duration]($style) "
    style = "yellow"

    [python]
    format = "[$virtualenv]($style) "
    style = "bright-black"
    detect_extensions = []
    detect_files = []
  '';
}
