import RijksWondersServices

public final class ArtCollection {
    
    public var deliverQueue: DispatchQueue = .main // exposed for customiztion, if necessary
    
    let backend: SomeBackend
    
    public private(set) var pageNumber: UInt = 0
    
    public let pageSize: UInt
    
    public private(set) var items: [ArtObject] = []
    
    public private(set) var hasMore: Bool = false
    
    var onReady: () -> Void = {}
    
    var onUpdated: () -> Void = {}
    
    var onFailure: (Error) -> Void = { _ in }
    
    private(set) var isBusy = false
    
    public init(backend: SomeBackend, pageSize: UInt) throws {
        
        guard 1...100 ~= pageSize else { throw InitializationError.incorrectPageSize }
        
        self.backend = backend
        self.pageSize = pageSize
    }
}

// MARK: - Nested types

public extension ArtCollection {
    
    typealias ArtObject = CollectionEndpoint.ArtObject
    
    enum InitializationError: Error {
        case incorrectPageSize
    }
}

// MARK: - Commands

public extension ArtCollection {
    
    func fetch() {
        
        guard !isBusy, items.isEmpty else { return }
        
        isBusy = true
        let request = CollectionEndpoint(p: pageNumber, ps: pageSize)
        
        backend.sendGetRequest(request) { [weak self] result in
            
            guard let self = self else { return }
            
            self.deliverQueue.async {
                
                self.isBusy = false
                switch result {
                        
                    case .success(let responsePayload):
                        self.items = responsePayload.artObjects
                        self.hasMore = responsePayload.count > self.items.count
                        self.onReady()
                    case .failure(let error):
                        self.onFailure(error)
                }
            }
        }
    }
    
    func fetchNext() {
        
        guard !isBusy, hasMore else { return }
        
        isBusy = true
        pageNumber += 1
        let request = CollectionEndpoint(p: pageNumber, ps: pageSize)
        
        backend.sendGetRequest(request) { [weak self] result in
            
            guard let self = self else { return }
            
            self.deliverQueue.async {
                
                self.isBusy = false
                switch result {
                        
                    case .success(let responsePayload):
                        self.items += responsePayload.artObjects // +
                        self.hasMore = responsePayload.count > self.items.count // still has more?
                        self.onUpdated()
                    case .failure(let error):
                        self.onFailure(error)
                }
            }
        }
    }
}
