/// https://data.rijksmuseum.nl/object-metadata/api/#collection-api
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
    
    struct ResponsePayload: SomeResponsePayload {
        public let count: Int
        public let artObjects: [ArtObject]
    }
    
    struct ArtObject: Decodable {
        public let links: Links
        public let id: String
        public let title: String
        public let principalOrFirstMaker: String
        public let longTitle: String
        public let webImage: ImageMetadata
        public let headerImage: ImageMetadata
    }
}

public extension CollectionEndpoint.ArtObject {
    
    struct Links: Decodable {
        
        public let `self`: URL
        public let web: URL
    }
    
    struct ImageMetadata: Decodable {
        public let guid: String
        public let url: URL
    }
}
