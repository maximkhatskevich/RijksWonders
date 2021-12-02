import XCTest
@testable import RijksWondersModels
@testable import RijksWondersServices
@testable import RijksWondersViewModels

class ArtCollectionScreenTests: XCTestCase {
    
    fileprivate let backend = BackendMock(pageSize: 15)
    lazy var artCollection = try! ArtCollection(backend: backend, pageSize: 15)
    lazy var sut = try! ArtCollectionScreen(model: artCollection)
}

// MARK: - Tests

extension ArtCollectionScreenTests {
    
    func test_initialFetch_happyPath() throws {
        
        let expectReady = expectation(description: "Ready")
        
        XCTAssertEqual(sut.numberOfSections, 0)
        
        artCollection.onReady = { [unowned sut] in
            
            XCTAssertEqual(Thread.main, Thread.current)
            XCTAssertEqual(sut.numberOfSections, 1)
            XCTAssertEqual(sut.numberOfItemsInSection(at: 0), 16) // +1 for "load more" cell
            expectReady.fulfill()
        }
        
        sut.fetch()
        
        waitForExpectations(timeout: 1)
    }
    
    func test_subsequentFetch_happyPath() throws {
        
        let expectUpdate = expectation(description: "Update")
        
        sut.fetch()
        
        sut.onReady = { [unowned artCollection, unowned sut] in
            
            XCTAssertEqual(sut.numberOfItemsInSection(at: 0), 16) // +1 for "load more" cell
            
            self.backend.pageNumber = 1
            sut.fetchNext()
            
            sut.onUpdate = { [unowned artCollection, unowned sut] pageNumToUpdate in
                
                XCTAssertEqual(Thread.main, Thread.current)
                XCTAssertEqual(pageNumToUpdate, 1)
                XCTAssertEqual(artCollection.allItems.count, 23)
                XCTAssertEqual(sut.numberOfItemsInSection(at: 0), 15) // same as page size
                XCTAssertEqual(sut.numberOfItemsInSection(at: 1), 9) // +1 for "load more" cell
                expectUpdate.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func test_lastItemIndexes() throws {
        
        let expectReady = expectation(description: "Ready")
        
        artCollection.onReady = { [unowned artCollection, unowned sut] in
            
            XCTAssertEqual(sut.numberOfSections, 1)
            XCTAssertEqual(artCollection.allItems.count, 15)
            XCTAssertTrue(sut.isLast(item: 15, inLastSection: 0)) // +1 for "load more" cell
            expectReady.fulfill()
        }
        
        sut.fetch()
        
        waitForExpectations(timeout: 1)
    }
    
    func test_fetch_failure() throws {
        
        let expectFailure = expectation(description: "Failure")
        
        backend.shouldReturnError = true
        sut.onFailure = { _ in
            
            XCTAssertEqual(Thread.main, Thread.current)
            expectFailure.fulfill()
        }
        
        sut.fetch()
        
        waitForExpectations(timeout: 1)
    }
}

// MARK: - Helpers

fileprivate final class BackendMock: SomeBackend {
    
    let scheme = "https"
    let host = "example.com"
    let key = "abc123"
    let totalObjectsCount = 23
    
    var pageNumber = 0
    let pageSize: Int
    var shouldReturnError = false
    
    enum MockError: Error {
        case requestExecutionError
    }
    
    init(pageSize: Int) {
        self.pageSize = pageSize
    }
    
    func sendRequest<R>(_ request: URLRequest, _ callback: @escaping (Result<R, Error>) -> Void) where R : SomeResponsePayload {
         
        if shouldReturnError {
            callback(.failure(MockError.requestExecutionError))
        } else {
            let artObject = try! JSONDecoder()
                .decode(
                    ArtCollection.ArtObject.self,
                    from: sampleArtObject.data(using: .utf8)!
                )
            
            var targetAmount = totalObjectsCount - pageNumber * pageSize
            if targetAmount > pageSize { targetAmount = pageSize }
            
            let objects: [ArtCollection.ArtObject] = .init(repeating: artObject, count: targetAmount)
            
            let responsePayload = CollectionEndpoint.ResponsePayload(
                count: totalObjectsCount, artObjects: objects)
            
            callback(.success(responsePayload as! R))
        }
    }
    
    let sampleArtObject = """
        {
              "links": {
                "self": "http://www.rijksmuseum.nl/api/nl/collection/SK-C-5",
                "web": "http://www.rijksmuseum.nl/nl/collectie/SK-C-5"
              },
              "id": "nl-SK-C-5",
              "objectNumber": "SK-C-5",
              "title": "De Nachtwacht",
              "hasImage": true,
              "principalOrFirstMaker": "Rembrandt van Rijn",
              "longTitle": "De Nachtwacht, Rembrandt van Rijn, 1642",
              "showImage": true,
              "permitDownload": true,
              "webImage": {
                  "guid": "aa08df9c-0af9-4195-b31b-f578fbe0a4c9",
                  "offsetPercentageX": 0,
                  "offsetPercentageY": 1,
                  "width": 2500,
                  "height": 2034,
                  "url":"https://lh3.googleusercontent.com/J-mxAE7CPu-DXIOx4QKBtb0GC4ud37da1QK7CzbTIDswmvZHXhLm4Tv2-1H3iBXJWAW_bHm7dMl3j5wv_XiWAg55VOM=s0"
              },
              "headerImage": {
                "guid": "29a2a516-f1d2-4713-9cbd-7a4458026057",
                "offsetPercentageX": 0,
                "offsetPercentageY": 0,
                "width": 1920,
                "height": 460,
                "url": "https://lh3.googleusercontent.com/O7ES8hCeygPDvHSob5Yl4bPIRGA58EoCM-ouQYN6CYBw5jlELVqk2tLkHF5C45JJj-5QBqF6cA6zUfS66PUhQamHAw=s0"
              },
              "productionPlaces": ["Amsterdam"]
            }
        """
}
