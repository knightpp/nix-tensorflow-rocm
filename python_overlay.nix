self: super: {
  # TODO: FIX inf recursion
  # numpy = self.callPackage ./numpy.nix {};
  protobuf = super.protobuf.override {
    protobuf = super.pkgs.protobuf3_19;
  };
  tensorflow-io-gcs-filesystem = self.callPackage ./tensorflow-io-gcs-filesystem.nix {};
  libclang = self.callPackage ./libclang.nix {};
  tensorflow-rocm = self.callPackage ./tensorflow-rocm.nix {};
}
