#!/bin/sh

#
# cc_wrapper.sh
#

# Add sysroot and toolchain lib directories to library path
export LD_LIBRARY_PATH="$PWD/external/+_repo_rules+bazel_sysroot_tarball/lib:$PWD/external/toolchains_llvm++llvm+llvm_toolchain_llvm/lib:$LD_LIBRARY_PATH"

exec clang \
  -Wno-error=unused-command-line-argument \
  -isystem "$PWD/external/+_repo_rules+bazel_sysroot_tarball/include" \
  -L"$PWD/external/+_repo_rules+bazel_sysroot_tarball/lib" \
  -Wl,-rpath,"$PWD/external/+_repo_rules+bazel_sysroot_tarball/lib" \
  -Wl,--no-as-needed \
  -Wl,--whole-archive \
  -lxml2 \
  -Wl,--no-whole-archive \
  "$@"

# end