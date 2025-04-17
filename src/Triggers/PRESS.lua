--[[
    Most basic form of input handler. Triggers when the input is pressed.
    Author: Adam Mills
]]
local AbstractTrigger = require(script.Parent.AbstractTrigger)
local Types = require(script.Parent.Parent.Types)
local Binding = require(script.Parent.Parent.Binding)

type PRESS = Types.PRESS

--[=[
	@class PRESS
	A type of trigger that fires when the given input is pressed.
]=]
local PRESS = setmetatable({}, AbstractTrigger)
PRESS.__index = PRESS

--[=[
	@param BindingInfo BindingInfo -- The binding information for the input. The input index must be only a single input method (i.e. Enum.KeyCode, Enum.UserInputType, or GuiButton).
	@return Input -- The new PRESS object.
]=]
function PRESS.new(BindingInfo : table) : PRESS
    local self = setmetatable(AbstractTrigger.new(), PRESS)
    self.Binding = Binding.new(BindingInfo)
    self._active = false
    self:_setup()
    return self
end

-- Initialise the connections for the object.
function PRESS:_setup()
    self._connectionActivated = self.Binding.OnActivated:Connect(function(...)
        if not self._active then
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
function PRESS:Destroy()
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

return PRESS :: PRESS