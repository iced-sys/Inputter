--[[
    Input handler that triggers when the input is pressed and released within a given time frame.
    Author: Adam Mills
]]
local AbstractTrigger = require(script.Parent.AbstractTrigger)
local Types = require(script.Parent.Parent.Types)
local Binding = require(script.Parent.Parent.Binding)

type SHORT_PRESS = Types.SHORT_PRESS
type BindingInfo = Types.BindingInfo

--[=[
	@class SHORT_PRESS
	A type of trigger that fires when the given input is pressed and released within a specified time frame.
]=]
local SHORT_PRESS = setmetatable({}, AbstractTrigger)
SHORT_PRESS.__index = SHORT_PRESS

--[=[
	@param BindingInfo BindingInfo -- The binding information for the input. The input index must be only a single input method (i.e. Enum.KeyCode, Enum.UserInputType, or GuiButton).
	@param MaxPressTime number -- The maximum duration (in seconds) the input can be held to still be considered a short press.
	@return SHORT_PRESS -- The new SHORT_PRESS object.
]=]
function SHORT_PRESS.new(BindingInfo: BindingInfo, MaxPressTime: number): SHORT_PRESS
	local self = setmetatable(AbstractTrigger.new(script.Name, BindingInfo, MaxPressTime), SHORT_PRESS)
	self.Binding = Binding.new(BindingInfo)
	self.MaxPressTime = MaxPressTime or error("MaxPressTime must be specified and greater than 0")
	self._pressStartTime = nil
	self._isPressed = false
	self:_setup()
	return self
end

-- Initialise the connections for the object.
function SHORT_PRESS:_setup()
	self._connectionActivated = self.Binding.OnActivated:Connect(function()
		if not self._isPressed then
			-- Record when the press started
			self._pressStartTime = tick()
			self._isPressed = true
		end
	end)

	self._connectionDeactivated = self.Binding.OnDeactivated:Connect(function(...)
		local args = { ... }
		if self._isPressed and self._pressStartTime then
			local pressDuration = tick() - self._pressStartTime

			-- Check if it was a short press
			if pressDuration <= self.MaxPressTime then
				-- It's a short press - activate the trigger
				self:_activated(table.unpack(args))
			end

			-- Reset state
			self._isPressed = false
			self._pressStartTime = nil
		end
	end)
end

-- Destroy the input handler
function SHORT_PRESS:Destroy()
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

	-- Reset state
	self._isPressed = false
	self._pressStartTime = nil
end

return SHORT_PRESS :: SHORT_PRESS
