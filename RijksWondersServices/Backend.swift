public final class Backend: SomeBackend {
    
    /// URL session to be used for network requests.
    public var session: URLSession = .shared // exposed for customization, if necessary
    
    /// Respoonse payload decoder.
    public var decoder = JSONDecoder()  // exposed for customization, if necessary
    
    public var assumedDataAsStringEncoding = String.Encoding.utf8 // exposed for customization, if necessary
    
    /// URL scheme to be used with given backend.
    public var scheme = "https" // exposed for customization, if necessary
    
    /// Base part of the URL for any given request.
    public let host: String
    
    /// API key to be added to all requests
    public let key: String
    
    // MARK:  Initialization
    
    public init(host: String, key: String) {
        self.host = host
        self.key = key
    }
}

// MARK: - Nested types

public extension Backend {
    
    enum ResponseParsingError: Error {
        case missingResponse
        case unexpectedResponsePayload(expected: SomeResponsePayload.Type, actual: String?)
    }
}

// MARK: - SomeBackend conformance

public extension Backend {
    
    func sendRequest<T: SomeResponsePayload>(_ request: URLRequest, _ callback: @escaping (Result<T, Error>) -> Void) {
        
        let task = session.dataTask(with: request) { dataMaybe, _, errorMaybe in
            
            if let error = errorMaybe {
                return callback(.failure(error))
            }
            
            guard let data = dataMaybe else {
                return callback(.failure(ResponseParsingError.missingResponse))
            }
            
            do {
                let responsePayload = try self.decoder.decode(T.self, from: data)
                callback(.success(responsePayload))
            } catch {
                return callback(.failure(ResponseParsingError.unexpectedResponsePayload(expected: T.self, actual: String(data: data, encoding: self.assumedDataAsStringEncoding))))
            }
        }
        task.resume()
    }
}
