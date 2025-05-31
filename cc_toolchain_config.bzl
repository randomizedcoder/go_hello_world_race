#
# cc_toolchain_config.bzl
#
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl", "feature", "flag_group", "flag_set", "tool_path", "with_feature_set")

def _get_tool_paths(arch):
    if arch == "k8":
        prefix = "external/bazel_sysroot_llvm_amd64"
    elif arch == "aarch64":
        prefix = "external/bazel_sysroot_llvm_arm64"
    else:
        fail("Unsupported architecture: " + arch)

    return [
        tool_path(
            name = "ar",
            path = prefix + "/bin/llvm-ar",
        ),
        tool_path(
            name = "cpp",
            path = prefix + "/bin/clang",
        ),
        tool_path(
            name = "gcc",
            path = prefix + "/bin/clang",
        ),
        tool_path(
            name = "gcov",
            path = prefix + "/bin/llvm-cov",
        ),
        tool_path(
            name = "ld",
            path = prefix + "/bin/ld.lld",
        ),
        tool_path(
            name = "nm",
            path = prefix + "/bin/llvm-nm",
        ),
        tool_path(
            name = "objcopy",
            path = prefix + "/bin/llvm-objcopy",
        ),
        tool_path(
            name = "objdump",
            path = prefix + "/bin/llvm-objdump",
        ),
        tool_path(
            name = "strip",
            path = prefix + "/bin/llvm-strip",
        ),
    ]

def _get_features():
    return [
        feature(
            name = "default_compile_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = [
                        "assemble",
                        "preprocess-assemble",
                        "linkstamp-compile",
                        "c-compile",
                        "c++-compile",
                        "c++-header-parsing",
                        "c++-module-compile",
                        "c++-module-codegen",
                        "c++-header-preprocessing",
                        "c++-preprocessing",
                        "lto-backend",
                        "clif-match",
                    ],
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-fPIC",
                                "-Wall",
                                "-Werror",
                                "-Wno-error=unused-command-line-argument",
                            ],
                        ),
                    ],
                ),
            ],
        ),
        feature(
            name = "default_link_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = [
                        "c++-link-executable",
                        "c++-link-dynamic-library",
                        "c++-link-nodeps-dynamic-library",
                    ],
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-fuse-ld=lld",
                                "-Wl,--no-as-needed",
                            ],
                        ),
                    ],
                ),
            ],
        ),
    ]

def _impl(ctx):
    target_cpu = ctx.attr.cpu
    tool_paths = _get_tool_paths(target_cpu)
    features = _get_features()

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = "llvm-toolchain-" + target_cpu,
        host_system_name = "local",
        target_system_name = "local",
        target_cpu = target_cpu,
        target_libc = "local",
        compiler = "clang",
        abi_version = "local",
        abi_libc_version = "local",
        tool_paths = tool_paths,
        features = features,
        cxx_builtin_include_directories = [
            "external/bazel_sysroot_library/include",
        ],
    )

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {
        "cpu": attr.string(mandatory = True),
    },
    provides = [CcToolchainConfigInfo],
)