#
# Makefile
#

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo ""
	@echo "Bazel targets:"
	@echo "  bazel-clean        - Clean Bazel cache and sync"
	@echo "  bazel-expunge      - Remove all Bazel cache"
	@echo "  bazel-sync         - Sync Bazel dependencies"
	@echo ""
	@echo "Gazelle targets:"
	@echo "  gazelle_update     - Update Go dependencies from go.mod"
	@echo "  gazelle_run        - Run Gazelle to update BUILD files"
	@echo ""
	@echo "Test targets:"
	@echo "  test_local         - Run tests locally with race detection"
	@echo "  test_local_sysroot - Run tests with local sysroot"
	@echo "  test_remote        - Run tests on remote build farm"
	@echo ""
	@echo "Nix build targets:"
	@echo "  nix_build          - Build default package"
	@echo "  nix_build_go_with_sysroot - Build Go with sysroot"
	@echo "  nix_shell          - Enter development shell"
	@echo ""
	@echo "Bazelrc generation targets:"
	@echo "  nix_bazelrc_generated     - Generate and copy bazelrc"
	@echo "  nix_create_bazelrc_generated - Generate bazelrc"
	@echo "  nix_copy_bazelrc_generated   - Copy generated bazelrc"
	@echo ""
	@echo "Sysroot targets:"
	@echo "  nix_create_sysroot     - Create sysroot"
	@echo "  nix_copy_sysroot_tarball - Copy sysroot to remote"
	@echo "  inspect_tar            - Inspect sysroot tarball contents"

# Bazel targets
.PHONY: bazel-clean bazel-expunge bazel-sync
bazel-clean: bazel-expunge bazel-sync
bazel-expunge:
	bazelisk clean --expunge
bazel-sync:
	bazel sync

# Gazelle targets
.PHONY: gazelle_update gazelle_run
gazelle_update:
	bazel run //:gazelle -- update-repos -from_file=go.mod
gazelle_run:
	bazel run //:gazelle

# Test targets
.PHONY: test_local test_local_sysroot test_remote
test_local:
	bazelisk test //:hello_test --features=race --sandbox_debug --verbose_failures
test_local_sysroot:
	bazelisk test //:hello_test --config=local-sysroot --sandbox_debug --verbose_failures
test_remote:
	bazelisk test //:hello_test --features=race --config=hp4 --sandbox_debug --verbose_failures

# Nix build targets
.PHONY: nix_build nix_build_go_with_sysroot nix_shell
nix_build:
	nix build .#default
nix_build_go_with_sysroot:
	nix build .#go-with-sysroot -o go-sdk
nix_shell:
	nix develop

# Bazelrc generation targets
.PHONY: nix_bazelrc_generated nix_create_bazelrc_generated nix_copy_bazelrc_generated
nix_bazelrc_generated: nix_create_bazelrc_generated nix_copy_bazelrc_generated
nix_create_bazelrc_generated:
	nix build .#bazelrcGenerated
nix_copy_bazelrc_generated:
	cp result/etc/bazel/bazelrc.generated .bazelrc.generated
	cat .bazelrc.generated

# Sysroot targets
.PHONY: nix_create_sysroot nix_copy_sysroot_tarball inspect_tar
nix_create_sysroot:
	nix build .#sysroot
nix_copy_sysroot_tarball:
	scp result/sysroot.tar.gz hp4:
inspect_tar:
	tar -ztvf ./result/sysroot.tar.gz


rsync:
	rsync -av ./result/sysroot/ ../bazel_remote_runner_sysroot/sysroot/


# end