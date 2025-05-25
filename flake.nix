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
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        sysroot = import ./sysroot { inherit pkgs; };

        cgoLdflags = "-Wl,-rpath=${sysroot}/sysroot/lib -lz -lssl";

        go-with-sysroot = pkgs.stdenv.mkDerivation {
          name = "go-with-sysroot";
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
  -isystem ${sysroot}/sysroot/include \
  -L${sysroot}/sysroot/lib \
  "\$@"
EOF
            chmod +x $out/bin/cc
          '';
        };

        bazelrcGenerated = pkgs.runCommand "bazelrc-generated" {} ''
          mkdir -p $out/etc/bazel
          cat > $out/etc/bazel/bazelrc.generated <<EOF
        build:local-sysroot --repo_env=CGO_ENABLED=1
        build:local-sysroot --repo_env=CC=\$(pwd)/cc_wrapper.sh
        build:local-sysroot --repo_env=CGO_CFLAGS=-I\$(pwd)/external/+_repo_rules+bazel_sysroot_tarball/include
        build:local-sysroot --repo_env=CGO_LDFLAGS="-L\$(pwd)/external/+_repo_rules+bazel_sysroot_tarball/lib -Wl,-rpath=\$(pwd)/external/+_repo_rules+bazel_sysroot_tarball/lib -lz -lssl -lxml2 -lyaml -lffi -ledit -lncurses"

        build:local-sysroot --action_env=CGO_ENABLED=1
        build:local-sysroot --action_env=CC=\$(pwd)/cc_wrapper.sh
        build:local-sysroot --action_env=CGO_CFLAGS=-I\$(pwd)/external/+_repo_rules+bazel_sysroot_tarball/include
        build:local-sysroot --action_env=CGO_LDFLAGS="-L\$(pwd)/external/+_repo_rules+bazel_sysroot_tarball/lib -Wl,-rpath=\$(pwd)/external/+_repo_rules+bazel_sysroot_tarball/lib -lz -lssl -lxml2 -lyaml -lffi -ledit -lncurses"
        EOF
        '';

      in {
        packages = {
          default = go-with-sysroot;
          go-with-sysroot = go-with-sysroot;
          sysroot = sysroot;
          bazelrcGenerated = bazelrcGenerated;
        };

        devShells.default = pkgs.mkShell {
          name = "bazel-sysroot-shell";
          packages = [ pkgs.bazel_7 pkgs.clang pkgs.go ];
          shellHook = ''
            echo "Sysroot ready at: result/"
            echo "Run: cp result/etc/bazel/bazelrc.generated .bazelrc.generated"
          '';
        };
      }
    );
}

# end
