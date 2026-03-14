local ReallyFarCF = CFrame.new(Vector3.new(1e10, 1e10, 1e10))

local InstanceCache = {}
InstanceCache.__index = InstanceCache

local function Constructor(Inst: Instance, PreCreatedInstancesQuantity: number, InstanceParentFolder: Folder)
	local self = setmetatable({}, InstanceCache)

	function self:Add()
		local Clone = self.Template:Clone()
		if Clone:IsA("PVInstance") then
			Clone:PivotTo(ReallyFarCF)
		end
		Clone.Parent = self.InstanceParentFolder
		table.insert(self.Instances, Clone)
		table.insert(self.AllInstances, Clone)

		return Clone
	end

	function self:ReturnInstance(Inst: Instance)
		local findResult = table.find(self.InUse, Inst)
		if findResult then
			table.remove(self.InUse, findResult)
			if Inst:IsA("PVInstance") then
				Inst:PivotTo(ReallyFarCF)
			end
			Inst.Parent = self.InstanceParentFolder
			table.insert(self.Instances, Inst)
		end
	end

	function self:GetInstance(): Instance?
		local Inst = table.remove(self.Instances)
		if Inst then
			table.insert(self.InUse, Inst)
			return Inst
		else
			local New = self:Add()
			table.remove(self.Instances, table.find(self.Instances, New))
			table.insert(self.InUse, New)
			return New
		end
	end

	function self:Destroy()
		for _, Inst in self.AllInstances do
			Inst:Destroy()
		end

		table.clear(self.Instances)
		table.clear(self.AllInstances)
		table.clear(self.InUse)

		self.Instances = nil
		self.AllInstances = nil
		self.InUse = nil

		table.clear(self)
		setmetatable(self, nil)
	end

	self.PreCreatedInstancesQuantity = (PreCreatedInstancesQuantity or 100)
	self.InstanceParentFolder = (InstanceParentFolder or workspace)
	self.Instances = table.create(PreCreatedInstancesQuantity, nil)
	self.AllInstances = table.create(PreCreatedInstancesQuantity, nil)
	self.InUse = {}
	self.Template = Inst

	for i = 1, self.PreCreatedInstancesQuantity do
		self:Add()
	end

	return self
end

return Constructor
