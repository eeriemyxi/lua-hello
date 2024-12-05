# Hello from Lua
This repository aims to be a plain and simple example for building
self-contained Lua script `amd64` binaries for Linux and Windows, and `arm32`
and `arm64` binaries for Linux. No support for MacOS because all the
instructions I found online were very complicated and unreliable.

[`main.lua`](main.lua) contains the source code, [`build.fish`](build.fish) is a
Fish shell script for building the binaries. [`ext/`](`ext/`) contains external
modules that are embedded into the binary. The script assumes you have GCC,
Mingw 64-bit, and GCC ARM compiler toolchain installed. The rest it will figure
out on its own.

Run it from the root of the project's source tree for best results, _but_ it
should work from anywhere.

The binaries will be at `build/{linux,linux-arm32,linux-arm64,windows}/bin/`.

Build artifacts can be cleaned with the build script's `--clean` flag. Run
`--help` flag for more information.
