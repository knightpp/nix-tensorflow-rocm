{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  python,
  bash,
  bazel_6,
  buildBazelPackage,
  rocm-core,
  hip,
  buildEnv,
  miopen-hip,
  rocblas,
  rocrand,
  rocfft,
  hipfft,
  roctracer,
  hipsparse,
  hipsolver,
  rocsolver,
  writeShellScriptBin,
  rccl,
  hipblas,
}: let
  pname = "tensorflow-rocm";
  version = "2.14.0-rc1";
  gpuTargets = ["gfx1012"];
  bazel-build = buildBazelPackage rec {
    name = "bazel-build-${pname}-${version}";

    src = fetchFromGitHub {
      owner = "ROCmSoftwarePlatform";
      repo = "tensorflow-upstream";
      rev = "v${version}";
      hash = "sha256-hE+HeADzdGLK8bRqz4ku6DnTxh1vvm8DPNm5CiYldMw=";
    };

    patches = [./system-python.patch];

    bazel = bazel_6;

    buildInputs = [
      rocm-core
      hip
      miopen-hip
      rocblas
      rocrand
      rocfft
      hipfft
      roctracer
      hipsparse
      hipsolver
      rocsolver
      rccl
      hipblas
      (writeShellScriptBin "rocm_agent_enumerator" ''
        echo -e "${builtins.concatStringsSep "\n" gpuTargets}"
      '')
    ];

    bazelTargets = ["//tensorflow/tools/pip_package:build_pip_package"];
    bazelFlags = [
      "--config=opt"
      "--config=rocm"
      "--verbose_failures"
      "--toolchain_resolution_debug=regex"
      "--config=system_python"
    ];

    postPatch = ''
      rm -f .bazelversion
    '';

    env = {
      PYTHON_BIN_PATH = "${python.interpreter}";
      # AMDGPU_TARGETS = "${builtins.concatStringsSep "," gpuTargets}"
    };

    configureScript = "${bash}/bin/bash ./configure";
    dontAddPrefix = true;
    preConfigure = let
      libs = buildEnv {
        name = "libs";
        paths = buildInputs;
      };
    in ''
      export ROCM_PATH="${libs}"
      export PYTHON_BIN_PATH="${python.interpreter}"
      export TF_PYTHON_VERSION="${lib.versions.majorMinor python.version}"
      export TF_NEED_CLANG=0
      export TF_NEED_ROCM=1
    '';

    fetchAttrs = {
      inherit bazelTargets;
      inherit bazelFlags;

      sha256 = lib.fakeSha256;
    };

    buildAttrs = {
      outputs = ["out"];

      inherit bazelFlags;

      installPhase = ''
        ./bazel-bin/tensorflow/tools/pip_package/build_pip_package $out --rocm
      '';
    };
  };
in
  buildPythonPackage {
    inherit pname version;
    pyproject = false;

    src = bazel-build;

    meta = with lib; {
      description = "TensorFlow ROCm port";
      homepage = "https://github.com/ROCmSoftwarePlatform/tensorflow-upstream";
      license = licenses.asl20;
      maintainers = with maintainers; [knightpp];
      mainProgram = "tensorflow-rocm";
      platforms = platforms.all;
    };
  }
