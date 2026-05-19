for _, v in game:GetService("ReplicatedStorage").Storage.GUIs.LockpickGUI.MF.LP_Frame.Frames:GetChildren() do
    if v:IsA("Frame") then
        v.Bar.PosV.Value = 0
    end
end