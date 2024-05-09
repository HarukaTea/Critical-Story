--!strict
type rateLimitArg = {
	maxEntrance: number?,
	interval: number?,
}

type logging = {
	store: boolean,
	opt: boolean,
}

export type ServerConf = {
	rateLimit: rateLimitArg?,
	logging: logging?,
}

export type ClientConf = {
	yieldWait: number?,
	logging: logging?,
}

export type Client = {
	Fire: (self: Client, ...any) -> (),
	Invoke: (self: Client, timeout: number, ...any) -> any,
	Connect: (self: Client, callback: (...any) -> ()) -> string,
	Once: (self: Client, callback: (player: Player, ...any) -> ()) -> string,
	Disconnect: (self: Client, key: string) -> (),
	DisconnectAll: (self: Client) -> (),
	Wait: (self: Client) -> number,
	Destroy: (self: Client) -> (),
	logs: (self: Client) -> any,
}

export type Server = {
	Fire: (self: Server, player: Player, ...any) -> (),
	Fires: (self: Server, ...any) -> (),
	Invoke: (self: Server, timeout: number, player: Player, ...any) -> any,
	Connect: (self: Server, callback: (player: Player, ...any) -> ()) -> string,
	Once: (self: Server, callback: (player: Player, ...any) -> ()) -> string,
	Disconnect: (self: Server, key: string) -> (),
	DisconnectAll: (self: Server) -> (),
	Wait: (self: Server) -> number,
	Destroy: (self: Server) -> (),
	logs: (self: Server) -> any,
}

export type Event = {
	Reliable: RemoteEvent,
	Unreliable: UnreliableRemoteEvent,
	Request: RemoteEvent,
}

export type QueueMap = {
	[string]: {
		[any]: any,
	}
}

export type CallbackMap = {
	[string]: (any),
}

export type StoredRatelimit = {
	[string]: any
}

return nil