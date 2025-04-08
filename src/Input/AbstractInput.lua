--[[
    AbstractInput is a base class for representing an input type.
    Very basic, mainly just provides a common interface for the different concrete input types.
    Author: Adam Mills
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AbstractInput = {}
AbstractInput.__index = AbstractInput

local Signal = require(script.Parent.Parent.Parent.Signal)
local Types = require(script.Parent.Parent.Types)

function AbstractInput.new()
    local self = setmetatable({}, AbstractInput)
    self.OnActivated = Signal.new()
    self.OnDeactivated = Signal.new()
    return self
end

function AbstractInput:_activated(...)
    self.OnActivated:Fire(...)
end

function AbstractInput:_deactivated(...)
    self.OnDeactivated:Fire(...)
end

return AbstractInput
