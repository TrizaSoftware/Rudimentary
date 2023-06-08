export type Middleware = {
    Inbound: {
        [number]: (...any) -> nil
    }?,
    Outbound: {
        [number]: (...any) -> nil
    }?,
    RequestsPerMinute: number?
}

export type ConnectionCallback = (...any) -> any

return {}