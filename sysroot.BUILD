package(default_visibility = ["//visibility:public"])

# Common filegroup for all files
filegroup(
    name = "all",
    srcs = glob([
        "lib/**",
        "include/**",
        "bin/**",
    ]),
)

# LLVM toolchain library
cc_library(
    name = "llvm_toolchain",
    srcs = glob(["lib/*.so*"]),
    hdrs = glob(["include/**/*.h"]),
    includes = ["include"],
    linkstatic = 1,
    visibility = ["//visibility:public"],
)

# Binary files
filegroup(
    name = "binaries",
    srcs = glob(["bin/*"]),
    visibility = ["//visibility:public"],
)

# libxml2 library
cc_library(
    name = "libxml2",
    srcs = ["lib/libxml2.so.2"],
    hdrs = glob(["include/libxml2/**/*.h"]),
    includes = ["include"],
    linkstatic = 0,
    visibility = ["//visibility:public"],
    deps = [],
    copts = ["-fPIC"],
    linkopts = [
        "-Wl,-rpath,$ORIGIN",
        "-Wl,-rpath,$ORIGIN/../lib",
    ],
)