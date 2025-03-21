# define some options used by meowos, i could duplicate shit but idc
{lib, ...}: {
  options = {
    meow.workstation.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };
}
