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
	@echo "  nix_create_sysroot_all    - Create sysroots for all architectures"
	@echo "  nix_create_sysroot_amd64  - Create sysroot for amd64"
	@echo "  nix_create_sysroot_arm64  - Create sysroot for arm64"
	@echo "  nix_create_sysroot_darwin_amd64 - Create sysroot for darwin-amd64"
	@echo "  nix_create_sysroot_darwin_arm64 - Create sysroot for darwin-arm64"
	@echo "  nix_copy_sysroot_tarball  - Copy sysroot to remote"
	@echo "  inspect_tar               - Inspect sysroot tarball contents"

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
.PHONY: nix_create_sysroot_all nix_create_sysroot_amd64 nix_create_sysroot_arm64 nix_create_sysroot_darwin_amd64 nix_create_sysroot_darwin_arm64 nix_copy_sysroot_tarball inspect_tar

# Build all sysroots
nix_create_sysroot_all: nix_create_sysroot_amd64 nix_create_sysroot_arm64

# Build individual sysroots
nix_create_sysroot_amd64:
	nix build .#sysroot-library -o sysroot-library
	nix build .#sysroot-lib-amd64 -o sysroot-lib-amd64
	@echo "Built amd64 sysroot components"

nix_create_sysroot_arm64:
	nix build .#sysroot-library -o sysroot-library
	nix build .#sysroot-lib-arm64 -o sysroot-lib-arm64
	@echo "Built arm64 sysroot components"

# Copy sysroot tarballs to remote
nix_copy_sysroot_tarball:
	scp sysroot-library/sysroot-library.tar.gz hp4:sysroot-library.tar.gz
	scp sysroot-lib-amd64/sysroot-lib.tar.gz hp4:sysroot-lib-amd64.tar.gz
	scp sysroot-lib-arm64/sysroot-lib.tar.gz hp4:sysroot-lib-arm64.tar.gz

# Inspect tarball contents
inspect_tar:
	@echo "Inspecting library sysroot:"
	tar -ztvf ./sysroot-library/sysroot-library.tar.gz
	@echo "\nInspecting amd64 lib sysroot:"
	tar -ztvf ./sysroot-lib-amd64/sysroot-lib.tar.gz
	@echo "\nInspecting arm64 lib sysroot:"
	tar -ztvf ./sysroot-lib-arm64/sysroot-lib.tar.gz

# Rsync targets for each architecture
.PHONY: rsync_all rsync_amd64 rsync_arm64

rsync_all: rsync_amd64 rsync_arm64

rsync_amd64:
	rsync -av ./sysroot-library/sysroot/library/ ../bazel_remote_runner_sysroot/sysroot/library/
	rsync -av ./sysroot-lib-amd64/sysroot/amd64/ ../bazel_remote_runner_sysroot/sysroot/amd64/

rsync_arm64:
	rsync -av ./sysroot-library/sysroot/library/ ../bazel_remote_runner_sysroot/sysroot/library/
	rsync -av ./sysroot-lib-arm64/sysroot/arm64/ ../bazel_remote_runner_sysroot/sysroot/arm64/

#
test_amd64:
	bazelisk test //:hello_test_arm64 --verbose_failures  --config=local-sysroot --sandbox_debug

cycle:
	bazelisk clean --expunge && bazelisk test //:hello_test_amd64 --verbose_failures  --config=local-sysroot --sandbox_debug

# end