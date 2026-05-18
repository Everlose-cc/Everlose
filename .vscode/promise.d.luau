export type PromiseStatus = "Started" | "Resolved" | "Rejected" | "Cancelled"
export type PromiseErrorKind = "ExecutionError" | "AlreadyCancelled" | "NotResolvedInTime" | "TimedOut"

type Connection = {
	Disconnect: (self: Connection) -> (),
	Destroy: (self: Connection) -> (),
	Connected: boolean,
}

type Signal<T...> = {
	Fire: (self: Signal<T...>, T...) -> (),
	FireDeferred: (self: Signal<T...>, T...) -> (),
	Connect: (self: Signal<T...>, fn: (T...) -> ()) -> Connection,
	Once: (self: Signal<T...>, fn: (T...) -> ()) -> Connection,
	DisconnectAll: (self: Signal<T...>) -> (),
	GetConnections: (self: Signal<T...>) -> { Connection },
	Destroy: (self: Signal<T...>) -> (),
	Wait: (self: Signal<T...>) -> T...,
}

export type PromiseErrorStaticAndShared = {
	Kind: {
		ExecutionError: "ExecutionError",
		AlreadyCancelled: "AlreadyCancelled",
		NotResolvedInTime: "NotResolvedInTime",
		TimedOut: "TimedOut",
	},
}
export type PromiseErrorOptions = {
	error: string,
	trace: string?,
	context: string?,
	kind: PromiseErrorKind,
}

export type PromiseError = typeof(setmetatable(
	{} :: PromiseErrorStaticAndShared & {
		error: string,
		trace: string?,
		context: string?,
		kind: PromiseErrorKind,
		parent: PromiseError?,
		createdTick: number,
		createdTrace: string,

		extend: (self: PromiseError, options: PromiseErrorOptions?) -> PromiseError,
		getErrorChain: (self: PromiseError) -> {PromiseError},
	},
	{} :: {__tostring: (self: PromiseError) -> string}
	))
export type PromiseErrorStatic = PromiseErrorStaticAndShared & {
	new: (options: PromiseErrorOptions?, parent: PromiseError?) -> PromiseError,
	is: (anything: any) -> boolean,
	isKind: (anything: any, kind: PromiseErrorKind) -> boolean,
}

export type Promise = {
	andThen: (
		self: Promise,
		successHandler: (...any) -> ...any,
		failureHandler: ((...any) -> ...any)?
	) -> Promise,
	andThenCall: <TArgs...>(self: Promise, callback: (TArgs...) -> ...any, TArgs...) -> any,
	andThenReturn: (self: Promise, ...any) -> Promise,

	await: (self: Promise) -> (boolean, ...any),
	awaitStatus: (self: Promise) -> (Status, ...any),

	cancel: (self: Promise) -> (),
	catch: (self: Promise, failureHandler: (...any) -> ...any) -> Promise,
	expect: (self: Promise) -> ...any,

	finally: (self: Promise, finallyHandler: (status: Status) -> ...any) -> Promise,
	finallyCall: <TArgs...>(self: Promise, callback: (TArgs...) -> ...any, TArgs...) -> Promise,
	finallyReturn: (self: Promise, ...any) -> Promise,

	getStatus: (self: Promise) -> Status,
	now: (self: Promise, rejectionValue: any?) -> Promise,
	tap: (self: Promise, tapHandler: (...any) -> ...any) -> Promise,
	timeout: (self: Promise, seconds: number, rejectionValue: any?) -> Promise,
}
export type TypedPromise<T...> = {
	andThen: (self: Promise, successHandler: (T...) -> ...any, failureHandler: ((...any) -> ...any)?) -> Promise,
	andThenCall: <TArgs...>(self: Promise, callback: (TArgs...) -> ...any, TArgs...) -> Promise,
	andThenReturn: (self: Promise, ...any) -> Promise,

	await: (self: Promise) -> (boolean, T...),
	awaitStatus: (self: Promise) -> (Status, T...),

	cancel: (self: Promise) -> (),
	catch: (self: Promise, failureHandler: (...any) -> ...any) -> Promise,
	expect: (self: Promise) -> T...,

	finally: (self: Promise, finallyHandler: (status: Status) -> ...any) -> Promise,
	finallyCall: <TArgs...>(self: Promise, callback: (TArgs...) -> ...any, TArgs...) -> Promise,
	finallyReturn: (self: Promise, ...any) -> Promise,

	getStatus: (self: Promise) -> Status,
	now: (self: Promise, rejectionValue: any?) -> Promise,
	tap: (self: Promise, tapHandler: (T...) -> ...any) -> Promise,
	timeout: (self: Promise, seconds: number, rejectionValue: any?) -> TypedPromise<T...>,
}

export type PromiseSignal<T...> = {
	Connect: (self: Signal<T...>, callback: (T...) -> ...any) -> PromiseSignalConnection,
}

export type PromiseSignalConnection = {
	Disconnect: (self: PromiseSignalConnection) -> ...any,
	[any]: any,
}
export type PromiseStatic = {
	Error: PromiseErrorStatic,
	Status: {
		Started: "Started",
		Resolved: "Resolved",
		Rejected: "Rejected",
		Cancelled: "Cancelled",
	},

	all: <T>(promises: {TypedPromise<T>}) -> TypedPromise<{T}>,
	allSettled: <T>(promise: {TypedPromise<T>}) -> TypedPromise<{Status}>,
	any: <T>(promise: {TypedPromise<T>}) -> TypedPromise<T>,
	defer: <TReturn...>(
		executor: (
			resolve: (TReturn...) -> (),
			reject: (...any) -> (),
			onCancel: (abortHandler: (() -> ())?) -> boolean
		) -> ()
	) -> TypedPromise<TReturn...>,
	delay: (seconds: number) -> TypedPromise<number>,
	each: <T, TReturn>(
		list: {T | TypedPromise<T>},
		predicate: (value: T, index: number) -> TReturn | TypedPromise<TReturn>
	) -> TypedPromise<{TReturn}>,
	fold: <T, TReturn>(
		list: {T | TypedPromise<T>},
		reducer: (accumulator: TReturn, value: T, index: number) -> TReturn | TypedPromise<TReturn>
	) -> TypedPromise<TReturn>,
	fromEvent: <TReturn...>(
		event: Signal<TReturn...>,
		predicate: ((TReturn...) -> boolean)?
	) -> TypedPromise<TReturn...>,
	is: (object: any) -> boolean,
	new: <TReturn...>(
		executor: (
			resolve: (TReturn...) -> (),
			reject: (...any) -> (),
			onCancel: (abortHandler: (() -> ())?) -> boolean
		) -> ()
	) -> TypedPromise<TReturn...>,
	onUnhandledRejection: (callback: (promise: TypedPromise<any>, ...any) -> ()) -> () -> (),
	promisify: <TArgs..., TReturn...>(callback: (TArgs...) -> TReturn...) -> (TArgs...) -> TypedPromise<TReturn...>,
	race: <T>(promises: {TypedPromise<T>}) -> TypedPromise<T>,
	reject: (...any) -> TypedPromise<...any>,
	resolve: <TReturn...>(TReturn...) -> TypedPromise<TReturn...>,
	retry: <TArgs..., TReturn...>(
		callback: (TArgs...) -> TypedPromise<TReturn...>,
		times: number,
		TArgs...
	) -> TypedPromise<TReturn...>,
	retryWithDelay: <TArgs..., TReturn...>(
		callback: (TArgs...) -> TypedPromise<TReturn...>,
		times: number,
		seconds: number,
		TArgs...
	) -> TypedPromise<TReturn...>,
	some: <T>(promise: {TypedPromise<T>}, count: number) -> TypedPromise<{T}>,
	try: <TArgs..., TReturn...>(callback: (TArgs...) -> TReturn..., TArgs...) -> TypedPromise<TReturn...>,
}