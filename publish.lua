local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
 
local placeFile = fs.readFile("place.rbxl")
local game = roblox.deserializePlace(placeFile)

print("Publishing to Roblox...")