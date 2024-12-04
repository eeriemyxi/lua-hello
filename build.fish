#!/bin/fish
set SOURCE $(pwd)
set PROGRAM "main"

set LUASTATIC build/lua/luastatic.lua
set LUASTATIC_VERSION "0.0.12"

set LUA_VERSION "5.4.7"

set CORES $(nproc)
set LINCC "gcc"
set WINCC "x86_64-w64-mingw32-gcc"

argparse 'h/help' 'c/clean' -- $argv

if set -q _flag_help
    echo "Usage: $(basename (status -f)) [OPTIONS]"
    echo "  -h, --help        Show this help message"
    echo "  -c, --clean       Clean build artifacts"
    exit 0
end

if set -q _flag_clean
    rm -r $SOURCE/build/
    echo "Removed $SOURCE/build/"
    exit 0
end

# Setup
mkdir build/{lua,windows,linux} -p
mkdir build/lua/{luawin,lualin} -p
mkdir build/{windows,linux}/{include,bin} -p

if not test -f build/lua/lua-$LUA_VERSION.tar.gz
    wget https://www.lua.org/ftp/lua-$LUA_VERSION.tar.gz --directory-prefix build/lua
    tar xf build/lua/lua-$LUA_VERSION.tar.gz --directory=build/lua/luawin
    tar xf build/lua/lua-$LUA_VERSION.tar.gz --directory=build/lua/lualin
end

# Linux
cd $SOURCE/build/lua/lualin/lua-$LUA_VERSION
make PLAT=linux -j$CORES
cp src/* $SOURCE/build/linux/include/

# Windows
cd $SOURCE/build/lua/luawin/lua-$LUA_VERSION
make PLAT=mingw CC=x86_64-w64-mingw32-gcc -j$CORES
cp src/* $SOURCE/build/windows/include/

cd $SOURCE

if not test -f build/lua/luastatic.lua
    wget "https://raw.githubusercontent.com/ers35/luastatic/refs/tags/$LUASTATIC_VERSION/luastatic.lua" \
        --directory-prefix build/lua
end

CC=$LINCC lua $LUASTATIC main.lua build/linux/include/liblua.a \
    -Ibuild/linux/include/ \
    -o build/linux/bin/$PROGRAM.bin

CC=$WINCC lua $LUASTATIC main.lua build/windows/include/liblua.a \
    -Ibuild/windows/include/ \
    -o build/windows/bin/$PROGRAM.exe

rm $PROGRAM.luastatic.c
