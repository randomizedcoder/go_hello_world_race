# go_hello_world_race

![icon](./docs/Screenshot%20From%202025-05-31%2011-08-32.png "icon")

## Introduction and Motivation

The aim of this repository is to demonstrate how to use Bazel to:
- compile a "hello world" c++ program (hello.cc)
- compile a "hello world" Go program (hello.go), with a focus on including Go race tests (hello_test.go)

Given that a key feature of Go is its easy-to-use concurrency, race tests are critical for anyone wanting to use Bazel with Go. However, I've been unable to find a simple example, so this repository aims to fill that gap. ( [Bazel Go tutorial](https://bazel.build/start/go) and [here](https://github.com/bazelbuild/examples/tree/main/go-tutorial/stage3) .)

The goal is to create a repository that will allow any Go user can easily start using with Bazel. The key advantages are that Bazel is fast and "improves" definition of envionmental dependencies. For development teams, simple things like the Go version can be enforced by Bazel.

The key motivation for me to do this is because our CI/CD pipelines are slow, taking ~30 minutes per pull request, and I'd like to get this down to sub-five (<5) minutes. To achieve this, we're going to use Bazel with a remote Buildbarn cluster. Please note that I did measure Nix for this, and it's just not fast enough.  There reason a fast CI/CD pipelines are important, including improving developer velocity, and allowing production code to be updated more quickly in an emergency.

( Please note that I have done extensive [performance benchmarking](https://github.com/randomizedcoder/go_nix_simple?tab=readme-ov-file#summary), including testing various caching methods.  Ultimiately concluded that Nix isn't fast enough.  Bazel is definitely fast. )

I had originally thought this was going to be a lot easier than it turned out to be. I started trying to get Buildbarn working, but then ran into all sorts of challenges, so I've simplified and am just aiming to get local builds working before moving back to remote builds.

Being new to Bazel, I found that it would be great if the Bazel documentation had more detailed descriptions of how the sandbox environment are bootstrapped.  Reading the source code definitely helped to understand what's going on.
https://github.com/bazelbuild/bazel/blob/master/src/main/tools/linux-sandbox-pid1.cc
https://github.com/bazelbuild/bazel/blob/master/src/main/tools/linux-sandbox.cc

## Go Race Tests

The challenge with a Go race test is that it needs to be linked to some precompiled C code. The Go race detector is based on the [ThreadSanitizer (TSan)](https://github.com/google/sanitizers/tree/master/tsan) project from Google.

- The Go-specific integration and runtime code can be found in the Go repository:
  - [Go runtime/race package (Go integration)](https://github.com/golang/go/tree/master/src/runtime/race)
  - [Go race runtime C/C++ code (amd64)](https://github.com/golang/go/tree/master/src/runtime/race/amd64) (for amd64; see also `arm64` for ARM)

The Go distribution ships with these Clang-compiled shared libraries, typically named like `race_linux_amd64.syso` or `race_linux_amd64.a` (static archive), and sometimes as `.so` shared objects for dynamic linking. These are built from the sources above and are included in the Go distribution. You can find them in your Go installation under:

- `$GOROOT/pkg/tool/linux_amd64/` (or similar, depending on your platform)
- Example: `/usr/local/go/pkg/tool/linux_amd64/race_linux_amd64.syso`

For more details, see the [Go source distribution's Makefile](https://github.com/golang/go/blob/master/src/runtime/race/Makefile) and [Go's official documentation on the race detector](https://golang.org/doc/articles/race_detector.html).

To run the race test, a linker like ld.lld needs to link the compiled Go code with the shared libraries.

This introduces major challenges for Go because it means we need to somehow supply the linker. I was unable to find a simple example of how to do this, and after trying now for several weeks unsuccessfully, I now know why. I think the reason a simple example doesn't exist is that most organizations using Bazel are also compiling and linking other C/C++ code, so they already have the C/C++ "toolchains" as Bazel calls them.  Getting the C/C++ toolchains setup correctly has been a lot harder than expected, so to reduce complexity while working this out, I added hello.cc.

( I didn't really understand how the go race tests where linked to c++ code until trying to solve this Bazel nightmare , so this has been valuable learning about golang. )

## NixOS and Bazel Undeclared Dependencies

The other unique thing about this repository is that because I use NixOS, a lot of the assumptions Bazel makes aren't true. [Read about NixOS here](https://edolstra.github.io/pubs/nixos-jfp-final.pdf). NixOS doesn't follow the traditional [Filesystem Hierarchy Standard](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard), so when Bazel tries to use undeclared dependencies, like mktemp and rm, it assumes they will be in the usual places like /bin/, but they are not there on NixOS. In fact, I've been heavily using Nix for over a year and am amazed by its correctness, and now looking at Bazel which claims to be "correct", it's just amazing how untrue this is. Nix and Bazel both use sandbox approaches to achieve "hermetic" builds, but Nix does a much more complete job.

"Hermeticity is very much a matter of degree, unfortunately." - David Sanderson (DWS), on Buildbarn Slack

## Issues Filed
As I've been encountering challenges, I've been filing issues, and have been very impressed by the positive reception from the Bazel community. (Thanks to everyone involved.)

Go-tutorial missing tests and race tests
- https://github.com/bazelbuild/examples/issues/595

Undeclared Dependencies:
- https://github.com/bazel-contrib/rules_go/issues/4343
- There is an active pull request aiming to address this: https://github.com/bazel-contrib/rules_go/pull/4365

Undeclared Dependencies:
- https://github.com/bazelbuild/rules_shell/issues/29

Code Quality Issue:
- https://github.com/bazelbuild/rules_shell/issues/28

![Not Nix correct](./docs/Screenshot%20From%202025-05-31%2010-24-05.png "Not Nix correct")

## Bazel 8 on NixOS
Please note that NixOS users should use the bazelisk package, and not bazel_7. There is no bazel_8 package, but Bazel 8 works perfectly well with bazelisk.

## Bazel Modules
This repository also aims to use the new-ish Bazel modules, rather than "workspaces". I suspect the modules system isn't as widely used, as of May 2025, as workspaces, because there are still a lot of Bazel repositories talking about workspace configurations.

## toolchain_llvm
To allow the linking, I tried to use the most standard modules for Bazel, to try to do things the most Bazel way possible.
I tried to use toolchains_llvm. You need to be extremely careful with the version, and I found that "20.1.2" works the "best" as of May 2025.

```bazel
bazel_dep(name = "toolchains_llvm", version = "1.4.0")  # https://github.com/bazel-contrib/toolchains_llvm/tags
```

**Note:** When using the `toolchains_llvm` module, ensure you load the extension from the correct path. For example, use:
```bazel
llvm = use_extension("@toolchains_llvm//toolchain/extensions:llvm.bzl", "llvm")
```
instead of `@toolchains_llvm//:extensions.bzl`. This is because the actual file is located at `toolchain/extensions/llvm.bzl` in the repo.

However, the default toolchains_llvm compiles Clang to use shared libraries, and to my shock and horror, toolchains_llvm does not supply its own dependencies. ??!! Bazel's toolchains_llvm assumes you will have libraries like libxml2.so.2 available, and I guess for lots of Bazel users they do exist in standard locations, which the Bazel sandbox happily leaks into the "hermetic build". (I haven't filed the issue for this yet, but I should.)

The particularly frustrating thing is that Bazel modules does have a libxml library, however this is only to be used for compiling code again, and NOT easily used at runtime when Clang itself needs to link to the shared libxml2.so.2 library.
```bazel
bazel_dep(name = "libxml2", version = "2.13.5")  # https://registry.bazel.build/modules/libxml2
```

The challenge is that Clang itself needs to link to the shared library libxml2.so.2, and there is no way to pass the standard environment variable LD_LIBRARY_PATH into the sandbox. To hack around this, I created a pull request for rules_go, which does allow you to pass in LD_LIBRARY_PATH, and so I supplied the library in a sysroot I built with Nix. The PR is here: https://github.com/bazel-contrib/rules_go/pull/4361

The PR allows Bazel rules_go users to configure "impure_env" environment variables, which I tried to do in a very generic way for maximum flexibility.
```bazel
go_test(
    name = "hello_test",
    srcs = ["hello_test.go"],
    embed = [":hello_lib"],
    cgo = True,
    cdeps = [":system_deps"],
    data = ["@bazel_sysroot_tarball//:all"],
    impure_env = {
        "LD_LIBRARY_PATH": "external/bazel_sysroot_tarball/lib",   <----- LD_LIBRARY_PATH
    },
    clinkopts = [
        "-L@bazel_sysroot_tarball//:lib",
        "-Wl,-rpath,$$ORIGIN/../../external/bazel_sysroot_tarball/lib",
        "-Wl,--no-as-needed",
        "-lxml2",
    ],
)
```
This works, and so I was finally able to link to allow the Go race test to run.

![rules_go/pull/4361](./docs/Screenshot%20From%202025-05-31%2010-26-03.png "rules_go/pull/4361")

I would still like to see the PR merged, because it will mean that if anyone using rules_go needs to be able to set environment variables in the sandbox, this gives you a way to do it. I don't recommend this in general, but for testing/debugging purposes it's helpful. The documentation included in the PR also makes this clear. Furthermore, I don't see the impure_env as a solution to my problems.

## Alternatives to Solve the toolchain_llvm Undeclared Dependencies

How to solve this challenge "correctly"?

1. Patch rules_go
The improve_env hack was good to prove the challenge with toolchain_llvm, but using shared libraries means that keeping toolchain_llvm in sync with the sysroot could be a maintenance issue.

(But I'd still like to merge the patch :)


2. Use dzbarsky/static-clang
I'm obviously not the first person to run into these types of issues, and so dzbarsky has built a statically compiled version.
https://github.com/dzbarsky/static-clang

Essentially, this repo could be used to replace the toolchain_llvm with the statically compiled versions.

I suspect this would solve the problem, but this repo is built using Docker, and various other non-hermetic techniques that for Nix purists just feels dirty.

Please note that for many people dzbarsky/static-clang is probably a good option, particularly because of the good blogs, and extensive tests.
- https://steven.casagrande.io/posts/2024/sysroot-generation-toolchains-llvm/
- https://steven.casagrande.io/posts/2024/building-macos-llvm-package/
- https://github.com/bazel-contrib/toolchains_llvm/tree/1.0.0/tests

To download and review static-clang, see the releases page: https://github.com/dzbarsky/static-clang/releases

An example URL is:
https://github.com/dzbarsky/static-clang/releases/download/v20.1.1-4/linux_amd64.tar.zst

3. Use Nix to create the toolchain_llvm
Similar to option 2, Nix can be used to create a statically compiled toolchain_llvm. This has the advantage that it will be completely hermetic, and because the Nix packages are regularly maintained and tested, it will be easy to keep the toolchain up to date. e.g., Running "nix flake update" and rebuilding will be the only maintenance required.

This option essentially means leveraging the advantages of Nix and Nix packages.

Therefore, I've chosen to go with option 3.... I guess I'll find out how bad the maintenance burden is.


## How toolchain_llvm works

To create the required sysroot and then configure bazel to have a usable toolchain_llvm we need to understand more about how toolchain_llvm works.

The default toolchain_llvm bazel module essentially has phases:
1. Download and compiles llvm
2. Find all the executable binaries, some libs, and some includes, to make them usable by bazel.

### Phase 1: LLVM Compilation
The module downloads the LLVM source code and compiles it using options to use shared libraries. This makes all the compiled binaries available.

### Phase 2: Toolchain Structure
The toolchain_llvm expects a specific directory structure in the sysroot. The tool definitions come from multiple sources:

1. Core tool requirements are defined in [rules_cc's unix_cc_configure.bzl](https://github.com/bazelbuild/rules_cc/blob/main/cc/private/toolchain/unix_cc_configure.bzl#L68), which specifies the essential tools needed:
   ```python
   [
       "ar",           # Archiver
       "ld",           # Linker
       "llvm-cov",     # Coverage tool
       "llvm-profdata",# Profile data tool
       "cpp",          # C preprocessor
       "gcc",          # C compiler
       "dwp",          # DWARF packager
       "gcov",         # Coverage tool
       "nm",           # Symbol table dumper
       "objcopy",      # Object copier
       "objdump",      # Object dumper
       "strip",        # Symbol stripper
       "c++filt",      # C++ symbol demangler
   ]
   ```

2. Additional tools required by [toolchain_llvm's common.bzl](https://github.com/bazel-contrib/toolchains_llvm/blob/master/toolchain/internal/common.bzl#L35):
   ```python
   [
       "clang-cpp",    # C preprocessor
       "clang-format", # Code formatter
       "clang-tidy",   # Static analyzer
       "clangd",       # Language server
       "ld.lld",       # LLVM linker
       "llvm-ar",      # LLVM archiver
       "llvm-dwp",     # LLVM DWARF packager
       "llvm-profdata",# LLVM profile data tool
       "llvm-cov",     # LLVM coverage tool
       "llvm-nm",      # LLVM symbol table dumper
       "llvm-objcopy", # LLVM object copier
       "llvm-objdump", # LLVM object dumper
       "llvm-strip",   # LLVM symbol stripper
   ]
   ```

   Note: Since version 1.4.0, `toolchain_llvm` requires `clangd`, `clang-format`, and `clang-tidy` to be present in the distribution. This is documented in [issue #481](https://github.com/bazel-contrib/toolchains_llvm/issues/481).

3. Standard tool aliases are defined in [toolchain_llvm's aliases.bzl](https://github.com/bazel-contrib/toolchains_llvm/blob/master/toolchain/aliases.bzl), which maps standard tool names to their LLVM counterparts.

4. Additional compiler tools and their patterns are defined in [rules_cc's cc_toolchain_config.bzl](https://github.com/bazelbuild/rules_cc/blob/master/cc/private/toolchain/cc_toolchain_config.bzl).

The sysroot must provide all these tools in the following structure:

```
sysroot/
├── bin/                    # All executable tools
│   ├── clang              # Main C/C++ compiler (aliased as 'gcc')
│   ├── clang-cpp          # C preprocessor (aliased as 'cpp')
│   ├── clang++            # C++ compiler (aliased as 'g++')
│   ├── clang-format       # Code formatter (required since toolchain_llvm 1.4.0)
│   ├── clang-tidy         # Static analyzer (required since toolchain_llvm 1.4.0)
│   ├── clangd             # Language server (required since toolchain_llvm 1.4.0)
│   ├── ld.lld             # LLVM linker (aliased as 'ld')
│   ├── llvm-ar            # LLVM archiver (aliased as 'ar')
│   ├── llvm-as            # LLVM assembler (aliased as 'as')
│   ├── llvm-nm            # LLVM symbol table dumper (aliased as 'nm')
│   ├── llvm-objcopy       # LLVM object copier (aliased as 'objcopy')
│   ├── llvm-objdump       # LLVM object dumper (aliased as 'objdump')
│   ├── llvm-readelf       # LLVM ELF reader (aliased as 'readelf')
│   ├── llvm-strip         # LLVM symbol stripper (aliased as 'strip')
│   ├── llvm-dwp           # LLVM DWARF packager (aliased as 'dwp')
│   ├── llvm-cov           # LLVM coverage tool
│   ├── llvm-profdata      # LLVM profile data tool
│   └── llvm-c++filt       # LLVM C++ symbol demangler
├── include/               # Header files (required by rules_cc)
│   ├── c++/              # C++ standard library headers
│   └── clang/            # Clang-specific headers
└── lib/                  # Library files (required by rules_cc)
    ├── libc++.a          # LLVM C++ standard library
    ├── libc++abi.a       # LLVM C++ ABI library
    └── libunwind.a       # LLVM unwinder library
```

The `include` and `lib` directories are required by `rules_cc` for:
- Finding system headers
- Linking against standard libraries
- Resolving compiler and linker dependencies

These paths are used by the toolchain configuration to set up the correct include paths and library search paths for the compiler and linker.

### Sysroot Configuration
While the basic structure shows all components in a single sysroot, `toolchain_llvm` actually supports splitting these components across multiple sysroots. This is particularly useful for our architecture where we want to maintain separate sysroots for different purposes.

In `MODULE.bazel`, we can configure the toolchain to use different sysroots for different components:

```bazel
llvm.toolchain(
    name = "llvm_amd64",
    llvm_version = "20.1.2",
    stdlib = {
        "linux-x86_64": "stdc++",
    },
)

llvm.sysroot(
    name = "llvm_amd64",
    targets = ["linux-x86_64"],
    # Main sysroot containing the LLVM tools
    label = "@bazel_sysroot_llvm_amd64//:sysroot",
    # Additional sysroots for headers and libraries
    include_prefix = "@bazel_sysroot_library//:include",
    lib_prefix = "@bazel_sysroot_lib_amd64//:lib",
    # System libraries from both common and architecture-specific sysroots
    system_libs = [
        "@bazel_sysroot_library//:system_deps",
        "@bazel_sysroot_library//:system_deps_static",
        "@bazel_sysroot_lib_amd64//:system_libs",
    ],
)
```

This configuration allows us to:
1. Keep the LLVM tools in `bazel_sysroot_llvm_amd64`
2. Store common headers in `bazel_sysroot_library`
3. Keep architecture-specific libraries in `bazel_sysroot_lib_amd64`

The benefits of this separation include:
- Smaller, more focused sysroots that can be updated independently
- Better caching in Buildbarn as changes to one component don't invalidate others
- Clearer organization of dependencies
- Ability to share common components across architectures

Each sysroot still needs to expose the correct filegroups in its `BUILD.bazel`:

1. `bazel_sysroot_llvm_amd64`:
```bazel
filegroup(
    name = "sysroot",
    srcs = glob(["bin/**"]),
    visibility = ["//visibility:public"],
)
```

2. `bazel_sysroot_library`:
```bazel
filegroup(
    name = "include",
    srcs = glob(["include/**"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "system_deps",
    srcs = glob(["lib/**"]),
    visibility = ["//visibility:public"],
)
```

3. `bazel_sysroot_lib_amd64`:
```bazel
filegroup(
    name = "lib",
    srcs = glob(["lib/**"]),
    visibility = ["//visibility:public"],
)
```

This approach maintains our original goal of separation while still providing all the necessary components to the toolchain.

## Nix Created Sysroots

The design for the sysroots is as follows. Please note that "sysroots" are the Bazel term for a .tar.gz that you can unpack into the sandbox.

One option would be to use Nix to create a single sysroot with all the things required to bring into the sandbox. This option would be okay because, given it would be managed by Nix, it would be easy to control exactly what's in there, and it would be relatively easy to update.

The downside would be that the single sysroot would get large, and whenever it was updated, each runner in the Buildbarn cluster would need to download the new version. Instead, I'm going to try having multiple smaller sysroots, so that any updates will be smaller.

The sysroots will be:
- bazel_sysroot_library
- bazel_sysroot_llvm_amd64
- bazel_sysroot_llvm_arm64
- bazel_sysroot_lib_amd64
- bazel_sysroot_lib_arm64

For each repo, these are pushed into git as files, but then bazel can download the files in a tar.gz, where github provides the ability to generate the .tar.gz on the fly.
```
http_archive(
    name = "bazel_sysroot_tarball_amd64",
    urls = ["https://github.com/randomizedcoder/bazel_sysroot_llvm_amd64/archive/refs/heads/main.tar.gz"],
    strip_prefix = "bazel_sysroot_llvm_amd64-main/sysroot",
    build_file = "//:BUILD.bazel",
)
```

### bazel_sysroot_library

This sysroot will supply the standard /include libraries, which is essentially the .h files.

GitHub repo:
https://github.com/randomizedcoder/bazel_sysroot_library

To see what's included, look at the [default.nix](https://github.com/randomizedcoder/bazel_sysroot_library/blob/main/default.nix), and refer to the README.

### bazel_sysroot_llvm_amd64 && bazel_sysroot_llvm_arm64

These sysroots will contain the statically compiled LLVM package. This is equivalent to dzbarsky/static-clang, except Nix-built.

I also included coreutils in this sysroot because we do need tools like mktemp and rm. These should probably move to their own sysroot in the future.

Please note that I found there is an enormous ~75MB [llvm-exegesis](https://llvm.org/docs/CommandGuide/llvm-exegesis.html) which is some kind of benchmarking tool. Obviously, we don't need this for Go, so I've stripped it out for now. (Possibly if this is ever required in the future, it could go into its own sysroot.)

GitHub repos:
https://github.com/randomizedcoder/bazel_sysroot_llvm_amd64
https://github.com/randomizedcoder/bazel_sysroot_llvm_arm64

To see what's included, look at the [default.nix](https://github.com/randomizedcoder/bazel_sysroot_llvm_amd64/blob/main/default.nix), and also refer to the README.

### bazel_sysroot_lib_amd64 && bazel_sysroot_lib_arm64

This sysroot will have shared libraries, and I'm creating amd64 and arm64 versions. Given that I'm supplying statically built LLVM, I don't really need this sysroot, but to be honest, I had basically created this already from when I was trying setting LD_LIBRARY_PATH. This could be useful to allow linking any other C/C++ programs.

GitHub repo:
https://github.com/randomizedcoder/bazel_sysroot_lib_amd64
https://github.com/randomizedcoder/bazel_sysroot_lib_arm64

To see what's included, look at the [default.nix](https://github.com/randomizedcoder/bazel_sysroot_lib_amd64/blob/main/default.nix), and also refer to the README.

## Next Steps

With the sysroots created, the idea now is to update the Bazel configuration in this repository so the toolchain_llvm uses the bazel_sysroot_llvm_amd64/arm64.

With all this setup, the first step is to try to get hello.cc to compile and run.

In theory, with a basic hello.cc working, this will also mean the Go race test can be linked about the shared c++ code. If I'm really lucky, this will also work with the remote Buildbarn runner, which is the ultimate goal.

Assuming this works, it will mean that this repository demonstrates:
- Go race tests locally
- Go race tests remotely
- Serves as an example for other Go users how to use Bazel
- Sysroots that are hermetic and well managed by Nix

## Sysroot Structure

The project uses five separate sysroots, each with a specific responsibility and its own embedded BUILD file:

### 1. bazel_sysroot_library
- **Purpose**: Common headers and system libraries shared across architectures
- **Directory Structure**:
  ```
  sysroot/
  ├── include/     # Common header files
  ├── lib/         # Common system libraries
  └── BUILD.bazel
  ```
- **BUILD.bazel**:
  - Exposes `include` and `lib` filegroups
  - Defines `system_deps` (shared) and `system_deps_static` (static) cc_library targets

### 2. bazel_sysroot_lib_amd64
- **Purpose**: AMD64-specific shared libraries
- **Directory Structure**:
  ```
  sysroot/
  ├── lib/         # AMD64-specific libraries
  └── BUILD.bazel
  ```
- **BUILD.bazel**:
  - Exposes `lib` filegroup
  - Defines `system_libs` cc_library target for AMD64

### 3. bazel_sysroot_lib_arm64
- **Purpose**: ARM64-specific shared libraries
- **Directory Structure**:
  ```
  sysroot/
  ├── lib/         # ARM64-specific libraries
  └── BUILD.bazel
  ```
- **BUILD.bazel**:
  - Exposes `lib` filegroup
  - Defines `system_libs` cc_library target for ARM64

### 4. bazel_sysroot_llvm_amd64
- **Purpose**: AMD64 LLVM toolchain tools
- **Directory Structure**:
  ```
  sysroot/
  ├── bin/         # LLVM tools and GNU symlinks
  └── BUILD.bazel
  ```
- **BUILD.bazel**:
  - Exposes `bin` filegroup
  - Defines individual tool targets (as, ar, ld, etc.)
  - Includes GNU tool symlinks

### 5. bazel_sysroot_llvm_arm64
- **Purpose**: ARM64 LLVM toolchain tools
- **Directory Structure**:
  ```
  sysroot/
  ├── bin/         # LLVM tools and GNU symlinks
  └── BUILD.bazel
  ```
- **BUILD.bazel**:
  - Exposes `bin` filegroup
  - Defines individual tool targets (as, ar, ld, etc.)
  - Includes GNU tool symlinks

## Bazel Configuration

The `MODULE.bazel` file configures the build system to use these sysroots:

1. **Import Sysroots**:
   ```python
   # Common headers and libraries
   http_archive(name = "bazel_sysroot_library", ...)

   # Architecture-specific libraries
   http_archive(name = "bazel_sysroot_lib_amd64", ...)
   http_archive(name = "bazel_sysroot_lib_arm64", ...)

   # LLVM toolchains
   http_archive(name = "bazel_sysroot_tarball_amd64", ...)
   http_archive(name = "bazel_sysroot_tarball_arm64", ...)
   ```

2. **Configure LLVM Toolchains**:
   ```python
   # AMD64 Toolchain
   llvm.toolchain(
       name = "llvm_toolchain",
       llvm_version = "20.1.2",
   )
   llvm.sysroot(
       name = "llvm_toolchain",
       targets = ["linux-x86_64"],
       label = "@bazel_sysroot_tarball_amd64//:sysroot",
       include_prefix = "@bazel_sysroot_library//:include",
       lib_prefix = "@bazel_sysroot_lib_amd64//:lib",
       system_libs = [
           "@bazel_sysroot_library//:system_deps",
           "@bazel_sysroot_library//:system_deps_static",
       ],
   )

   # ARM64 Toolchain
   llvm.toolchain(
       name = "llvm_toolchain_arm64",
       llvm_version = "20.1.2",
   )
   llvm.sysroot(
       name = "llvm_toolchain_arm64",
       targets = ["linux-aarch64"],
       label = "@bazel_sysroot_tarball_arm64//:sysroot",
       include_prefix = "@bazel_sysroot_library//:include",
       lib_prefix = "@bazel_sysroot_lib_arm64//:lib",
       system_libs = [
           "@bazel_sysroot_library//:system_deps",
           "@bazel_sysroot_library//:system_deps_static",
       ],
   )
   ```

This configuration ensures that:
1. Common headers and libraries are shared across architectures
2. Architecture-specific libraries are used appropriately
3. LLVM tools are available for each architecture
4. The toolchain can find all necessary components in their correct locations

## Building

To build for AMD64:
```bash
bazel build --platforms=@platforms//cpu:x86_64 //...
```

To build for ARM64:
```bash
bazel build --platforms=@platforms//cpu:arm64 //...
```

## Testing

To run tests for AMD64:
```bash
bazel test --platforms=@platforms//cpu:x86_64 //...
```

To run tests for ARM64:
```bash
bazel test --platforms=@platforms//cpu:arm64 //...
```

# Go Hello World Race

This project demonstrates cross-platform Go development using Bazel, with support for both AMD64 and ARM64 architectures.

## Project Structure

```
.
├── BUILD.bazel
├── MODULE.bazel
├── hello.go
├── hello_test.go
└── main.go
```

## Sysroot Structure

The project uses five specialized sysroots, each responsible for a specific part of the build environment:

1. `bazel_sysroot_library` - Common library headers and files
   - Exposes `/include` directory
   - Contains shared headers and library files used by both architectures

2. `bazel_sysroot_lib_amd64` - AMD64-specific libraries
   - Exposes `/lib` directory
   - Contains AMD64-specific shared libraries
   - Depends on `bazel_sysroot_library` for headers

3. `bazel_sysroot_lib_arm64` - ARM64-specific libraries
   - Exposes `/lib` directory
   - Contains ARM64-specific shared libraries
   - Depends on `bazel_sysroot_library` for headers

4. `bazel_sysroot_llvm_amd64` - AMD64-specific LLVM tools
   - Exposes `/bin` directory
   - Contains AMD64-specific LLVM compiler tools
   - Used for building AMD64 binaries

5. `bazel_sysroot_llvm_arm64` - ARM64-specific LLVM tools
   - Exposes `/bin` directory
   - Contains ARM64-specific LLVM compiler tools
   - Used for building ARM64 binaries

Each sysroot includes a `BUILD.sysroot.bazel` file that defines the filegroups and visibility rules for its contents.

## Bazel Configuration

The project uses Bazel's LLVM toolchain configuration to integrate the sysroots. The configuration in `MODULE.bazel` will:

1. Import each sysroot as a Bazel module:
   ```python
   bazel_dep(name = "bazel_sysroot_library", version = "1.0.0")
   bazel_dep(name = "bazel_sysroot_lib_amd64", version = "1.0.0")
   bazel_dep(name = "bazel_sysroot_lib_arm64", version = "1.0.0")
   bazel_dep(name = "bazel_sysroot_llvm_amd64", version = "1.0.0")
   bazel_dep(name = "bazel_sysroot_llvm_arm64", version = "1.0.0")
   ```

2. Configure the LLVM toolchain for each architecture:
   ```python
   llvm_toolchain(
       name = "llvm_amd64",
       sysroot = "@bazel_sysroot_library//:sysroot",
       lib_sysroot = "@bazel_sysroot_lib_amd64//:sysroot",
       toolchain_path = "@bazel_sysroot_llvm_amd64//:sysroot",
       ...
   )

   llvm_toolchain(
       name = "llvm_arm64",
       sysroot = "@bazel_sysroot_library//:sysroot",
       lib_sysroot = "@bazel_sysroot_lib_arm64//:sysroot",
       toolchain_path = "@bazel_sysroot_llvm_arm64//:sysroot",
       ...
   )
   ```

3. Register the toolchains for use:
   ```python
   register_toolchains(
       "//:llvm_amd64_toolchain",
       "//:llvm_arm64_toolchain",
   )
   ```

## Building

To build the project:

```bash
bazel build //...
```

To run tests:

```bash
bazel test //...
```

## Cross-Platform Support

The project supports both AMD64 and ARM64 architectures. The build system automatically selects the appropriate sysroot based on the target platform.

For AMD64:
```bash
bazel build --platforms=//:linux_x86_64 //...
```

For ARM64:
```bash
bazel build --platforms=//:linux_arm64 //...
```

```bash
bazelisk clean --expunge && bazelisk build //:hello --config=local-sysroot --verbose_failures --sandbox_debug
```

## Latest Bazel Modules in Use

In this repo, we are trying to use Bazel modules, and the latest versions of these, which are shown in the following table.

| Module | Version | URL |
|--------|---------|-----|
| rules_cc | 0.1.1 | [bazelbuild/rules_cc](https://github.com/bazelbuild/rules_cc/tags) |
| rules_go | 0.54.1 | [bazel-contrib/rules_go](https://github.com/bazel-contrib/rules_go/tags) |
| toolchains_llvm | 1.4.0 | [bazel-contrib/toolchains_llvm](https://github.com/bazel-contrib/toolchains_llvm/tags) |
| platforms | 1.0.0 | [bazelbuild/platforms](https://github.com/bazelbuild/platforms/tags) |
| gazelle | 0.43.0 | [bazel-contrib/bazel-gazelle](https://github.com/bazel-contrib/bazel-gazelle/tags) |

For toolchain_llvm we are using 20.1.2, because the Bazel module is lagging behind.  In the Nix built sysroot we're actually on 20.1.5, because we track the "unstable" which is kept very up to date.
```
llvm.toolchain(
    name = "llvm_amd64",
    llvm_version = "20.1.2",
)