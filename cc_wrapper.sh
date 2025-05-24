#!/bin/sh

#
# cc_wrapper.sh
#
exec clang \
  -Wno-error=unused-command-line-argument \
  -isystem "$PWD/bazel-out/k8-fastbuild/bin/sysroot/sysroot/include" \
  -L"$PWD/bazel-out/k8-fastbuild/bin/sysroot/sysroot/lib" \
  "$@"

# end