{
  description = "M1Pro nix-darwin system flake";

  inputs = {
    charmbracelet-tap = {
      url = "github:charmbracelet/homebrew-tap";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-ai-tools.url = "github:numtide/nix-ai-tools";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      nix-ai-tools,
      charmbracelet-tap,
    }:
    let
      configuration =
        { pkgs, config, ... }:
        {
          environment.systemPackages = [
            pkgs.bartender
            pkgs.bitwarden-desktop
            pkgs.bruno
            pkgs.dbeaver-bin
            pkgs.discord
            pkgs.firefox-bin
            pkgs.fzf
            pkgs.git-fork
            pkgs.go
            pkgs.iina
            pkgs.infisical
            pkgs.iterm2
            pkgs.mkalias
            pkgs.monitorcontrol
            # pkgs.neovim
            pkgs.nixfmt-rfc-style
            pkgs.nodejs_24
            pkgs.orbstack
            # pkgs.outline # notes
            pkgs.raycast
            pkgs.rectangle
            pkgs.slack
            # pkgs.soundsource
            # pkgs.spotify-player
            # pkgs.steam
            pkgs.telegram-desktop
            pkgs.texliveFull
            pkgs.the-unarchiver
            pkgs.tmux
            pkgs.tree
            pkgs.uv
            pkgs.vscode
            inputs.nix-ai-tools.packages.${pkgs.system}.crush
          ];
          environment.variables = {
            EDITOR = "code --wait";
            LC_ALL = "en_US.UTF-8";
            LANG = "en_US.UTF-8";
          };

          fonts.packages = with pkgs; [
            nerd-fonts.jetbrains-mono
          ];

          homebrew = {
            enable = true;
            brews = [
              "mas"
            ];
            casks = [
              "arc"
              "codex"
              "hammerspoon"
              "hovrly"
              "keepingyouawake"
              "onlyoffice"
              "onyx"
              "openvpn-connect"
              "protonvpn"
              "radiola"
              "spotify"
              "steam"
              "zen"
            ];
            masApps = {
              "Easy Authenticator 2FA" = 1629589835;
              "Mattermost Desktop" = 1614666244;
            };
            onActivation.cleanup = "zap";
            onActivation.autoUpdate = true;
            onActivation.upgrade = true;
          };

          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];
          nix.settings.trusted-users = [
            "root"
            "rezaharli"
          ];

          nixpkgs.config.allowUnfree = true;
          nixpkgs.hostPlatform = "aarch64-darwin";

          # programs.fish.enable = true;
          programs.zsh.enable = true;

          system.activationScripts.applications.text =
            let
              env = pkgs.buildEnv {
                name = "system-applications";
                paths = config.environment.systemPackages;
                pathsToLink = [ "/Applications" ];
              };
            in
            pkgs.lib.mkForce ''
              # Set up applications.
              echo "setting up /Applications..." >&2
              rm -rf /Applications/Nix\ Apps
              mkdir -p /Applications/Nix\ Apps
              find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
              while read -r src; do
                app_name=$(basename "$src")
                echo "copying $src" >&2
                ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
              done
            '';
          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.defaults = {
            dock.autohide = false;
            dock.persistent-apps = [
              "/System/Applications/Calendar.app"
              "/System/Applications/Mail.app"
              "/Applications/Zen.app"
              "${pkgs.iterm2}/Applications/iTerm2.app"
            ];
          };
          system.primaryUser = "rezaharli";
          system.stateVersion = 6;
        };
    in
    {
      darwinConfigurations."m1pro" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              autoMigrate = true;
              enable = true;
              enableRosetta = true;
              mutableTaps = false;
              taps = {
                "charmbracelet/homebrew-tap" = charmbracelet-tap;
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
              };
              user = "rezaharli";
            };
          }
          (
            { config, ... }:
            {
              homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
            }
          )
        ];
      };
    };
}
