local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
 
local placeFile = fs.readFile("place.rbxl")
local gameFile = roblox.deserializePlace(placeFile)

local Packages = gameFile.ReplicatedStorage.Packages
local packageModel = roblox.serializeModel({Packages})
fs.writeFile("Inputter.rbxm", packageModel)

