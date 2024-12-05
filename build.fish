#!/bin/fish
set SOURCE $(status dirname)
set PROGRAM "hello"

set LUASTATIC $SOURCE/build/lua/luastatic.lua
set LUASTATIC_VERSION "0.0.12"

set LUA "lua"
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
mkdir $SOURCE/build/{lua,windows,linux} -p
mkdir $SOURCE/build/lua/{luawin,lualin} -p
mkdir $SOURCE/build/{windows,linux}/{include,bin} -p

if not test -f $SOURCE/build/lua/lua-$LUA_VERSION.tar.gz
    wget https://www.lua.org/ftp/lua-$LUA_VERSION.tar.gz --directory-prefix $SOURCE/build/lua
    tar xf $SOURCE/build/lua/lua-$LUA_VERSION.tar.gz --directory=$SOURCE/build/lua/luawin
    tar xf $SOURCE/build/lua/lua-$LUA_VERSION.tar.gz --directory=$SOURCE/build/lua/lualin
end

# Linux
set -l LIN_LUA_PATH $SOURCE/build/lua/lualin/lua-$LUA_VERSION
make -C $LIN_LUA_PATH PLAT=linux -j$CORES
cp $LIN_LUA_PATH/src/* $SOURCE/build/linux/include/

# Windows
set -l WIN_LUA_PATH $SOURCE/build/lua/luawin/lua-$LUA_VERSION
make -C $WIN_LUA_PATH PLAT=mingw CC=x86_64-w64-mingw32-gcc -j$CORES
cp $WIN_LUA_PATH/src/* $SOURCE/build/windows/include/

if not test -f $SOURCE/build/lua/luastatic.lua
    wget "https://raw.githubusercontent.com/ers35/luastatic/refs/tags/$LUASTATIC_VERSION/luastatic.lua" \
        --directory-prefix $SOURCE/build/lua
end

CC=$LINCC $LUA $LUASTATIC $SOURCE/main.lua $SOURCE/ext/*.lua $SOURCE/build/linux/include/liblua.a \
    -I$SOURCE/build/linux/include/ \
    -o$SOURCE/build/linux/bin/$PROGRAM.bin \
    -static

CC=$WINCC $LUA $LUASTATIC $SOURCE/main.lua $SOURCE/ext/*.lua $SOURCE/build/windows/include/liblua.a \
    -I$SOURCE/build/windows/include/ \
    -o$SOURCE/build/windows/bin/$PROGRAM.exe \
    -static

rm *.luastatic.c
