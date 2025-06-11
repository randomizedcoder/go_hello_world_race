# load("@bazel_gazelle//:deps.bzl", "go_repository") # Keep if you use Gazelle for Go deps later

# Load the http_archive rule, which can only be used inside repository rules or module extension implementations
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# --- sysroots_ext: Module extension for fetching custom Nix-built sysroots ---
# This extension is currently NOT USED in MODULE.bazel as llvm.toolchain_package
# is being used to fetch the LLVM sysroot directly.
# If you revert to using this extension, uncomment its usage in MODULE.bazel.

# def _sysroots_extension_impl(module_ctx):
#     """Implementation for the sysroots module extension.
#
#     Fetches the custom Nix-built sysroot archives.
#     """
#     # # Common library sysroot (headers and common libs)
#     # http_archive(
#     #     name = "bazel_sysroot_library",
#     #     urls = ["https://github.com/randomizedcoder/bazel_sysroot_library/archive/refs/heads/main.tar.gz"],
#     #     sha256 = "ee9a2366f3594ab1793779fa8e4d986dd50bf54a775d2804a2b2c0f3ad81dd05",
#     #     strip_prefix = "bazel_sysroot_library-main/sysroot",
#     #     build_file_content = """\
# # package(default_visibility = ["//visibility:public"])
# #
# # filegroup(
# #     name = "include",
# #     srcs = glob(["include/**"]),
# # )
# #
# # # Common system libraries (e.g., shared objects)
# # cc_library(
# #     name = "system_deps",
# #     hdrs = [":include"], # Make headers available with these libs
# #     srcs = glob(["lib/**/*.so", "lib/**/*.so.*"], allow_empty = True),
# #     includes = ["include"], # Add 'include' to the include path for these libs
# #     linkstatic = False,
# # )
# #
# # # Common static system libraries (e.g., .a files)
# # cc_library(
# #     name = "system_deps_static",
# #     hdrs = [":include"],
# #     srcs = glob(["lib/**/*.a"], allow_empty = True), # Adjust if libc++.a etc. are here
# #     includes = ["include"],
# #     linkstatic = True,
# # )""",
#     # )
#
#     # # AMD64-specific library sysroot
#     # http_archive(
#     #     name = "bazel_sysroot_lib_amd64",
#     #     urls = ["https://github.com/randomizedcoder/bazel_sysroot_lib_amd64/archive/refs/heads/main.tar.gz"],
#     #     sha256 = "0a4153a9426f42890f120b49a0c801f13543c11cc6eb94603e2180f4b07d5759",
#     #     strip_prefix = "bazel_sysroot_lib_amd64-main/sysroot",
#     #     build_file_content = """\
# # package(default_visibility = ["//visibility:public"])
# #
# # filegroup(
# #     name = "lib", # Exposes the lib/ directory contents
# #     srcs = glob(["lib/**"]),
# # )
# #
# # cc_library(
# #     name = "system_libs", # Arch-specific system libraries (e.g., libc++.a, libc++abi.a for amd64)
# #     srcs = glob(["lib/**/*.a", "lib/**/*.so", "lib/**/*.so.*"], allow_empty = True),
# # )""",
#     # )
#
#     # AMD64 LLVM toolchain sysroot
#     # print("DEBUG: _sysroots_extension_impl: Attempting to define http_archive for bazel_sysroot_llvm_amd64")
#     # http_archive(
#     #     name = "bazel_sysroot_llvm_amd64",
#     #     urls = ["https://github.com/randomizedcoder/bazel_sysroot_llvm_amd64/archive/refs/heads/main.tar.gz"],
#     #     sha256 = "bcb9792c3eac7f9e1268065792af94d286b2739361bcf28d7f68226f91da2830",
#     #     strip_prefix = "bazel_sysroot_llvm_amd64-main/sysroot", # The archive contains its own BUILD.bazel at this path.
#     # )
#     # print("DEBUG: _sysroots_extension_impl: Finished http_archive definition for bazel_sysroot_llvm_amd64")
#
#     # You would add other http_archive calls here if needed by the extension.
#     pass # Extension must do something or define repositories.
#
# sysroots_ext = module_extension(
#     implementation = _sysroots_extension_impl,
#     tag_classes = {"declare_toolchain_deps": tag.string()},
# )

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