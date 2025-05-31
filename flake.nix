#
# flake.nix
#
{
  description = "Hermetic sysroot for Bazel with Clang, glibc, and Go";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      # Define supported architectures and their mappings
      # Nix system -> Bazel platform name
      supportedSystems = {
        x86_64-linux = {
          bazel = "amd64";
          nix = "x86_64-linux";
        };
        aarch64-linux = {
          bazel = "arm64";
          nix = "aarch64-linux";
        };
      };

      # Create a function to generate outputs for each system
      mkOutputs = system:
        let
          # For each system, we need to build for both architectures
          mkSysrootLib = targetSystem:
            let
              crossSystem = {
                config = if targetSystem == "x86_64-linux" then "x86_64-unknown-linux-gnu"
                        else if targetSystem == "aarch64-linux" then "aarch64-unknown-linux-gnu"
                        else throw "Unsupported system: ${targetSystem}";
              };

              pkgs = import nixpkgs {
                inherit system;
                crossSystem = crossSystem;
              };
            in
            import ./sysroot_lib { inherit pkgs system; };

          # Build sysroot-library for the current system
          pkgs = import nixpkgs { inherit system; };
          sysrootLibrary = import ./sysroot_library { inherit pkgs; };

          # Build sysroot-lib for both architectures
          sysrootLibAmd64 = mkSysrootLib "x86_64-linux";
          sysrootLibArm64 = mkSysrootLib "aarch64-linux";

          archInfo = supportedSystems.${system};
          bazelArch = archInfo.bazel;

          cgoLdflags = "-Wl,-rpath=${sysrootLibAmd64}/sysroot/amd64/lib -lz -lssl";

          go-with-sysroot = pkgs.stdenv.mkDerivation {
            name = "go-with-sysroot-${bazelArch}";
            dontUnpack = true;
            buildInputs = [ pkgs.go ];
            installPhase = ''
              mkdir -p $out/bin

              for f in ${pkgs.go}/bin/*; do
                ln -s "$f" $out/bin/
              done

              cat > $out/bin/cc <<EOF
#!/bin/sh
exec ${pkgs.clang}/bin/clang \
  -Wno-error=unused-command-line-argument \
  -isystem ${sysrootLibrary}/sysroot/library/include \
  -L${sysrootLibAmd64}/sysroot/amd64/lib \
  "\$@"
EOF
              chmod +x $out/bin/cc
            '';
          };

          bazelrcGenerated = pkgs.runCommand "bazelrc-generated-${bazelArch}" {} ''
            mkdir -p $out/etc/bazel
            cat > $out/etc/bazel/bazelrc.generated <<EOF
          build:local-sysroot --repo_env=CGO_ENABLED=1
          build:local-sysroot --repo_env=CC=\$(pwd)/cc_wrapper.sh
          build:local-sysroot --repo_env=CGO_CFLAGS=-I\$(pwd)/external/+_repo_rules+bazel_sysroot_tarball/library/include
          build:local-sysroot --repo_env=CGO_LDFLAGS="-L\$(pwd)/external/+_repo_rules+bazel_sysroot_tarball/${bazelArch}/lib -Wl,-rpath=\$(pwd)/external/+_repo_rules+bazel_sysroot_tarball/${bazelArch}/lib -lz -lssl -lxml2 -lyaml -lffi -ledit -lncurses"

          build:local-sysroot --action_env=CGO_ENABLED=1
          build:local-sysroot --action_env=CC=\$(pwd)/cc_wrapper.sh
          build:local-sysroot --action_env=CGO_CFLAGS=-I\$(pwd)/external/+_repo_rules+bazel_sysroot_tarball/library/include
          build:local-sysroot --action_env=CGO_LDFLAGS="-L\$(pwd)/external/+_repo_rules+bazel_sysroot_tarball/${bazelArch}/lib -Wl,-rpath=\$(pwd)/external/+_repo_rules+bazel_sysroot_tarball/${bazelArch}/lib -lz -lssl -lxml2 -lyaml -lffi -ledit -lncurses"
          EOF
          '';
        in {
          packages = {
            default = go-with-sysroot;
            "go-with-sysroot-${bazelArch}" = go-with-sysroot;
            "sysroot-library" = sysrootLibrary;
            "sysroot-lib-amd64" = sysrootLibAmd64;
            "sysroot-lib-arm64" = sysrootLibArm64;
            "bazelrcGenerated-${bazelArch}" = bazelrcGenerated;
          };

          devShells.default = pkgs.mkShell {
            name = "bazel-sysroot-shell-${bazelArch}";
            packages = [ pkgs.bazel_7 pkgs.clang pkgs.go ];
            shellHook = ''
              echo "Sysroot ready at: result/"
              echo "Run: cp result/etc/bazel/bazelrc.generated .bazelrc.generated"
            '';
          };
        };
    in
    flake-utils.lib.eachDefaultSystem (system: mkOutputs system);
}

# end
