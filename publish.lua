local place = remodel.readPlaceFile("place.rbxl")
local Packages = place.ReplicatedStorage.Packages

print("Writing packages to package file...")
remodel.writeModelFile("Inputter.rbxm", Packages)
print("Inputter model file written.")