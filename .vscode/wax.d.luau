--declare script: LocalScript

export type ClientUtils = {
	GetPositionOnScreen: (Vector: Vector3) -> (Vector2, boolean),
	FindFirstChildOr: (Parent: Instance, ...string) -> Instance?,
	GetMouseRay: () -> (Vector3, Vector3),
	GetPing: () -> number,
	GetFPS: () -> number,
}

declare wax: {
    version: string,
    envname: string,
    shared: {[any]: any, ['ClientUtils']: ClientUtils},

    script: LuaSourceContainer,

    require: (...any) -> ...any,
}