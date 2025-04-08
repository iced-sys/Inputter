local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)

local Types = require(script.Types)
export type Inputter = Types.Inputter
type Signal = Types.Signal
type Binding = Types.Binding
type Input = Types.Input

local Inputter = {}
Inputter.__index = Inputter

-- Table containing the constructors for the different input types
Inputter.Input = {
    -- Multiple press input handler.
    MULTIPLE_PRESS = require(script.Input.MULTIPLE_PRESS).new,
    -- Press input handler.
    PRESS = require(script.Input.PRESS).new,
}

-- Create a new Inputter with the given name and connected to the given inputs.
function Inputter.new(name: string, inputs : {Input}) : Inputter
    local self = setmetatable({}, Inputter)
    if not name or typeof(name) ~= "string" then
        error("Input name must be a string")
    end
    if not inputs or typeof(inputs) ~= "table" then
        error("Input binds must be a table")
    end
    self.Name = name
    self.Active = false
    self.Enabled = true
    self.OnActivated = Signal.new()
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
