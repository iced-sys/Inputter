local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)

local Types = require(script.Types)
export type Inputter = Types.Inputter
type Signal<T...> = Types.Signal<T...>
type Trigger = Types.Trigger

local Inputter = {}
Inputter.__index = Inputter

Inputter.Trigger = {
	MULTIPLE_PRESS = require(script.Triggers.MULTIPLE_PRESS).new,
	PRESS = require(script.Triggers.PRESS).new,
}

--[=[
	@within Inputter
	@function new
	@param name string -- The name of the inputter. Should be unique
	@param triggers {Trigger} -- The triggers that will be used by the inputter. This should be a table of Trigger objects.
	@return Inputter -- The new inputter object

	Creates a new inputter object, ideally there should be one input for each different player action. I.e. an inputter for punch, another inputter for fly, etc.
	```lua
	local Inputter = require(ReplicatedStorage.Packages.Inputter)

	local punchInput = Inputter.new("PunchInput", {
		Inputter.Trigger.PRESS({
			Input = Enum.KeyCode.ButtonR2,
			IgnoreGameProcessedEvent = true,
		}),
		Inputter.Trigger.MULTIPLE_PRESS({
			Input = Enum.UserInputType.MouseButton1,
			IgnoreGameProcessedEvent = true,
			PressCount = 2,
			TimeFrame = 0.3,
		})
	})
	```
]=]

function Inputter.new(name: string, triggers : {Trigger}) : Inputter
	local self = setmetatable({}, Inputter)
	if not name or typeof(name) ~= "string" then
		error("Input name must be a string")
	end
	if not triggers or typeof(triggers) ~= "table" then
		error("Input binds must be a table")
	end
	--[=[
		@within Inputter
		@prop Name string
		@readonly
		Name of the inputter. This should be unique for each inputter.
	]=]
	self.Name = name
	--[=[
		@within Inputter
		@prop Active boolean
		@readonly
		Whether the inputter is currently active (i.e. is at least one of the inputs bound triggered). Can be used if the action triggered relies on checking the input is still active.
	]=]
	self.Active = false
	--[=[
		@within Inputter
		@prop Enabled boolean
		@readonly
		Whether the inputter is enabled. If this is false, the inputter will not trigger any events.
	]=]
	self.Enabled = true
	--[=[
		@within Inputter
		@prop OnActivated Signal
		@readonly
		Signal that is fired when the inputter is activated. This will be fired when at least one of the inputs bound to the inputter is triggered.
	]=]
	self.OnActivated = Signal.new()
	--[=[
		@within Inputter
		@prop OnDeactivated Signal
		@readonly
		Signal that is fired when the inputter is deactivated. This will be fired when all of the inputs bound to the inputter are deactivated.
	]=]
	self.OnDeactivated = Signal.new()
	--[=[
		@within Inputter
		@prop ActiveTriggers {Trigger}
		@readonly
		The triggers that the inputter is currently listening to.
	]=]
	self.ActiveTriggers = {}
	self._activeConnections = {}
	self:_setup(triggers)
	return self
end

--[=[
	@within Inputter
	@private
	@param triggers {Trigger} -- The triggers that will be used by the inputter.
	Initial inputter setup method, used to begin listening to the initially passed triggers. Should only be called internally.
]=]
function Inputter:_setup(triggers : {Trigger}) 
	for _, Input in pairs(triggers) do
		self:AddInput(Input)
	end
end

--[=[
	@within Inputter
	@param trigger Trigger -- The trigger to add to the inputter.
	Adds a new trigger to an already existing inputter.
]=]
function Inputter:AddInput(trigger : Trigger)
	if not trigger then
		error("Trigger cannot be nil")
	end
	table.insert(self.ActiveTriggers, trigger)
	self._activeConnections[trigger] = {}
	table.insert(self._activeConnections[trigger], trigger.OnActivated:Connect(function(...)
		self:_activate(...)
	end))
	table.insert(self._activeConnections[trigger], trigger.OnDeactivated:Connect(function(...)
		self:_deactivate(...)
	end))
end

--[=[
	@within Inputter
	@tag Work In Progress
	@param Trigger Trigger -- The trigger to remove from the inputter.
	Removes a trigger from an already existing inputter. This method is a work in progress, in the future it may be expanded to allow removal by keybind or other properties.
]=]
function Inputter:RemoveInput(Trigger : Trigger)
	for i,v in pairs(self.ActiveTriggers) do
		if v == Trigger then
			table.remove(self.ActiveTriggers, i)
			break
		end
	end
	if self._activeConnections[Trigger] then
		for _, connection in pairs(self._activeConnections[Trigger]) do
			connection:Disconnect()
		end
		self._activeConnections[Trigger] = nil
	end
end

--[=[
	@within Inputter
	@return {Input} -- All inputs this input is currently connected to.
	Returns all the inputs currently used by the inputter.
]=]
function Inputter:GetAllTriggers()
	local triggers = {}
	for _, trigger in pairs(self.ActiveTriggers) do
		table.insert(triggers, trigger)
	end
	return triggers
end

--[=[
	@within Inputter
	@private
	@param InputObject InputObject -- The input object that triggered the event.
	@param GameProcessedEvent boolean -- Whether the game processed the event or not.
	@param ... any -- Any additional arguments passed to the event.
	Internal method that is called when an input is activated. Should only be called internally.
]=]
function Inputter:_activate(InputObject, GameProcessedEvent, ...)
	if self.Enabled then
		self.Active = true
		self.OnActivated:Fire(InputObject, GameProcessedEvent, ...)
	end
end

--[=[
	@within Inputter
	@private
	@param InputObject InputObject -- The input object that triggered the event.
	@param GameProcessedEvent boolean -- Whether the game processed the event or not.
	@param ... any -- Any additional arguments passed to the event.
	Internal method that is called when an input is deactivated. Should only be called internally.
]=]
function Inputter:_deactivate(InputObject, GameProcessedEvent, ...)
	if self.Active then
		self.Active = false
		if self.Enabled then
			self.OnDeactivated:Fire(InputObject, GameProcessedEvent, ...)
		end
	end
end

--[=[
	@within Inputter
	@return boolean -- Whether the inputter is currently active or not.
	Returns whether the inputter is currently active or not. This will be true if at least one of the inputs bound to the inputter is triggered.
]=]
function Inputter:IsActive()
	return self.Active
end

--[=[
	@within Inputter
	Enables the inputter, meaning it can send activated and deactivated events.
]=]
function Inputter:Enable()
	self.Enabled = true
end

--[=[
	@within Inputter
	Disables the inputter, meaning it will not send activated and deactivated events.
]=]
function Inputter:Disable()
	self.Enabled = false
end

--[=[
	@within Inputter
	Destroys the inputter, meaning it will no longer send activated and deactivated events. This should be called when the inputter is no longer needed.
]=]
function Inputter:Destroy()
	for _, connection in pairs(self._activeConnections) do
		if connection.OnActivated then
			connection.OnActivated:Disconnect()
		end
		if connection.OnDeactivated then
			connection.OnDeactivated:Disconnect()
		end
	end
	self.OnActivated:Destroy()
	self.OnDeactivated:Destroy()
	for i, _ in pairs(self) do
		self[i] = nil
	end
end

return Inputter
