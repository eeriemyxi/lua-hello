argparse = require "ext.argparse"
col      = require "ext.lunacolors"

local parser = argparse("script", "An example script.")
parser:option("-n --name", "A name.", "world")
local args = parser:parse()

print(col.brightWhite("Hello ") .. col.bold(col.green(args.name) .. col.reset() .. "!"))
