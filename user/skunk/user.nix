{ pkgs, ... }:
{
  username = "skunk";

  lawModules = [
  ];

  packages = with pkgs; [
    # system administration tools
    neovim
  ];

  system = {
  };
}
