--!nocheck

oth.hook(getrawmetatable(game).__namecall, function(self, ...)
    
    if self and self.Name == "Humanoid" then
        if select(2, ...) == "SetStateEnabled" and select(3, ...) == Enum.HumanoidStateType.Seated then
            return oth.get_root_callback()(self, "SetStateEnabled", false)
        end
    end

    return oth.get_root_callback()(self, ...)
end)