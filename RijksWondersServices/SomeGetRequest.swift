import Foundation

/// Representationof GET request specifically.
public protocol SomeGetRequest: SomeRequest {
    var queryItems: [URLQueryItem] { get }
}

public extension SomeGetRequest {
    
    var asURLComponents: URLComponents {
        var components = URLComponents()
        components.path = path
        components.queryItems = queryItems
        return components
    }
}
