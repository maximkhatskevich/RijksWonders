import RijksWondersModels

public final class ArtCollectionScreen {
    
    let model: ArtCollection
    
    public var onStartLoading: () -> Void {
        get {
            model.onStartLoading
        }
        set {
            model.onStartLoading = newValue
        }
    }
    
    public var onStopLoading: () -> Void {
        get {
            model.onStopLoading
        }
        set {
            model.onStopLoading = newValue
        }
    }
    
    public var onReady: () -> Void {
        get {
            model.onReady
        }
        set {
            model.onReady = newValue
        }
    }
    
    public var onUpdate: (_ sectionToUpdate: Int) -> Void {
        get {
            model.onUpdate
        }
        set {
            model.onUpdate = newValue
        }
    }
    
    public var onFailure: (Alert) -> Void = { _ in }
    
    public var sections: [Section] {
        model.preloadedPaginatedItems.map { (header: "\($0.key)", items: $0.value) }
    }
    
    public var canLoadMore: Bool { model.hasMore }
    
    public init(model: ArtCollection? = nil) throws {
        
        self.model = try model ?? ArtCollection(pageSize: Self.pageSize)
        
        self.model.onFailure = { [unowned self] in
            let alert: Alert = ("Something went wrong", $0.localizedDescription)
            self.onFailure(alert)
        }
    }
}

// MARK: - Nested types

public extension ArtCollectionScreen {
    
    typealias Item = ArtCollection.ArtObject
    typealias Section = (header: String, items: [Item])
    typealias Alert = (title: String, message: String)
}
    
// MARK: - Config - specific to this screen

public extension ArtCollectionScreen {
    
    static let pageSize: Int = 10
    static let cellId = "ArtCell"
}

// MARK: - Commands

public extension ArtCollectionScreen {
    
    func fetch() {
        
        model.fetch()
    }
    
    func fetchNext() {
        
        model.fetchNext()
    }
}
