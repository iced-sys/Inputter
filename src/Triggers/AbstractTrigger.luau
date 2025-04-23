--[=[
    @class AbstractTrigger
    @ignore
    A base class for triggers. This should not be used directly, but rather as a base class for other input triggers.
]=]
local AbstractTrigger = {}
AbstractTrigger.__index = AbstractTrigger

local Signal = require(script.Parent.Parent.Parent.Signal)
local Types = require(script.Parent.Parent.Types)
type Trigger = Types.Trigger

--[=[
	@return Trigger -- The new AbstractTrigger object.
]=]
function AbstractTrigger.new() : Trigger
    local self = setmetatable({}, AbstractTrigger)
    --[=[
        @within AbstractTrigger
        @private
        @prop OnActivated Signal -- The signal that is fired when the trigger is activated.
    ]=]
    self.OnActivated = Signal.new()
    --[=[
        @within AbstractTrigger
        @private
        @prop OnDeactivated Signal -- The signal that is fired when the trigger is deactivated.
    ]=]
    self.OnDeactivated = Signal.new()
    return self
end

--[=[
    @function _activated
    @private
    @within AbstractTrigger
    Fires the OnActivated signal.
]=]
function AbstractTrigger:_activated(...)
    self.OnActivated:Fire(...)
end

--[=[
    @function _deactivated
    @private
    @within AbstractTrigger
    Fires the OnDeactivated signal.
]=]
function AbstractTrigger:_deactivated(...)
    self.OnDeactivated:Fire(...)
end

return AbstractTrigger
