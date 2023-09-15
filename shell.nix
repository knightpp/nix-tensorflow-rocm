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

  # python = let
  #   packageOverrides = self: super: {
  #     gast = super.gast.overridePythonAttrs (old: rec {
  #       version = "0.4.0";
  #       src =
  #         old.src
  #         // {
  #           inherit version;
  #           hash = pkgs.lib.fakeHash;
  #         };
  #     });
  #   };
  # in
  #   pkgs.python310.override {
  #     inherit packageOverrides;
  #     self = python;
  #   };
  python = pkgs.python310;
in
  stdenv.mkDerivation {
    name = "dev-env";

    env = {
      LD_LIBRARY_PATH = libs;
      CUDA_PATH = pkgs.cudaPackages.cudatoolkit;
      CUDNN_PATH = pkgs.cudaPackages.cudnn;
      OCL_ICD_VENDORS = "${pkgs.rocm-opencl-icd}/etc/OpenCL/vendors/";
      HSA_OVERRIDE_GFX_VERSION = amdgpuVersions.gfx908;
    };

    buildInputs = builtins.attrValues {
      python = python.withPackages (ps:
        builtins.attrValues {
          inherit
            (ps)
            virtualenv
            # matplotlib
            
            # ipykernel
            
            ;
          tensorflow-rocm = ps.buildPythonPackage rec {
            pname = "tensorflow-rocm";
            version = "2.11.1.550";
            # src = pkgs.fetchFromGitHub {
            #   owner = "ROCmSoftwarePlatform";
            #   repo = "tensorflow-upstream";
            #   rev = "v${version}";
            #   sha256 = "sha256-Rq5pAVmxlWBVnph20fkAwbfy+iuBNlfFy14poDPd5h0=";
            # };
            format = "wheel";
            src = pkgs.fetchPypi {
              pname = "tensorflow_rocm";
              inherit version format;

              dist = "cp310";
              python = "cp310";
              abi = "cp310";
              platform = "manylinux2014_x86_64";

              sha256 = "sha256-dwKpKWq3bA8mLvQM+xe3SP6t9fSXSzaFiACrYImrFpI=";
            };
            doCheck = false;
            nativeBuildInputs = [pkgs.python310];
            propagatedBuildInputs = builtins.attrValues {
              inherit
                (ps)
                absl-py
                astunparse
                flatbuffers
                google-pasta
                grpcio
                h5py
                jax
                keras
                # libclang
                
                numpy
                opt-einsum
                packaging
                protobuf
                setuptools
                six
                tensorboard
                tensorflow-estimator
                # tensorflow-io-gcs-filesystem
                
                termcolor
                typing-extensions
                wrapt
                ;
            };
          };
        });
    };

    shellHook = ''
      . ./.venv/bin/activate
      exec fish
    '';
  }
