{
  description = "A very basic flake";

  outputs = inputs:
    {
      lib = import ./lib.nix;
    };
}
