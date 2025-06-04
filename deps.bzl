# load("@bazel_gazelle//:deps.bzl", "go_repository") # Keep if you use Gazelle for Go deps later

# Load the http_archive rule, which can only be used inside repository rules or module extension implementations
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _sysroots_extension_impl(module_ctx):
    """Implementation for the sysroots module extension.

    Fetches the custom Nix-built sysroot archives.
    """
    # Common library sysroot (headers and common libs)
    http_archive(
        name = "bazel_sysroot_library",
        urls = ["https://github.com/randomizedcoder/bazel_sysroot_library/archive/refs/heads/main.tar.gz"],
        sha256 = "ee9a2366f3594ab1793779fa8e4d986dd50bf54a775d2804a2b2c0f3ad81dd05",
        strip_prefix = "bazel_sysroot_library-main/sysroot",
    )

    # AMD64-specific library sysroot
    http_archive(
        name = "bazel_sysroot_lib_amd64",
        urls = ["https://github.com/randomizedcoder/bazel_sysroot_lib_amd64/archive/refs/heads/main.tar.gz"],
        sha256 = "1720a0cbf08e06d9ff9622c98d4dced08c46badef3411e91bd37ad399df4b770",
        strip_prefix = "bazel_sysroot_lib_amd64-main/sysroot",
    )

    # ARM64-specific library sysroot
    http_archive(
        name = "bazel_sysroot_lib_arm64",
        urls = ["https://github.com/randomizedcoder/bazel_sysroot_lib_arm64/archive/refs/heads/main.tar.gz"],
        sha256 = "3eb494d14b91cbac1c474e88540c361b5ef7bb7d1970cf6fd5669cb4050bf0e5",
        strip_prefix = "bazel_sysroot_lib_arm64-main/sysroot",
    )

    # AMD64 LLVM toolchain sysroot
    http_archive(
        name = "bazel_sysroot_llvm_amd64",
        urls = ["https://github.com/randomizedcoder/bazel_sysroot_llvm_amd64/archive/refs/heads/main.tar.gz"],
        sha256 = "03cfe7f73c392fd3eeed8c7490d194f39007cbb9569a00839a4668c6865dc51a",
        strip_prefix = "bazel_sysroot_llvm_amd64-main/sysroot",
    )

    # ARM64 LLVM toolchain sysroot
    http_archive(
        name = "bazel_sysroot_llvm_arm64",
        urls = ["https://github.com/randomizedcoder/bazel_sysroot_llvm_arm64/archive/refs/heads/main.tar.gz"],
        sha256 = "27819972372a5fa19e682462b36fda9764afe1f107f37bb634ca4c94a7d32c0f",
        strip_prefix = "bazel_sysroot_llvm_arm64-main/sysroot",
    )

sysroots_ext = module_extension(implementation = _sysroots_extension_impl)

def go_dependencies():
    """A function that declares the external Go dependencies."""
    pass
    # Example for Gazelle if you use it:
    # go_repository(
    #     name = "com_github_google_uuid",
    #     importpath = "github.com/google/uuid",
    #     sum = "h1:qJYtXnJRWmX73LS4YV3yJkE4T1M4EUGB9C3HGTqIsf8=",
    #     version = "v1.3.0",
    # )