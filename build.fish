#!/bin/fish
set SOURCE $(status dirname)
set PROGRAM "hello"

set LUASTATIC $SOURCE/build/lua/luastatic.lua
set LUASTATIC_VERSION "0.0.12"

set LUA "lua"
set LUA_VERSION "5.4.7"

set CORES $(nproc)
set LINCC "gcc"
set LINA32CC "arm-linux-gnueabi-gcc"
set LINA64CC "aarch64-linux-gnu-gcc"
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
mkdir $SOURCE/build/{lua,windows,linux,linux-arm32,linux-arm64} -p
mkdir $SOURCE/build/lua/{luawin,lualin,lualina32,lualina64} -p
mkdir $SOURCE/build/{windows,linux,linux-arm32,linux-arm64}/{include,bin} -p

if not test -f $SOURCE/build/lua/lua-$LUA_VERSION.tar.gz
    wget https://www.lua.org/ftp/lua-$LUA_VERSION.tar.gz --directory-prefix $SOURCE/build/lua
    tar xf $SOURCE/build/lua/lua-$LUA_VERSION.tar.gz --directory=$SOURCE/build/lua/luawin
    tar xf $SOURCE/build/lua/lua-$LUA_VERSION.tar.gz --directory=$SOURCE/build/lua/lualin
    tar xf $SOURCE/build/lua/lua-$LUA_VERSION.tar.gz --directory=$SOURCE/build/lua/lualina32
    tar xf $SOURCE/build/lua/lua-$LUA_VERSION.tar.gz --directory=$SOURCE/build/lua/lualina64
end

# Linux
set -l LIN_LUA_PATH $SOURCE/build/lua/lualin/lua-$LUA_VERSION
make -C $LIN_LUA_PATH PLAT=linux CC=$LINCC -j$CORES
cp $LIN_LUA_PATH/src/* $SOURCE/build/linux/include/

# Linux ARM32
set -l LIN_LUA_PATH $SOURCE/build/lua/lualina32/lua-$LUA_VERSION
make -C $LIN_LUA_PATH PLAT=linux CC=$LINA32CC -j$CORES
cp $LIN_LUA_PATH/src/* $SOURCE/build/linux-arm32/include/

# Linux ARM64
set -l LIN_LUA_PATH $SOURCE/build/lua/lualina64/lua-$LUA_VERSION
make -C $LIN_LUA_PATH PLAT=linux CC=$LINA64CC -j$CORES
cp $LIN_LUA_PATH/src/* $SOURCE/build/linux-arm64/include/

# Windows
set -l WIN_LUA_PATH $SOURCE/build/lua/luawin/lua-$LUA_VERSION
make -C $WIN_LUA_PATH PLAT=mingw CC=$WINCC -j$CORES
cp $WIN_LUA_PATH/src/* $SOURCE/build/windows/include/

if not test -f $SOURCE/build/lua/luastatic.lua
    wget "https://raw.githubusercontent.com/ers35/luastatic/refs/tags/$LUASTATIC_VERSION/luastatic.lua" \
        --directory-prefix $SOURCE/build/lua
end

CC=$LINCC $LUA $LUASTATIC $SOURCE/main.lua $SOURCE/ext/*.lua $SOURCE/build/linux/include/liblua.a \
    -I$SOURCE/build/linux/include/ \
    -o$SOURCE/build/linux/bin/$PROGRAM-linux-amd64.bin \
    -static

CC=$LINA32CC $LUA $LUASTATIC $SOURCE/main.lua $SOURCE/ext/*.lua $SOURCE/build/linux-arm32/include/liblua.a \
    -I$SOURCE/build/linux-arm32/include/ \
    -o$SOURCE/build/linux-arm32/bin/$PROGRAM-linux-arm32.bin \
    -static \
    -march=armv7-a

CC=$LINA64CC $LUA $LUASTATIC $SOURCE/main.lua $SOURCE/ext/*.lua $SOURCE/build/linux-arm64/include/liblua.a \
    -I$SOURCE/build/linux-arm64/include/ \
    -o$SOURCE/build/linux-arm64/bin/$PROGRAM-linux-arm64.bin \
    -static \

CC=$WINCC $LUA $LUASTATIC $SOURCE/main.lua $SOURCE/ext/*.lua $SOURCE/build/windows/include/liblua.a \
    -I$SOURCE/build/windows/include/ \
    -o$SOURCE/build/windows/bin/$PROGRAM-windows-amd64.exe \
    -static

rm *.luastatic.c
