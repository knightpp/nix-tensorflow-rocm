{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
}:
buildPythonPackage rec {
  pname = "libclang";
  version = "16.0.6";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "sighingnow";
    repo = "libclang";
    rev = "llvm-${version}";
    hash = "sha256-YTeARLUL7RP3nbBrVMi1OuP+gwx+6XIqL3j5GBKvAxc=";
  };

  doCheck = false;

  pythonImportsCheck = ["clang" "clang.cindex" "clang.enumerations"];

  meta = with lib; {
    description = "(Unofficial) Release libclang (clang.cindex) on pypi";
    homepage = "https://github.com/sighingnow/libclang";
    license = licenses.asl20;
    maintainers = with maintainers; [knightpp];
  };
}
