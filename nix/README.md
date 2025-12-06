# Nix Darwin flake

Example `nix-darwin` system flake targeting an Apple Silicon machine (`aarch64-darwin`).

## Contents

- `flake.nix` – basic nix-darwin configuration with `vim` as a sample package.
- `flake.lock` – pinned inputs (`nixpkgs` unstable and `nix-darwin` master).

## Installation

- Install Nix: https://nixos.org/download/
- Install `nix-darwin`
```zshrc
sudo nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/nix#m1pro
which darwin-rebuild
```

## Usage

```sh
nix-shell
```

Build or apply the configuration:

```sh
sudo darwin-rebuild switch --flake ~/nix.#m1pro
```

## Apps
```sh
nix search nixpkgs [pkg]
```
Or, https://search.nixos.org/packages

Or, https://github.com/NixOS/nixpkgs/tree/master/pkgs

Or, brews, casks

Or, app store via `mas search [app name]`

## Updating
```sh
nix flake update
```

## Customizing

- Add system packages under `environment.systemPackages` in `flake.nix`.
- Update the hostname/flake output name (`m1pro`) to match your machine if needed.
- Modify `nixpkgs.hostPlatform` if targeting a different architecture.
- mac os configuration 
    ```
    darwin-help
    ```
- https://mynixos.com/nix-darwin/options

## Requirements

- nix-darwin installed on macOS.
