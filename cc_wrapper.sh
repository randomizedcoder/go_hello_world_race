#!/bin/sh

#
# cc_wrapper.sh
#

# Add sysroot and toolchain lib directories to library path
export LD_LIBRARY_PATH="$$ORIGIN/../../external/+_repo_rules+bazel_sysroot_tarball/lib:$$ORIGIN/../../external/toolchains_llvm++llvm+llvm_toolchain_llvm/lib:$LD_LIBRARY_PATH"

exec clang \
  -Wno-error=unused-command-line-argument \
  -isystem "$$ORIGIN/../../external/+_repo_rules+bazel_sysroot_tarball/include" \
  -L"$$ORIGIN/../../external/+_repo_rules+bazel_sysroot_tarball/lib" \
  -Wl,-rpath,"$$ORIGIN/../../external/+_repo_rules+bazel_sysroot_tarball/lib" \
  -Wl,--no-as-needed \
  -lxml2 \
  -fuse-ld=lld \
  -Wl,-v \
  "$@"

# end