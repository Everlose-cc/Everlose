export type TracerESPSettings = {
	Enabled: boolean,

	Color: Color3?,
	Thickness: number?,
	Transparency: number?,
	From: ("Top" | "Bottom" | "Center" | "Mouse")?,
}

export type ArrowESPSettings = {
	Enabled: boolean,

	Color: Color3?,
	CenterOffset: number?,
}

export type Box2DESPSettings = {
	Enabled: boolean,

	Color: Color3?,
	Thickness: number?,
	Transparency: number?,
	Filled: boolean?,
}

export type Box3DESPSettings = {
	Enabled: boolean,

	Color: Color3?,
	Thickness: number?,
	Transparency: number?,
}

export type SkeletonESPSettings = {
	Enabled: boolean,

	Color: Color3?,
	Thickness: number?,
	Transparency: number?,
}

export type ESPSettings = {
	Name: string,
	Model: Object,
	TextModel: Object?,

	-- // General Settings // --
	Visible: boolean?,
	Color: Color3?,
	MaxDistance: number?,

	StudsOffset: Vector3?,
	TextSize: number?,

	-- // ESP Type Settings // --
	ESPType: ("Text" | "SphereAdornment" | "CylinderAdornment" | "Adornment" | "SelectionBox" | "Highlight"),
	Thickness: number?,
	Transparency: number?,

	-- // SelectionBox Settings // --
	SurfaceColor: Color3?,

	-- // Highlight Settings // --
	FillColor: Color3?,
	OutlineColor: Color3?,

	FillTransparency: number?,
	OutlineTransparency: number?,

	-- // Components // --
	Tracer: TracerESPSettings?,
	Arrow: ArrowESPSettings?,
	Box2D: Box2DESPSettings?,
	Box3D: Box3DESPSettings?,
	Skeleton: SkeletonESPSettings?,

	-- // Callbacks // --
	OnDestroy: BindableEvent?,
	OnDestroyFunc: (() -> nil)?,

	BeforeUpdate: ((self: ESPSettings) -> nil)?,
	AfterUpdate: ((self: ESPSettings) -> nil)?
}

export type ESPInstance = {
	Index: string,
	Hidden: boolean,
	Deleted: boolean,

	OriginalSettings: ESPSettings,
	CurrentSettings: ESPSettings,

	Connections: { RBXScriptConnection },
	Components: {},

	Show: (self: ESPInstance, Force: boolean?) -> nil,
	Hide: (self: ESPInstance, Force: boolean?) -> nil,
	ToggleVisibility: (self: ESPInstance, Force: boolean?) -> nil,
	SetEveryColor: (self: ESPInstance, Color: Color3, IncludeComponents: boolean) -> nil,
	Destroy: (self: ESPInstance) -> nil
}