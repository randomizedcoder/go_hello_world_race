#
# sysroot/extension.bzl
#

def _fetch_sysroot_impl(ctx):
    extracted_dir = ctx.download_and_extract(
        url = "http://hp4:8080/sysroot.tar.gz",
        sha256 = "950ec77f10147ef1eaa7d44e3703b0c007bd2bfe02a4764eb785a3db834be913",
        #sha256sum ./result/sysroot.tar.gz
    )
    ctx.install(extracted_dir, name = "bazel_sysroot_tarball")

fetch_sysroot = module_extension(
    implementation = _fetch_sysroot_impl,
)

# end