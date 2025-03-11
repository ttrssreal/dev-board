{
  boron-platform,
  fetchFromGitHub,
  perl540Packages,
  which,
  lib,
  bash,
  gcc-10-2-1,
  overrideCC,
  wrapCC,
  xxd,
  src,
  name,
}: let
  cc = wrapCC gcc-10-2-1;
  boron-stdenv = overrideCC boron-platform.stdenv cc;
in
  boron-stdenv.mkDerivation {
    inherit name;

    src = fetchFromGitHub {
      owner = "particle-iot";
      repo = "device-os";
      rev = "v6.3.0";
      fetchSubmodules = true;
      hash = "sha256-UYIPu/mL6iLnQKPS3ilAFuCS5IQKOxzQ3Oxn7Q/oKsQ=";
    };

    nativeBuildInputs = [
      perl540Packages.ArchiveZip
      which
      xxd
    ];

    patchPhase = let
      escape-path-regex = pkg: bin: lib.escape ["/"] (lib.getExe' pkg bin);
      sed-replace-bash-path = bin: "s/\\/bin\\/${bin}/${escape-path-regex bash bin}/g";
    in ''
      find . \( -type d -name .git -prune \) -o -type f -print0 \
        | xargs -0 sed                                          \
          -i "${sed-replace-bash-path "bash"};                  \
              ${sed-replace-bash-path "sh"}"
    '';

    PLATFORM = "boron";
    APPDIR = src;
    TARGET_DIR = placeholder "out";
    makeFlags = [ "v=1" "-C" "main" ];

    dontInstall = true;
  }
