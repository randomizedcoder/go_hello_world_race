# go_hello_world_race

test bazel build go with a race test

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