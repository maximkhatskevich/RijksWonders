public struct CollectionEndpoint: SomeGetRequest {
    
    /// The language to search in (and of the results).
    public var culture: Culture = .en
    
    /// The result page. 0-n. Note that p * ps cannot exceed 10,000.
    public var p: UInt?
    
    /// The number of results per page. 1-100
    public var ps: UInt?
}

// MARK: - Calculated properties

public extension CollectionEndpoint {
    
    var path: String { "/api/\(culture)/collection" }
    
    var queryItems: [URLQueryItem] {
        
        var result: [URLQueryItem] = []
        
        if let value = p {
            result += [.init(name: "p", value: "\(value)")]
        }
        
        if let value = ps {
            result += [.init(name: "ps", value: "\(value)")]
        }
        
        return result
    }
}

// MARK: - Nested types

public extension CollectionEndpoint {
    
    /// The language to search in (and of the results).
    enum Culture: String {
        case en, nl
    }
}

// MARK: - Response

public extension CollectionEndpoint {
    struct ResponsePayload: SomeResponsePayload {
        public let count: Int
    }
}
