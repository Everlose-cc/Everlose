--!nocheck

-- local physics = game:GetService("PhysicsService")

-- for _, coll in physics:GetRegisteredCollisionGroups() do
--     warn(coll)
-- end

_G.MaxSlopeAngle = 1

oth.hook(getrawmetatable(game).__newindex, function(self, key, value)
    local root: AnyFunction = oth.get_root_callback()

    if self:IsA("Humanoid") and key == "MaxSlopeAngle" then
        value = _G.MaxSlopeAngle
    end

    return root(self, key, value)
end)--!nocheck

-- local physics = game:GetService("PhysicsService")

-- for _, coll in physics:GetRegisteredCollisionGroups() do
--     warn(coll)
-- end

_G.MaxSlopeAngle = 1

oth.hook(getrawmetatable(game).__newindex, function(self, key, value)
    local root: AnyFunction = oth.get_root_callback()

    if self:IsA("Humanoid") and key == "MaxSlopeAngle" then
        value = _G.MaxSlopeAngle
    end

    return root(self, key, value)
end)