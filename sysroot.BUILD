package(default_visibility = ["//visibility:public"])

filegroup(
    name = "all",
    srcs = glob([
        "lib/**",
        "include/**",
    ]),
)

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