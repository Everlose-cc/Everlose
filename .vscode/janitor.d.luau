type BooleanOrString = boolean | string


export type Janitor = typeof(setmetatable(
	{} :: {
		CurrentlyCleaning: boolean,
		SuppressInstanceReDestroy: boolean,

		Add: <T>(self: Janitor, object: T, methodName: BooleanOrString?, index: any?) -> T,
		AddObject: <T, A...>(
			self: Janitor,
			constructor: {new: (A...) -> T},
			methodName: BooleanOrString?,
			index: any?,
			A...
		) -> T,
		AddPromise: <T...>(self: Janitor, promiseObject: TypedPromise<T...>) -> TypedPromise<T...>,

		Remove: (self: Janitor, index: any) -> Janitor,
		RemoveNoClean: (self: Janitor, index: any) -> Janitor,

		RemoveList: (self: Janitor, ...any) -> Janitor,
		RemoveListNoClean: (self: Janitor, ...any) -> Janitor,

		Get: (self: Janitor, index: any) -> any?,
		GetAll: (self: Janitor) -> {[any]: any},

		Cleanup: (self: Janitor) -> (),
		Destroy: (self: Janitor) -> (),

		LinkToInstance: (self: Janitor, Object: Instance, allowMultiple: boolean?) -> RBXScriptConnection,
		LinkToInstances: (self: Janitor, ...Instance) -> Janitor,
	},
	{} :: {__call: (self: Janitor) -> ()}
	))
export type JanitorPrivate = typeof(setmetatable(
	{} :: {
		CurrentlyCleaning: boolean,
		SuppressInstanceReDestroy: boolean,

		-- Private
		[any]: BooleanOrString,

		Add: <T>(self: JanitorPrivate, object: T, methodName: BooleanOrString?, index: any?) -> T,
		AddObject: <T, A...>(
			self: JanitorPrivate,
			constructor: {new: (A...) -> T},
			methodName: BooleanOrString?,
			index: any?,
			A...
		) -> T,
		AddPromise: <T...>(self: JanitorPrivate, promiseObject: TypedPromise<T...>) -> TypedPromise<T...>,

		Remove: (self: JanitorPrivate, index: any) -> JanitorPrivate,
		RemoveNoClean: (self: JanitorPrivate, index: any) -> JanitorPrivate,

		RemoveList: (self: JanitorPrivate, ...any) -> JanitorPrivate,
		RemoveListNoClean: (self: JanitorPrivate, ...any) -> JanitorPrivate,

		Get: (self: JanitorPrivate, index: any) -> any?,
		GetAll: (self: JanitorPrivate) -> {[any]: any},

		Cleanup: (self: JanitorPrivate) -> (),
		Destroy: (self: JanitorPrivate) -> (),

		LinkToInstance: (self: JanitorPrivate, object: Instance, allowMultiple: boolean?) -> RBXScriptConnection,
		LinkToInstances: (self: JanitorPrivate, ...Instance) -> JanitorPrivate,
	},
	{} :: {__call: (self: JanitorPrivate) -> ()}
	))
export type JanitorStatic = {
	ClassName: "Janitor",
	CurrentlyCleaning: boolean,
	SuppressInstanceReDestroy: boolean,

	new: () -> Janitor,
	Is: (object: any) -> boolean,
	instanceof: (object: any) -> boolean,
}
export type JanitorPrivateStatic = JanitorStatic & {
	__call: (self: JanitorPrivate) -> (),
	__tostring: (self: JanitorPrivate) -> string,
}