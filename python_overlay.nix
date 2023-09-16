self: super: {
  # numpy = super.numpy.overridePythonAttrs (old: rec {
  #   version = "1.21.6";
  #   src = super.fetchPypi {
  #     pname = old.pname;
  #     inherit version;
  #     extension = "zip";
  #     sha256 = "sha256-7LVSUROXBmaf3sL/BzyY746ahEc+UecWIRtBqg8Y5lY=";
  #   };
  # });
  protobuf = super.protobuf.override {
    protobuf = super.pkgs.protobuf3_19;
  };
  tensorflow-io-gcs-filesystem = self.callPackage ./tensorflow-io-gcs-filesystem.nix {};
  libclang = self.callPackage ./libclang.nix {};
  tensorflow-rocm = self.callPackage ./tensorflow-rocm-src.nix {};
}
