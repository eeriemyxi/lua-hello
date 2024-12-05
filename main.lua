argparse = require "ext.argparse"
col      = require "ext.color"

local parser = argparse("script", "An example script.")
parser:option("-n --name", "A name.", "world")
local args = parser:parse()

print(
    col.fg.WHITE .. "Hello " .. 
    col.bold .. col.fg.green .. args.name .. 
    col.reset .. "!"
)
