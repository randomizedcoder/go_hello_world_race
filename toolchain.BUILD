package(default_visibility = ["//visibility:public"])

filegroup(
    name = "all",
    srcs = glob(["**"]),
)

filegroup(
    name = "binaries",
    srcs = glob(["bin/*"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "lib",
    srcs = glob(["lib/**"]),
    visibility = ["//visibility:public"],
)

cc_library(
    name = "llvm_toolchain",
    srcs = glob(["lib/*.so*"]),
    linkstatic = 1,
    visibility = ["//visibility:public"],
)