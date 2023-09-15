{
  buildPythonPackage,
  fetchPypi,
  absl-py,
  astunparse,
  flatbuffers,
  google-pasta,
  grpcio,
  h5py,
  jax,
  keras,
  opt-einsum,
  packaging,
  setuptools,
  six,
  tensorboard,
  tensorflow-estimator,
  termcolor,
  typing-extensions,
  wrapt,
  gast,
  pythonOlder,
  fetchFromGitHub,
  numpy,
  protobuf,
  libclang,
  tensorflow-io-gcs-filesystem,
}: let
  gast_0_4_0 =
    gast.overridePythonAttrs
    rec {
      version = "0.4.0";
      src = fetchFromGitHub {
        owner = "serge-sans-paille";
        repo = "gast";
        rev = version;
        hash = "sha256-vmjx/cULyvM6q1ZzQnQS4VkeXSto8JHZzS8PGRFQDH4=";
      };
      doCheck = false;
    };
in
  buildPythonPackage rec {
    pname = "tensorflow-rocm";
    version = "2.11.1.550";
    format = "wheel";
    disabled = pythonOlder "3.10";
    src = fetchPypi {
      pname = "tensorflow_rocm";
      inherit version format;
      dist = "cp310";
      python = "cp310";
      abi = "cp310";
      platform = "manylinux2014_x86_64";
      sha256 = "sha256-dwKpKWq3bA8mLvQM+xe3SP6t9fSXSzaFiACrYImrFpI=";
    };

    dontBuild = true;
    dontConfigure = true;
    dontPatch = true;
    dontCheck = true;

    propagatedBuildInputs = [
      libclang
      tensorflow-io-gcs-filesystem
      numpy
      gast_0_4_0
      protobuf

      absl-py
      astunparse
      flatbuffers
      google-pasta
      grpcio
      h5py
      jax
      keras
      opt-einsum
      packaging
      setuptools
      six
      tensorboard
      tensorflow-estimator
      termcolor
      typing-extensions
      wrapt
    ];
  }
