--[[
    A form of input handler that triggers when the input is held for a specified duration.
    Author: Adam Mills
]]
local AbstractTrigger = require(script.Parent.AbstractTrigger)
local Types = require(script.Parent.Parent.Types)
local Binding = require(script.Parent.Parent.Binding)

type HOLD = Types.HOLD
type BindingInfo = Types.BindingInfo

--[=[
	@class HOLD
	A type of trigger that fires when the given input is held for a specified duration.
]=]
local HOLD = setmetatable({}, AbstractTrigger)
HOLD.__index = HOLD

--[=[
	@param BindingInfo BindingInfo -- The binding information for the input. The input index must be only a single input method (i.e. Enum.KeyCode, Enum.UserInputType, or GuiButton).
	@param HoldTime number -- The duration (in seconds) the input must be held before triggering.
	@return HOLD -- The new HOLD object.
]=]
function HOLD.new(BindingInfo: BindingInfo, HoldTime: number): HOLD
	local self = setmetatable(AbstractTrigger.new(script.Name, BindingInfo, HoldTime), HOLD)
	self.Binding = Binding.new(BindingInfo)
	self.HoldTime = HoldTime or 1.0 -- Default to 1 second if not specified
	self._active = false
	self._holdTimer = nil
	self:_setup()
	return self
end

-- Initialise the connections for the object.
function HOLD:_setup()
	local RunService = game:GetService("RunService")

	self._connectionActivated = self.Binding.OnActivated:Connect(function(...)
		local args = { ... }
		if not self._active then
			-- Start the hold timer
			local startTime = tick()
			self._holdTimer = RunService.Heartbeat:Connect(function()
				if tick() - startTime >= self.HoldTime then
					-- Hold time reached, activate
					self._active = true
					self:_activated(table.unpack(args))
					if self._holdTimer then
						self._holdTimer:Disconnect()
						self._holdTimer = nil
					end
				end
			end)
		end
	end)

	self._connectionDeactivated = self.Binding.OnDeactivated:Connect(function(...)
		local args = { ... }
		-- Input released before hold time - cancel the timer
		if self._holdTimer then
			self._holdTimer:Disconnect()
			self._holdTimer = nil
		end

		-- If we were active, deactivate
		if self._active then
			self._active = false
			self:_deactivated(table.unpack(args))
		end
	end)
end

-- Destroy the input handler
function HOLD:Destroy()
	-- Clean up the hold timer
	if self._holdTimer then
		self._holdTimer:Disconnect()
		self._holdTimer = nil
	end

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

return HOLD :: HOLD
