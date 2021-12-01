import Foundation

public enum BackendResponseFormat: String {
    case json // we only support JSON for now
}

public enum BackendRequestPreparationError: Error {
    case unableToConstructURL(URLComponents)
}

public protocol SomeBackend {
    
    /// URL scheme to be used with given backend.
    var scheme: String { get }
    
    /// Base part of the URL for any given request.
    var host: String { get }
    
    /// API key to be used with any given request.
    var key: String { get }
    
    func sendRequest<R: SomeResponsePayload>(_ request: URLRequest, _ callback: @escaping (Result<R, Error>) -> Void)
}

// MARK: - Helpers

extension SomeBackend {
    
    var responseFormat: BackendResponseFormat { .json }  // we only support JSON for now
    
    func asURLRequest<T: SomeGetRequest>(_ request: T) throws -> URLRequest {
        
        var components = request.asURLComponents
        components.scheme = scheme
        components.host = host
        components.queryItems = components
            .queryItems
            .map {
                $0 + [
                    .init(name: "key", value: key),
                    .init(name: "format", value: responseFormat.rawValue)
                ]
            }
        
        guard let url = components.url else {
            throw BackendRequestPreparationError.unableToConstructURL(components)
        }
        
        return .init(url: url)
    }
    
    public func sendGetRequest<T: SomeGetRequest>(_ request: T, _ callback: @escaping (Result<T.ResponsePayload, Error>) -> Void) {
        
        do {
            let urlRequest = try asURLRequest(request)
            sendRequest(urlRequest, callback)
        } catch {
            return callback(.failure(error))
        }
    }
}
