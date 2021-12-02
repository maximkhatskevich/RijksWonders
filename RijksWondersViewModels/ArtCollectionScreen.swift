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
    typealias Section = (title: String, items: [Item])
    typealias Alert = (title: String, message: String)
}
    
// MARK: - Config - specific to this screen

public extension ArtCollectionScreen {
    
    static let pageSize: Int = 10
    static let cellId = "ArtCell"
    static let headerId = "ArtHeader"
    static let loadMoreCellId = "ArtCellLoadMore"
}

// MARK: - Misc

public extension ArtCollectionScreen {
    
    var numberOfPreloadedSections: Int {
        model.preloadedPaginatedItems.count
    }
    
    func preloadedSection(for index: Int) -> Section {
        let section = model.preloadedPaginatedItems[index] ?? []
        return (title: "Items \(index * Self.pageSize) - \((index + 1) * Self.pageSize - 1)", items: section)
    }
    
    func preloadedItem(for index: Int, section: Int) -> Item? {
        model.preloadedPaginatedItems[section]?[index]
    }
    
    var hasMore: Bool { model.hasMore }
    
    func fetch() {
        
        model.fetch()
    }
    
    func fetchNext() {
        
        model.fetchNext()
    }
}
