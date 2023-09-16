{pkgs ? import <nixpkgs> {}}: let
  amdgpuVersions = {
    gfx1030 = "10.3.0";
    gfx900 = "9.0.0";
    gfx906 = "9.0.6";
    gfx908 = "9.0.8";
    gfx90a = "9.0.a";
  };
  libs = pkgs.lib.makeLibraryPath (with pkgs; [
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
    llvmPackages_rocm.libunwind
    stdenv.cc.cc.lib
    #   (pkgs.cudaPackages)
    #   cudatoolkit
    #   cudnn
  ]);

  python = pkgs.python310.override {
    packageOverrides = import ./python_overlay.nix;
  };
in
  pkgs.mkShell {
    name = "dev-env";

    env = {
      LD_LIBRARY_PATH = libs;
      # CUDA_PATH = pkgs.cudaPackages.cudatoolkit;
      # CUDNN_PATH = pkgs.cudaPackages.cudnn;
      OCL_ICD_VENDORS = "${pkgs.rocm-opencl-icd}/etc/OpenCL/vendors/";
      HSA_OVERRIDE_GFX_VERSION = amdgpuVersions.gfx1030;
    };

    buildInputs = [
      (
        python.buildEnv.override {
          extraLibs = with python.pkgs; [
            virtualenv
            tensorflow-rocm
          ];
          ignoreCollisions = true;
        }
      )
    ];

    shellHook = ''
      exec fish
    '';
  }
