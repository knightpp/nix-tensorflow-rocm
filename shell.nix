let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) stdenv;
  amdgpuVersions = {
    gfx1030 = "10.3.0";
    gfx900 = "9.0.0";
    gfx906 = "9.0.6";
    gfx908 = "9.0.8";
    gfx90a = "9.0.a";
  };
  libs = pkgs.lib.makeLibraryPath (builtins.attrValues {
    # inherit
    #   (pkgs.cudaPackages)
    #   cudatoolkit
    #   cudnn
    #   ;
    inherit (pkgs.llvmPackages_rocm) libunwind;
    inherit
      (pkgs)
      rocm-runtime
      rocm-opencl-runtime
      rocm-comgr
      rocm-smi
      miopengemm
      rocblas
      ncurses
      sqlite
      libelf
      libdrm
      numactl
      rocrand
      hipfft
      miopen
      hip
      rccl
      ;
    inherit (stdenv.cc.cc) lib;
  });

  python = pkgs.python310.override {
    packageOverrides = import ./python_overlay.nix;
  };
in
  stdenv.mkDerivation {
    name = "dev-env";

    env = {
      LD_LIBRARY_PATH = libs;
      CUDA_PATH = pkgs.cudaPackages.cudatoolkit;
      CUDNN_PATH = pkgs.cudaPackages.cudnn;
      OCL_ICD_VENDORS = "${pkgs.rocm-opencl-icd}/etc/OpenCL/vendors/";
      HSA_OVERRIDE_GFX_VERSION = amdgpuVersions.gfx1030;
    };

    buildInputs = [
      (
        python.withPackages
        (ps:
          builtins.attrValues {
            inherit
              (ps)
              virtualenv
              tensorflow-rocm
              ;
          })
      )
    ];

    shellHook = ''
      exec fish
    '';
  }
