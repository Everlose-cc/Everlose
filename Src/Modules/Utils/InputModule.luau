--!nocheck

local UserInputService: UserInputService = wax.shared.Services.UserInputService

local KeysDown = {}

local InputModule = {}

wax.shared.Janitor:Add(UserInputService.InputBegan:Connect(function(InputObject: InputObject, GameProcessedEvent: boolean)
    if GameProcessedEvent then return end

    if InputObject.UserInputType == Enum.UserInputType.Keyboard then
        KeysDown[InputObject.KeyCode] = true
    end
end))

wax.shared.Janitor:Add(UserInputService.InputEnded:Connect(function(InputObject: InputObject, GameProcessedEvent: boolean)
    if GameProcessedEvent then return end

    if InputObject.UserInputType == Enum.UserInputType.Keyboard then
        KeysDown[InputObject.KeyCode] = nil
    end
end))

function InputModule.IsKeyDown(Key: Enum.KeyCode)
    return KeysDown[Key] and true or false
end

function InputModule.IsMouseButtonDown(MouseButton: Enum.UserInputType)
    return UserInputService:IsMouseButtonPressed(MouseButton)
end

return InputModule