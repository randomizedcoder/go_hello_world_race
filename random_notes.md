
## Random Notes Below This Point

Going to try 8.2.1rc1:
```
Release 8.2.1rc1 (2025-04-15)

Bazel 8.2.1 is a patch LTS release. It is fully backward compatible with Bazel 8.0 and contains selected changes by the Bazel community and Google engineers.
```
https://github.com/bazelbuild/bazel/releases/tag/8.2.1rc1

```
[das@t:~/Downloads/go_hello_world_race]$ nix-shell -p bazelisk
these 7 paths will be fetched (2.70 MiB download, 15.96 MiB unpacked):
  /nix/store/9ajjzpf3m5v04cdfgnrj9jw24p2wc4x2-bazelisk-1.22.1
  /nix/store/19djhxh07c8ya6n96ylidaxgi35p8asx-file-5.45
  /nix/store/h42gyp46whkbfsl4c6ayn06db4jc3l8f-gnu-config-2024-01-01
  /nix/store/gvc67j3hwsyz6bd2g9gfr80l1r6n3khm-gnumake-4.4.1
  /nix/store/q3hmrfgjkba7vqyrvr1nlsaiymy1ma5w-patchelf-0.15.0
  /nix/store/8rb50qg3macvs6y7i0fll37nsw2sifyc-stdenv-linux
  /nix/store/hi361xvwkvh3nrqgr6bzrnr39rw2g6yp-update-autotools-gnu-config-scripts-hook
copying path '/nix/store/9ajjzpf3m5v04cdfgnrj9jw24p2wc4x2-bazelisk-1.22.1' from 'https://cache.nixos.org'...
copying path '/nix/store/h42gyp46whkbfsl4c6ayn06db4jc3l8f-gnu-config-2024-01-01' from 'https://cache.nixos.org'...
copying path '/nix/store/19djhxh07c8ya6n96ylidaxgi35p8asx-file-5.45' from 'https://cache.nixos.org'...
copying path '/nix/store/gvc67j3hwsyz6bd2g9gfr80l1r6n3khm-gnumake-4.4.1' from 'https://cache.nixos.org'...
copying path '/nix/store/q3hmrfgjkba7vqyrvr1nlsaiymy1ma5w-patchelf-0.15.0' from 'https://cache.nixos.org'...
copying path '/nix/store/hi361xvwkvh3nrqgr6bzrnr39rw2g6yp-update-autotools-gnu-config-scripts-hook' from 'https://cache.nixos.org'...
copying path '/nix/store/8rb50qg3macvs6y7i0fll37nsw2sifyc-stdenv-linux' from 'https://cache.nixos.org'...

[nix-shell:~/Downloads/go_hello_world_race]$ bazelisk build --config=local-sysroot //:hello
2025/05/21 07:49:42 Downloading https://releases.bazel.build/8.2.1/rc1/bazel-8.2.1rc1-linux-x86_64...
Downloading: 60 MB out of 60 MB (100%)
Extracting Bazel installation...
Starting local Bazel server (8.2.1rc1) and connecting to it...
ERROR: Error computing the main repository mapping: error loading package 'external': Both --enable_bzlmod and --enable_workspace are disabled, but one of them must be enabled to fetch external dependencies.
Computing main repo mapping:

[nix-shell:~/Downloads/go_hello_world_race]$
```

Sandbox code
https://github.com/bazelbuild/bazel/blob/master/src/main/tools/linux-sandbox-pid1.cc

https://github.com/bazelbuild/bazel/blob/master/src/main/tools/linux-sandbox.cc

sysroot blog
https://steven.casagrande.io/posts/2024/sysroot-generation-toolchains-llvm/


Another nice blog
https://ltekieli.github.io/cross-compiling-with-bazel/


https://fzakaria.com/2025/02/26/nix-pragmatism-nix-ld-and-envfs


```
[das@t:~/Downloads/go_hello_world_race]$ find /home/das/.cache/bazel/_bazel_das/ -name 'libxml2.so.2'
find: ‘/home/das/.cache/bazel/_bazel_das/0cd5ed571ab210acf3127e673613e371/sandbox/inaccessibleHelperDir’: Permission denied
/home/das/.cache/bazel/_bazel_das/2069c7e7bbea1cec17d73a6b1498e560/external/+_repo_rules+bazel_sysroot_tarball/lib/libxml2.so.2
/home/das/.cache/bazel/_bazel_das/2069c7e7bbea1cec17d73a6b1498e560/execroot/_main/bazel-out/k8-fastbuild/bin/hello_test_/hello_test.runfiles/_main/_solib_k8/_U_S_S_Csystem_Udeps___Uexternal_S+_Urepo_Urules+bazel_Usysroot_Utarball_Slib/libxml2.so.2
/home/das/.cache/bazel/_bazel_das/2069c7e7bbea1cec17d73a6b1498e560/execroot/_main/bazel-out/k8-fastbuild/bin/hello_test_/hello_test.runfiles/+_repo_rules+bazel_sysroot_tarball/lib/libxml2.so.2
find: ‘/home/das/.cache/bazel/_bazel_das/2069c7e7bbea1cec17d73a6b1498e560/sandbox/inaccessibleHelperDir’: Permission denied
/home/das/.cache/bazel/_bazel_das/2069c7e7bbea1cec17d73a6b1498e560/sandbox/linux-sandbox/7/execroot/_main/external/+_repo_rules+bazel_sysroot_tarball/lib/libxml2.so.2
/home/das/.cache/bazel/_bazel_das/2069c7e7bbea1cec17d73a6b1498e560/sandbox/linux-sandbox/10/execroot/_main/external/+_repo_rules+bazel_sysroot_tarball/lib/libxml2.so.2
/home/das/.cache/bazel/_bazel_das/2069c7e7bbea1cec17d73a6b1498e560/sandbox/linux-sandbox/3/execroot/_main/external/+_repo_rules+bazel_sysroot_tarball/lib/libxml2.so.2
/home/das/.cache/bazel/_bazel_das/2069c7e7bbea1cec17d73a6b1498e560/sandbox/linux-sandbox/9/execroot/_main/external/+_repo_rules+bazel_sysroot_tarball/lib/libxml2.so.2
/home/das/.cache/bazel/_bazel_das/2069c7e7bbea1cec17d73a6b1498e560/sandbox/linux-sandbox/11/execroot/_main/external/+_repo_rules+bazel_sysroot_tarball/lib/libxml2.so.2

[das@t:~/Downloads/go_hello_world_race]$
```

```
[das@t:~/Downloads/go_hello_world_race]$ find /home/das/.cache/bazel/_bazel_das/2069c7e7bbea1cec17d73a6b1498e560/external/toolchains_llvm++llvm+llvm_toolchain_llvm/ > find_llvm_toolchain_llvm

[das@t:~/Downloads/go_hello_world_race]$ ls -la /home/das/.cache/bazel/_bazel_das/2069c7e7bbea1cec17d73a6b1498e560/external/toolchains_llvm++llvm+llvm_toolchain_llvm/bin/ld.lld
lrwxrwxrwx 1 das users 3 May 24 15:17 /home/das/.cache/bazel/_bazel_das/2069c7e7bbea1cec17d73a6b1498e560/external/toolchains_llvm++llvm+llvm_toolchain_llvm/bin/ld.lld -> lld

[das@t:~/Downloads/go_hello_world_race]$ ls -la /home/das/.cache/bazel/_bazel_das/2069c7e7bbea1cec17d73a6b1498e560/external/toolchains_llvm++llvm+llvm_toolchain_llvm/bin/lld
-rwxr-xr-x 1 das users 190332448 Apr  2 01:03 /home/das/.cache/bazel/_bazel_das/2069c7e7bbea1cec17d73a6b1498e560/external/toolchains_llvm++llvm+llvm_toolchain_llvm/bin/lld
```


```
By testing from inside the sandbox, if I can set the LD_LIBRARY_PATH, then ld.lld works, and can link to libxml2.so.2 which I'm providing via the sysroot
LD_LIBRARY_PATH=/home/das/.cache/bazel/_bazel_das/2069c7e7bbea1cec17d73a6b1498e560/external/+_repo_rules+bazel_sysroot_tarball/lib /home/das/.cache/bazel/_bazel_das/2069c7e7bbea1cec17d73a6b1498e560/external/toolchains_llvm++llvm+llvm_toolchain_llvm/bin/lld --version
Results in
LD_LIBRARY_PATH=/home/das/.cache/bazel/_bazel_das/2069c7e7bbea1cec17d73a6b1498e560/external/+_repo_rules+bazel_sysroot_tarball/lib /home/das/.cache/bazel/_bazel_das/2069c7e7bbea1cec17d73a6b1498e560/external/toolchains_llvm++llvm+llvm_toolchain_llvm/bin/lld --version
lld is a generic driver.
Invoke ld.lld (Unix), ld64.lld (macOS), lld-link (Windows), wasm-ld (WebAssembly) instead
However, I have no idea how to get Bazel to set the LD_LIBARY_PATH. e.g. This doesn't work
build:local-sysroot --test_env=LD_LIBRARY_PATH=$$ORIGIN/../../external/+_repo_rules+bazel_sysroot_tarball/lib
```

## dzbarsky/static-clang

While looking for how to use
https://github.com/dzbarsky/static-clang

This is possibly the best example I can find for using dzbarsky/static-clang
https://github.com/malt3/sysroots/blob/main/example/MODULE.bazel#L21

Another example here, although older llvm version:
https://github.com/aspect-build/rules_py/blob/main/WORKSPACE#L65

Multiple bazelbuild example mention dzbarsky/static-clang, but don't actually use it. ? Curious
https://github.com/bazelbuild/examples/blob/main/rust-examples/09-oci-container/MODULE.bazel#L18

This looks pretty interesting.  Anyone using it successfully? Sounds pretty awesome
https://github.com/cerisier/toolchains_llvm_bootstrapped


# Sysroots created by Nix

bazel_sysroot_library
bazel_sysroot_lib_amd64
bazel_sysroot_lib_arm64
bazel_sysroot_llvm_amd64
bazel_sysroot_llvm_arm64

git clone https://github.com/randomizedcoder/bazel_sysroot_library.git
git clone https://github.com/randomizedcoder/bazel_sysroot_lib_amd64.git
git clone https://github.com/randomizedcoder/bazel_sysroot_lib_arm64.git
git clone https://github.com/randomizedcoder/bazel_sysroot_llvm_amd64.git
git clone https://github.com/randomizedcoder/bazel_sysroot_llvm_arm64.git

```
[das@t:~/Downloads]$ ls -la | grep bazel_sysroot_
drwxr-xr-x   4 das  users        4096 May 29 13:39 bazel_sysroot_lib_amd64
drwxr-xr-x   3 das  users        4096 May 29 11:34 bazel_sysroot_lib_arm64
drwxr-xr-x   4 das  users        4096 May 29 11:25 bazel_sysroot_library
drwxr-xr-x   4 das  users        4096 May 29 13:40 bazel_sysroot_llvm_amd64
drwxr-xr-x   4 das  users        4096 May 29 13:57 bazel_sysroot_llvm_arm64
```

toolchains issue
https://github.com/bazelbuild/bazel/issues/7746

clang-tidy issue
https://github.com/bazel-contrib/toolchains_llvm/issues/481