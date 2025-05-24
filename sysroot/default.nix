#
# sysroot/default.nix
#
{ pkgs }:

pkgs.runCommand "sysroot" {
  sysrootInputs = with pkgs; [
    coreutils
    llvmPackages_20.libcxxClang
    llvmPackages_20.lld
    llvmPackages_20.libcxx.dev llvmPackages_20.libcxx.out
    glibc.dev glibc.out
    ncurses.dev ncurses.out
    zlib.dev zlib.out zlib
    openssl.dev openssl.out
    libyaml.dev libyaml.out
  ];
} ''
  # Create sysroot structure
  mkdir -p $out/sysroot/{include,lib}

  # Copy libc++ headers first to ensure they take precedence
  echo "Copying libc++ headers..."
  mkdir -p $out/sysroot/include/c++/v1
  cp -Lr ${pkgs.llvmPackages_20.libcxx.dev}/include/c++/v1/* $out/sysroot/include/c++/v1/ || true
  cp -Lr ${pkgs.llvmPackages_20.libcxxClang}/include/c++/v1/* $out/sysroot/include/c++/v1/ || true

  # Copy libc++'s C standard library headers
  echo "Copying libc++ C standard library headers..."
  cp -Lr ${pkgs.llvmPackages_20.libcxx.dev}/include/c++/v1/__support/libc/* $out/sysroot/include/ || true
  cp -Lr ${pkgs.llvmPackages_20.libcxxClang}/include/c++/v1/__support/libc/* $out/sysroot/include/ || true

  # Copy other headers
  echo "Copying LLVM/Clang headers..."
  cp -Lr ${pkgs.llvmPackages_20.libcxxClang}/include/* $out/sysroot/include/ || true
  cp -Lr ${pkgs.llvmPackages_20.libcxx.dev}/include/* $out/sysroot/include/ || true

  echo "Copying glibc headers..."
  cp -Lr ${pkgs.glibc.dev}/include/* $out/sysroot/include/ || true

  echo "Copying ncurses headers..."
  cp -Lr ${pkgs.ncurses.dev}/include/* $out/sysroot/include/ || true

  echo "Copying zlib headers..."
  cp -Lr ${pkgs.zlib.dev}/include/* $out/sysroot/include/ || true

  echo "Copying openssl headers..."
  cp -Lr ${pkgs.openssl.dev}/include/* $out/sysroot/include/ || true

  echo "Copying libyaml headers..."
  cp -Lr ${pkgs.libyaml.dev}/include/* $out/sysroot/include/ || true

  # Copy libraries
  echo "Copying LLVM/Clang libraries..."
  cp -Lr ${pkgs.llvmPackages_20.libcxx.out}/lib/* $out/sysroot/lib/ || true

  echo "Copying glibc libraries..."
  cp -Lr ${pkgs.glibc.out}/lib/* $out/sysroot/lib/ || true

  echo "Copying ncurses libraries..."
  cp -Lr ${pkgs.ncurses.out}/lib/* $out/sysroot/lib/ || true

  echo "Copying zlib libraries..."
  cp -Lr ${pkgs.zlib.out}/lib/* $out/sysroot/lib/ || true

  echo "Copying openssl libraries..."
  cp -Lr ${pkgs.openssl.out}/lib/* $out/sysroot/lib/ || true

  echo "Copying libyaml libraries..."
  cp -Lr ${pkgs.libyaml.out}/lib/* $out/sysroot/lib/ || true

  # Create tarball
  echo "Creating BUILD file..."
  cat > $out/sysroot/BUILD <<EOF
filegroup(
    name = "all",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)
EOF

  # Create tarball
  echo "Creating tarball..."
  cd $out
  tar czf $out/sysroot.tar.gz sysroot/

  echo "Done! Tarball created at $out/sysroot.tar.gz"
''

# end
