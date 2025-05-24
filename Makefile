#
# Makefile
#
.PHONY: \
	gazelle_update \
	gazelle_run \
	test_local \
	test_remote \
	nix_build \
	nix_shell \
	bazelrc_generate \
	nix_copy_bazelrc_generated \
	nix_bazelrc_generated \
	nix_create_sysroot_tarball \
	nix_copy_sysroot_tarball

gazelle_update:
	bazel run //:gazelle -- update-repos -from_file=go.mod

gazelle_run:
	bazel run //:gazelle

test_local:
	bazel test //:hello_test --features=race

test_local_sysroot:
	bazel test //:hello_test --config=local-sysroot --sandbox_debug --verbose_failures

test_remote:
	bazel test //:hello_test --features=race --config=hp4 --sandbox_debug --verbose_failures

nix_build:
	nix build .#default

nix_build_go_with_sysroot:
	nix build .#go-with-sysroot -o go-sdk

nix_shell:
	nix develop

# bazelrc_generated:
# 	@GO_SYSROOT=$$(nix path-info .#go-with-sysroot); \
# 	test -x "$$GO_SYSROOT/bin/cc"; \
# 	echo "build:hp4 --action_env=CC=$$GO_SYSROOT/bin/cc" > .bazelrc.generated; \
# 	echo "build:hp4 --repo_env=CC=$$GO_SYSROOT/bin/cc" >> .bazelrc.generated

nix_bazelrc_generated: nix_create_bazelrc_generated nix_copy_bazelrc_generated

nix_create_bazelrc_generated:
	nix build .#bazelrcGenerated
#nix develop

nix_copy_bazelrc_generated:
	cp result/etc/bazel/bazelrc.generated .bazelrc.generated
	cat .bazelrc.generated

nix_create_sysroot_tarball:
	nix build .#sysrootTarball

nix_copy_sysroot_tarball:
	scp result/sysroot.tar.gz hp4:

# end