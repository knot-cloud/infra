{ ... }:
{
  system = {
    imports = [ ./hardware.nix ];

    hostname = "umbreon";
    swapDevices = [ ];

    boot.initrd = {
      luks.devices.cryptroot.device = "/dev/sda2";
      postDeviceCommands = lib.mkAfter ''
        zfs destroy zpool/root
        zfs create -o mountpoint=legacy zpool/root

	mkdir /tmp_root
	mount -t zfs zpool/root /tmp_root
	mkdir -p /tmp_root/root/keys
	umount /tmp_root
	rm /tmp_root
      '';
    };

    networking.hostId = "939caf57";

    environment.persistence."/shared" = {
      enable = true;
      hideMounts = true;

      directories = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager/system-connections"
      ];

      files = [
        "/etc/machine-id"
        "/etc/passwd"

        { file = "/var/keys/secret_file"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
      ];
    };
  };
}
