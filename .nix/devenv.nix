{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./modules/devenv_utils.nix
    ./modules/node.nix
    ./modules/cloudflare.nix
  ];

  # node for npx/wrangler, imagemagick for the hero and member photos.
  modules.node.enable = true;

  modules.cloudflare.enable = true;

  packages = [pkgs.imagemagick];
}
