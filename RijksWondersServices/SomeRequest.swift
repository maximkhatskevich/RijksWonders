/// Generic URL request representation.
public protocol SomeRequest {
    associatedtype ResponsePayload: SomeResponsePayload
    
    var path: String { get }
}
