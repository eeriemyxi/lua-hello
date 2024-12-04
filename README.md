# Hello from Lua
This repository aims to be a plain and simple example for building
self-contained amd64 binaries of lua scripts for Linux and Windows. No support
for MacOS because all the instructions I found online were very complicated and
unreliable.

`/main.lua` contains the source code, `build.fish` is a Fish shell script for building the binaries. The script assumes you have GCC and Mingw 64-bit compiler toolchain installed. The rest it will figure out on its own.
