#
# sysroot/extension.bzl
#

# def _fetch_sysroot_impl(ctx):
#     repo = ctx.path("bazel_sysroot_tarball")

#     ctx.download_and_extract(
#         url = "http://hp4:8080/sysroot.tar.gz",
#         sha256 = "950ec77f10147ef1eaa7d44e3703b0c007bd2bfe02a4764eb785a3db834be913",
#         output = repo,
#     )

#     ctx.file(repo.get_child("WORKSPACE.bazel"), "")
#     ctx.file(repo.get_child("BUILD.bazel"), """
# filegroup(
#     name = "all",
#     srcs = glob(["**"]),
#     visibility = ["//visibility:public"],
# )
# """)

#     ctx.generate_repo(
#         name = "bazel_sysroot_tarball",
#         path = repo,
#     )

# fetch_sysroot = module_extension(
#     implementation = _fetch_sysroot_impl,
# )

# end