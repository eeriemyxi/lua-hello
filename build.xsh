#!/bin/xonsh

import argparse
from pathlib import Path
from collections import namedtuple

SOURCE = Path(__file__).parent
PROGRAM = "hello"

LUASTATIC = SOURCE / "build/lua/luastatic.lua"
LUASTATIC_VERSION = "0.0.12"

LUA = "lua"
LUA_VERSION = "5.4.7"

CORES = $(nproc).strip()

parser = argparse.ArgumentParser()
parser.add_argument('-C', '--clean', action='store_true', help="Clean build artifacts")
parser.add_argument('-c', '--continue', action='store_true', help="Don't exit after cleaning build artifacts.")
args = parser.parse_args()

Builder = (
    namedtuple('Builder', ['build_name', 'lua_dir', 'cc', 'platform', "suffix", "cflags"]))

BUILD_PROCS = [
    Builder("linux", "lualin", "gcc", "linux", "bin", "-static"),
    Builder("linux-arm32", "lualina32", "arm-linux-gnueabi-gcc", "linux", "bin", "-static"),
    Builder("linux-arm64", "lualina64", "aarch64-linux-gnu-gcc", "linux", "bin", "-static"),
    Builder("linux-android-arm64", "lualinan64", "aarch64-linux-android35-clang", "linux", "bin", "-static"),
    Builder("windows", "luawin", "x86_64-w64-mingw32-gcc", "mingw", "exe", "-static"),
]

if args.clean:
    build = SOURCE/"build"

    if not build.exists():
        print(f"{build.resolve()} doesn't exist.")
        exit(1)
        
    import shutil
    shutil.rmtree(build)

    if not getattr(args, "continue"):
        exit(0)

    
def setup_build_dir(build_name, lua_dir):
    mkdir @(SOURCE)/build/lua/@(builder.lua_dir) -p
    mkdir @(SOURCE)/build/@(builder.build_name)/include -p
    mkdir @(SOURCE)/build/@(builder.build_name)/bin -p


def setup_lua_src(lua_dir):
    if not (SOURCE / "build/lua" / f"lua-{LUA_VERSION}.tar.gz").exists():
        wget https://www.lua.org/ftp/lua-@(LUA_VERSION).tar.gz \
            --directory-prefix @(SOURCE)/build/lua
        
    if (SOURCE / "build/lua" / lua_dir / f"lua-{LUA_VERSION}").exists():
        return
    
    tar xf @(SOURCE)/build/lua/lua-@(LUA_VERSION).tar.gz \
        --directory=@(SOURCE)/build/lua/@(lua_dir)


def setup_luastatic():
    if LUASTATIC.exists():
        return
    
    wget @(f"https://raw.githubusercontent.com/ers35/luastatic/refs/tags/{LUASTATIC_VERSION}/luastatic.lua") \
        --directory-prefix @(LUASTATIC.parent)


def build_lua(build_name, lua_dir, platform, cc):
    lua_path = SOURCE / "build/lua" / lua_dir / f"lua-{LUA_VERSION}"
    make -C @(lua_path) PLAT=@(platform) CC=@(cc) -j@(CORES)
    cp @(lua_path)/src/* @(SOURCE)/build/@(build_name)/include/


def build_program(build_name, cc, suffix, cflags=""):
    $CC=cc @(LUA) @(LUASTATIC) @(SOURCE)/main.lua @(SOURCE)/ext/*.lua \
        @(SOURCE)/build/@(build_name)/include/liblua.a \
        -I@(SOURCE)/build/@(build_name)/include/ \
        -o@(SOURCE)/build/@(build_name)/bin/@(PROGRAM)-@(build_name).@(suffix) \
        @(cflags)

setup_luastatic()

for builder in BUILD_PROCS:
    setup_build_dir(builder.build_name, builder.lua_dir)
    setup_lua_src(builder.lua_dir)
    build_lua(builder.build_name, builder.lua_dir, builder.platform, builder.cc)
    build_program(builder.build_name, builder.cc, builder.suffix, builder.cflags)

rm *.luastatic.c
