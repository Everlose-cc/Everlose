local getSPRDList = filtergc("function", {Name = "getSPRD"}, false)
local fcfList = filtergc("table", {Keys = {"fcf"}}, false)
local lioceRCameraList = filtergc("function", {Name = "lioceRCamera"}, false)

local recoil = 17 -- 0
local spread = 10 -- 0

for _,v in fcfList do
    local active = rawget(v, "fcf"); -- what the fuck does this even stand for?
    local metatable = getrawmetatable(active);
    if (not metatable) then
        continue;
    end;
    local __index = rawget(metatable, "__index");
    if (type(__index) ~= "table") then
        continue;
    end;
    rawset(__index, "Spread", spread);
    rawset(__index, "Recoil", recoil);
end;

for _,v in getSPRDList do
    debug.setupvalue(v, 6, spread) -- 13
end;
for _,v in lioceRCameraList do
    debug.setupvalue(v, 3, recoil) -- 13
end;