{
  description = "Example nix-darwin system flake";

  inputs = {
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
    }:
    let
      configuration =
        { pkgs, config, ... }:
        {
          environment.systemPackages = [
            pkgs.bitwarden-desktop
            pkgs.firefox-bin
            # pkgs.git
            pkgs.fzf
            pkgs.git-fork
            pkgs.go
            pkgs.iterm2
            pkgs.mkalias
            pkgs.monitorcontrol
            pkgs.nixfmt-rfc-style
            pkgs.neovim
            pkgs.obsidian
            pkgs.orbstack
            pkgs.raycast
            # pkgs.spotify
            # pkgs.tmux
            pkgs.vscode
            # pkgs.warp-terminal
          ];

          fonts.packages = with pkgs; [
            nerd-fonts.jetbrains-mono
          ];

          homebrew = {
            enable = true;
            brews = [
              "mas"
            ];
            casks = [
            ];
            masApps = {
            };
            onActivation.cleanup = "zap";
            onActivation.autoUpdate = true;
            onActivation.upgrade = true;
          };

          nix.settings.experimental-features = "nix-command flakes";

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
              "${pkgs.firefox-bin}/Applications/Firefox.app"
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
