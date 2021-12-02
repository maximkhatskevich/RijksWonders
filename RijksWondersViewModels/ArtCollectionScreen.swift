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
    
    var numberOfSections: Int {
        
        model.itemsPerPage.count
    }
    
    func numberOfItemsInSection(at sectionIndex: Int) -> Int {
        
        let shouldShowLoadMoreButton = sectionIndex == lastSectionIndex
        let sectionItems = model.itemsPerPage[sectionIndex] ?? []
        return sectionItems.count + (shouldShowLoadMoreButton ? 1 : 0)
    }
    
    func isLast(item itemIndex: Int, inLastSection sectionIndex: Int) -> Bool {
        
        let isLastSection = (sectionIndex == lastSectionIndex)
        let isLastCell = itemIndex == lastItemIndexInSection(at: sectionIndex)
        
        return isLastSection && isLastCell
    }
    
    func item(at itemIndex: Int, inSection sectionIndex: Int) -> Item? {
        
        model.itemsPerPage[sectionIndex]?[itemIndex]
    }
    
    func section(at sectionIndex: Int) -> Section? {
        
        model
            .itemsPerPage[sectionIndex]
            .map {(
                "Items \(sectionIndex * Self.pageSize) - \((sectionIndex + 1) * Self.pageSize - 1)",
                items: $0
            )}
    }
    
    func fetch() {
        
        model.fetch()
    }
    
    func fetchNext() {
        
        model.fetchNext()
    }
}

// MARK: - Helpers

private extension ArtCollectionScreen {
    
    var lastSectionIndex: Int {
        
        numberOfSections - 1
    }
    
    func lastItemIndexInSection(at indexSection: Int) -> Int {
        
        numberOfItemsInSection(at: indexSection) - 1
    }
}
