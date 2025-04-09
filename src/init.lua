local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)

local Types = require(script.Types)
export type Inputter = Types.Inputter
type Signal = Types.Signal
type Binding = Types.Binding
type Input = Types.Input


--[=[
	@class Inputter
	The inputter class represents each individual action a player can make. It should be used to abstract away from the different input methods ROBLOX provides.
]=]
local Inputter = {}
Inputter.__index = Inputter

Inputter.Input = {
    MULTIPLE_PRESS = require(script.Input.MULTIPLE_PRESS).new,
    PRESS = require(script.Input.PRESS).new,
}

--[=[
	@param name string -- The name of the inputter. Should be unique
	@param inputs {Input} -- The inputs that will trigger the inputter. This should be a table of Input objects.
	@return Inputter -- The new inputter object

	Creates a new inputter object. This should be used to create a new inputter for each action the player can make.
	```lua
	local Inputter = require(ReplicatedStorage.Packages.Inputter)

	local punchInput = Inputter.new("PunchInput", {
		Inputter.Input.PRESS({
			Input = Enum.UserInputType.MouseButton1
			IgnoreGameProcessedEvent = true,
		}
	)
	```
]=]

function Inputter.new(name: string, inputs : {Input}) : Inputter
    local self = setmetatable({}, Inputter)
    if not name or typeof(name) ~= "string" then
        error("Input name must be a string")
    end
    if not inputs or typeof(inputs) ~= "table" then
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
    self.ActiveInputs = {}
    self._activeConnections = {}
    self:_setup(inputs)
    return self
end

-- Initialise the inputter with the passed inputs
function Inputter:_setup(Inputs : {Input}) 
    for _, Input in pairs(Inputs) do
        self:AddInput(Input)
    end
end

-- Add a new input that triggers the inputter
function Inputter:AddInput(Input : Input)
    if not Input then
        error("Input cannot be nil")
    end
    table.insert(self.ActiveInputs, Input)
    if Input.OnActivated then
        self._activeConnections[Input] = {}
        table.insert(self._activeConnections[Input], Input.OnActivated:Connect(function(...)
            self:_activate(...)
        end))
        table.insert(self._activeConnections[Input], Input.OnDeactivated:Connect(function(...)
            self:_deactivate(...)
        end))
    end
end

function Inputter:RemoveInput(Input : Input)
    for i,v in pairs(self.ActiveInputs) do
        if v == Input then
            table.remove(self.ActiveInputs, i)
            break
        end
    end
    if self._activeConnections[Input] then
        for _, connection in pairs(self._activeConnections[Input]) do
            connection:Disconnect()
        end
        self._activeConnections[Input] = nil
    end
end

function Inputter:GetAllInputs()
    local inputs = {}
    for _, Input in pairs(self.ActiveInputs) do
        table.insert(inputs, Input)
    end
    return inputs
end

function Inputter:_activate(InputObject, GameProcessedEvent, ...)
    if self.Enabled then
        self.Active = true
        self.OnActivated:Fire(InputObject, GameProcessedEvent, ...)
    end
end

function Inputter:_deactivate(InputObject, GameProcessedEvent, ...)
    if self.Active then
        self.Active = false
        if self.Enabled then
            self.OnDeactivated:Fire(InputObject, GameProcessedEvent, ...)
        end
    end
end

function Inputter:IsActive()
    return self.Active
end

function Inputter:Enable()
    self.Enabled = true
end

function Inputter:Disable()
    self.Enabled = false
end

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
    for i,v in pairs(self) do
        self[i] = nil
    end
end

return Inputter
