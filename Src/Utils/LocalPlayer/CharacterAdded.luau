local LocalPlayer = wax.shared.LocalPlayer
local ConnectionsHandler = wax.shared.ConnectionsHandler

local Library:Library = wax.shared.Library

local Toggles = Library.Toggles
local Options = Library.Options

return function(Character:Model)
    assert(Character == LocalPlayer.Character, 'Expected Local Player\'s Character.')
    wax.shared.LocalCharacter = Character
    local Humanoid = wax.shared.WaitForChildOfClass(Character, 'Humanoid', 5)
    if Humanoid then
        wax.shared.LocalHumanoid = Humanoid
        ConnectionsHandler:GiveSignal(Humanoid:GetPropertyChangedSignal('WalkSpeed'), function()
            local IsWalkSpeedDown: boolean = (Options.WalkSpeedToggleBind:GetState() and Toggles.WalkSpeedToggle.Value) or false
            if IsWalkSpeedDown then
                Humanoid.WalkSpeed = Options.WalkSpeedSlider.Value
            end
        end)
    end
end