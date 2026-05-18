local Janitor: Janitor = wax.shared.Janitor

local TableUtils = {}

function TableUtils.AddInstance(tbl: { [any]: any }, Inst: Instance, Key: any)
    local UID = newproxy(false)

	local Connection: RBXScriptConnection = nil
	Connection = Inst:GetPropertyChangedSignal("Parent"):Connect(function()
		if not Inst.Parent then
			tbl[Key] = nil
            Janitor:RemoveNoClean(UID)
			Connection:Disconnect()
		end
	end)
    Janitor:Add(Connection, nil, UID)

	tbl[Key] = Inst
end

return TableUtils