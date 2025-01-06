{ pkgs, ... }:
let
  lib = pkgs.lib;

  skunkKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAqmDqRIyYfc7+Et/uj8BAbJuOy7B3GpV0MKNegeKCT3"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMTD93FB+x5mcKXvaEI8piYJUgAcfKTHiGrSf2gm3Cq2"
  ];

  sysopKeys = skunkKeys;

in {
  lawModules = [
    /core/gnupg
  ];

  systemUsers = [ "skunk" ];

  packages = with pkgs; [
    qemu_full
    mailutils
  ];

  system = {
    programs.nix-ld.enable = true;

    users.users.skunk = {
      description = "skunk (sysop)";
      extraGroups = [ "networkmanager" "wheel" "libvirtd" ];

      openssh.authorizedKeys.keys = skunkKeys;
    };

    time.timeZone = "America/Bahia";
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };

      zfs = {
        devNodes = "/dev/disk/by-label";
        extraPools = [ "zpool" ];
        forceImportRoot = true;
      };

      kernelModules = [
        "zfs"
        "kvm-intel"
        "vfio_virqfd"
        "vfio_pci"
        "vfio_iommu_type1"
        "vfio"
      ];

      kernelParams = [
        "intel_iommu=on"
        "kvm.ignore_msrs=1"
        "ip=dhcp"
      ];

      initrd.network = {
        enable = true;

        ssh = {
          shell = "/bin/cryptsetup-askpass";
          authorizedKeys = sysopKeys;
          hostKeys = [ "/nix/secret/initrd/ssh_host_ed25519_key" ];
        };
      };
    };

    networking = {
      nameservers = [ "1.1.1.1" "8.8.8.8" ];

      firewall = {
        allowedTCPPorts = [ 22 ];
        allowedUDPPorts = [];
      };
    };

    services = {
      nfs.server.enable = true;

      zfs = {
        trim.enable = false;
        autoScrub.enable = true;

        autoSnapshot = {
          enable = true;

          frequent = 4;
          hourly = 24;
          daily = 7;
          weekly = 4;
          monthly = 1;
        };
      };

      openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
        };
      };
    };

    virtualisation.libvirtd = {
      enable = true;

      onBoot = "start";
      onShutdown = "suspend";

      qemu = {
        runAsRoot = false;
        swtpm.enable = true;
        ovmf.enable = true;
      };

      nss = {
        enable = true;
        enableGuest = true;
      };
    };
  };
}
