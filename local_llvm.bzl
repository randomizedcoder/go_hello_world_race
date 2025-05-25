"""
Local LLVM toolchain configuration.
"""

def _local_llvm_toolchain_impl(ctx):
    return [
        platform_common.ToolchainInfo(
            name = "local_llvm",
            compiler = ctx.attr.compiler,
            compiler_executable = ctx.attr.compiler_executable,
            sysroot = ctx.attr.sysroot,
        ),
    ]

local_llvm_toolchain = rule(
    implementation = _local_llvm_toolchain_impl,
    attrs = {
        "compiler": attr.string(default = "clang"),
        "compiler_executable": attr.string(default = "/usr/bin/clang"),
        "sysroot": attr.string(default = ""),
    },
)

def register_local_llvm_toolchain():
    native.register_toolchains("//:local_llvm_toolchain")

"""
Custom repository rule for local LLVM toolchain.
"""

def _local_llvm_repo_impl(ctx):
    ctx.download_and_extract(
        url = "http://hp4:8080/toolchains_llvm-v1.4.0.tar.gz",  # Local mirror for faster builds
        # url = "https://github.com/bazel-contrib/toolchains_llvm/releases/download/v1.4.0/toolchains_llvm-v1.4.0.tar.gz",  # Original URL
        sha256 = "fded02569617d24551a0ad09c0750dc53a3097237157b828a245681f0ae739f8",
        stripPrefix = "toolchains_llvm-v1.4.0",
    )

local_llvm_repo = repository_rule(
    implementation = _local_llvm_repo_impl,
    attrs = {},
)