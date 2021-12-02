import RijksWondersServices

public final class ArtCollection {
    
    public var deliverQueue: DispatchQueue = .main // exposed for customiztion, if necessary
    
    let backend: SomeBackend
    
    public private(set) var pageNumber: Int = 0
    
    public let pageSize: Int
    
    public private(set) var totalAvailableItemsCount: Int = 0
    public private(set) var allAvailablePageCounts: [Int: Int] = [:]
    
    public private(set) var preloadedPaginatedItems: [Int: [ArtObject]] = [:] {
        didSet {
            hasMore = allPreloadedItems.count < totalAvailableItemsCount
        }
    }
    
    public var allPreloadedItems: [ArtObject] { preloadedPaginatedItems.values.flatMap { $0 } }
    
    public private(set) var hasMore: Bool = false
    
    public var onStartLoading: () -> Void = {}
    
    public var onStopLoading: () -> Void = {}
    
    public var onReady: () -> Void = {}
    
    public var onUpdate: (_ sectionToUpdate: Int) -> Void = { _ in }
    
    public var onFailure: (Error) -> Void = { _ in }
    
    private(set) var isLoading = false {
        didSet {
            if isLoading {
                self.onStartLoading()
            } else {
                self.onStopLoading()
            }
        }
    }
    
    public init(backend: SomeBackend? = nil, pageSize: Int) throws {
        
        guard 1...100 ~= pageSize else { throw InitializationError.incorrectPageSize }
        
        self.backend = backend ?? Backend(
            host: Config.backendHost,
            key: Config.backendKey
        )
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
        
        guard !isLoading, preloadedPaginatedItems.isEmpty else { return }
        
        let request = CollectionEndpoint(p: pageNumber, ps: pageSize)
        
        isLoading = true
        backend.sendGetRequest(request) { [weak self] result in
            
            guard let self = self else { return }
            
            self.deliverQueue.async {
                
                self.isLoading = false
                
                switch result {
                        
                    case .success(let responsePayload):
                        self.totalAvailableItemsCount = responsePayload.count
                        
                        let totalNumberOfFullPages = Int(self.totalAvailableItemsCount / self.pageSize)
                        
                        (0...totalNumberOfFullPages).forEach {
                            self.allAvailablePageCounts[$0] = self.pageSize
                        }
                        
                        self.allAvailablePageCounts[totalNumberOfFullPages + 1] = self.totalAvailableItemsCount % self.pageSize
                        
                        self.preloadedPaginatedItems[self.pageNumber] = responsePayload.artObjects
                        self.onReady()
                        
                    case .failure(let error):
                        self.onFailure(error)
                }
            }
        }
    }
    
    func fetchNext() {
        
        guard !isLoading, hasMore else { return }
        
        pageNumber += 1
        let request = CollectionEndpoint(p: pageNumber, ps: pageSize)
        
        isLoading = true
        backend.sendGetRequest(request) { [weak self] result in
            
            guard let self = self else { return }
            
            self.deliverQueue.async {
                
                self.isLoading = false
                
                switch result {
                        
                    case .success(let responsePayload):
                        self.preloadedPaginatedItems[self.pageNumber] = responsePayload.artObjects
                        self.onUpdate(self.pageNumber)
                    case .failure(let error):
                        self.onFailure(error)
                }
            }
        }
    }
}
