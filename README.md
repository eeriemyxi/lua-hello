# Hello from Lua
This repository aims to be a plain and simple example for building
self-contained Lua script AMD64 binaries for Linux and Windows. Also ARM32
and ARM64 binaries for Linux. ARM64 Linux builds for Android
(e.g., Termux) is also supported. 

[`main.lua`](main.lua) contains the source code, [`build.fish`](build.fish) is a
Fish shell script for building the binaries. [`ext/`](`ext/`) contains external
modules that are embedded into the binary. The script assumes you have GCC,
Mingw 64-bit, GCC ARM, and Android NDK compiler toolchain installed. The rest it will figure
out on its own.

> [!NOTE]
> For Android NDK you should consider adding
> `$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin` to your `$PATH`.

> [!NOTE]
> No support for MacOS because all the instructions I found online
> were very complicated and unreliable.

Run it from the root of the project's source tree for best results, _but_ it
should work from anywhere.

The binaries will be at `build/{linux,linux-arm32,linux-arm64,linux-android-arm64,windows}/bin/`.

Build artifacts can be cleaned with the build script's `--clean` flag. Run
`--help` flag for more information.

See [Releases](https://github.com/eeriemyxi/lua-hello/releases/latest) 
for outputs from automated CI at 
[`.github/workflows/release-binaries.yml`](.github/workflows/release-binaries.yml).
