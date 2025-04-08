local Signal = require(script.Parent.Parent.Signal)

export type Signal = Signal.Signal

export type Binding = {
    Input: Enum.KeyCode | Enum.UserInputType | GuiButton,
    OnActivated : Signal,
    OnDeactivated : Signal,
    Pressed: boolean,
    Destroy: (self: Binding) -> (),
    new: (BindingInfo: BindingInfo) -> Binding,
}

export type Input = {
    OnActivated: Signal,
    OnDeactivated: Signal,
}

export type BindingInfo = {
    Input: Enum.KeyCode | Enum.UserInputType | GuiButton,
    IgnoreGameProcessedEvent: boolean,
}
export type MULTIPLE_PRESS = {
    new: (BindingInfo : BindingInfo, PressCount: number, TimeFrame: number) -> Input,
}
export type PRESS = {
    new: (BindingInfo : BindingInfo) -> Input,
}

export type Inputter = {
    Name: string,
    Active: boolean,
    Enabled: boolean,
    ActiveInputs: {Input},
    OnActivated: Signal,
    OnDeactivated: Signal,

    new: (name: string, inputs: {Input}) -> Inputter,
    AddInput: (self: Inputter, input: Input) -> (),
    RemoveInput: (self: Inputter, input: Input) -> (),
    GetAllInputs: (self: Inputter) -> {Input},
    IsActive: (self: Inputter) -> boolean,
    Enable: (self: Inputter) -> (),
    Disable: (self: Inputter) -> (),
    Destroy: (self: Inputter) -> (),
}

return {}