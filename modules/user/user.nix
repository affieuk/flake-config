{ options, config, pkgs, lib, ... }:

with lib;
let cfg = config.ultra.user;
in {
  options.ultra.user = with types; {
    name = mkOpt str "short" "The name to use for the user account.";
    fullName = mkOpt str "Jake Hamilton" "The full name of the user.";
    email = mkOpt str "jake.hamilton@hey.com" "The email of the user.";
    initialPassword = mkOpt str "password"
      "The initial password to use when the user is first created.";
    icon = mkOpt path ./profile.jpg "The profile picture to use for the user.";
    extraGroups = mkOpt (listOf str) [ ] "Groups for the user to be assigned.";
    extraOptions = mkOpt attrs { }
      "Extra options passed to <option>users.users.<name></option>.";
  };

  config = {
    ultra.home.file.".face/${builtins.baseNameOf cfg.icon}".source = cfg.icon;

    environment.systemPackages = with pkgs; [
      starship
    ];

    programs.zsh = {
      enable = true;
      autosuggestions.enable = true;
      histFile = "$XDG_CACHE_HOME/zsh.history";
      promptInit = ''
        eval $(starship init zsh)
      '';
    };

    ultra.home.configFile."starship.toml".source = ./starship.toml;

    users.users.${cfg.name} = {
      isNormalUser = true;

      name = cfg.name;
      home = "/home/${cfg.name}";
      group = "users";

      shell = pkgs.zsh;

      # Arbitrary user ID to use for the user. Since I only
      # have a single user on my machines this won't ever collide.
      # However, if you add multiple users you'll need to change this
      # so each user has their own unique uid (or leave it out for the
      # system to select).
      uid = 1000;

      extraGroups = [ "wheel" ] ++ cfg.extraGroups;
    } // cfg.extraOptions;
  };
}
