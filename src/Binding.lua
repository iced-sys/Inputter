local UserInputService = game:GetService("UserInputService")

local Signal = require(script.Parent.Parent.Signal)
local Types = require(script.Parent.Types)

type Binding = Types.Binding
type BindingInfo = Types.BindingInfo

local Binding = {}
Binding.__index = Binding

local function matchesKeyboardInput(input : any, userInput: InputObject): boolean
    if input.EnumType == Enum.UserInputType then
        return input == userInput.UserInputType
    elseif input.EnumType == Enum.KeyCode then
        return input == userInput.KeyCode
    end
    return false
end

-- Constructor for Binding class
function Binding.new(BindingInfo : BindingInfo): Binding
    local self = setmetatable({}, Binding)
    local input = BindingInfo.Input or error("Input not provided")
    if BindingInfo.IgnoreGameProcessedEvent == nil then
        BindingInfo.IgnoreGameProcessedEvent = true
    end

    self.Input = input
    self.IgnoreGameProcessedEvent = BindingInfo.IgnoreGameProcessedEvent
    self.Pressed = false
    self.OnActivated = Signal.new()
    self.OnDeactivated = Signal.new()
    self._connections = {}
    self:_setup()

    return self
end

-- Function called when the binding is pressed
function Binding:_pressed(...)  
    self.Pressed = true
    self.OnActivated:Fire(...)
end

-- Function called when the binding is released
function Binding:_released(...)
    self.Pressed = false
    self.OnDeactivated:Fire(...)
end

-- Initialise the connections for the object.
-- Shouldn't be called by any user.
function Binding:_setup()
    if typeof(self.Input) == "Instance" and self.Input:IsA("GuiButton") then
        local connection = self.Input.Activated:Connect(function(input, clickCount)
            self:_pressed(input, false, clickCount)
            self:_released(input, false, clickCount)
        end)
        table.insert(self._connections, connection)
    elseif typeof(self.Input) == "EnumItem" then
        local connection1 = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
            if not self.IgnoreGameProcessedEvent then
                if gameProcessedEvent then
                    return
                end
            end
            if matchesKeyboardInput(self.Input, input) then
                self:_pressed(input, gameProcessedEvent)
            end
        end)
        local connection2 = UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
            if not self.IgnoreGameProcessedEvent then
                if gameProcessedEvent then
                    return
                end
            end
            if matchesKeyboardInput(self.Input, input) then
                self:_released(input, gameProcessedEvent)
            end
        end)
        table.insert(self._connections, connection1)
        table.insert(self._connections, connection2)
    else
        error("Unsupported input type: " .. tostring(self.Input))
    end
end

-- Destroy the object
function Binding:Destroy()
    self.OnActivated:Destroy()
    self.OnDeactivated:Destroy()
    for i = #self._connections, 1, -1 do
        local connection = self._connections[i]
        if connection then
            connection:Disconnect()
            table.remove(self._connections, i)
        end
    end
    self._connections = nil
end

return Binding
