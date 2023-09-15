{
  buildPythonPackage,
  pythonOlder,
  fetchPypi,
}:
buildPythonPackage rec {
  pname = "tensorflow-io-gcs-filesystem";
  version = "0.32.0"; # See https://github.com/tensorflow/io#tensorflow-version-compatibility
  format = "wheel";
  disabled = pythonOlder "3.10";
  src = fetchPypi {
    pname = "tensorflow_io_gcs_filesystem";
    inherit version format;
    dist = "cp310";
    python = "cp310";
    abi = "cp310";
    platform = "manylinux_2_12_x86_64.manylinux2010_x86_64";
    sha256 = "sha256-BF1Ru6WGOQ0FRfzYoYcn1isXXrFC9vTG1xnTneQHdM0=";
  };
}
