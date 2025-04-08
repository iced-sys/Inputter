--[[
    Class to represent an input handler that triggers when a given binding is pressed multiple times within a given window.
    Extends the AbstractInput base class.
    Author: Adam Mills
]]
local AbstractInput = require(script.Parent.AbstractInput)
local Types = require(script.Parent.Parent.Types)
local Binding = require(script.Parent.Parent.Binding)

type MULTIPLE_PRESS = Types.MULTIPLE_PRESS

local MULTIPLE_PRESS = setmetatable({}, AbstractInput)
MULTIPLE_PRESS.__index = MULTIPLE_PRESS

-- Constructor for MULTIPLE_PRESS class
function MULTIPLE_PRESS.new(BindingInfo : table, PressCount : number, TimeFrame : number) : MULTIPLE_PRESS
    local self = setmetatable(AbstractInput.new(), MULTIPLE_PRESS)
    self.Binding = Binding.new(BindingInfo)
    self._MaxPresses = PressCount or warn("PressCount not provided, defaulting to 1") and 1
    self._PressWindow = TimeFrame or warn("TimeFrame not provided, defaulting to 0.5") and 0.5
    self._pressCount = 0
    self._firstPressTime = 0
    self._active = false
    self:_setup()
    return self
end

-- Initialise the connections for the object.
-- Shouldn't be called by any user.
function MULTIPLE_PRESS:_setup()
    self._connectionActivated = self.Binding.OnActivated:Connect(function(...)
        if tick() - self._firstPressTime > self._PressWindow then
            self._pressCount = 0
        end
        if self._pressCount == 0 then
            self._firstPressTime = tick()
        end
        self._pressCount += 1
        if self._pressCount == self._MaxPresses then
            self._pressCount = 0
            self._active = true
            self:_activated(...)
        end
    end)
    self._connectionDeactivated = self.Binding.OnDeactivated:Connect(function(...)
        if self._active then
            self._active = false
            self:_deactivated(...)
        end
    end)
end

-- Destroy the input handler
function MULTIPLE_PRESS:Destroy()
    if self._connectionActivated then
        self._connectionActivated:Disconnect()
        self._connectionActivated = nil
    end
    if self._connectionDeactivated then
        self._connectionDeactivated:Disconnect()
        self._connectionDeactivated = nil
    end
    if self.Binding then
        self.Binding:Destroy()
        self.Binding = nil
    end
end

return MULTIPLE_PRESS :: MULTIPLE_PRESS