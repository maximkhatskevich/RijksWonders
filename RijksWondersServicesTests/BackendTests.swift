import XCTest
@testable import RijksWondersServices

class BackendTests: XCTestCase {

    let sut = Backend(host: "example.com", key: "abc123")
}

// MARK: - Tests

extension BackendTests {
    
    func test_correctInitialization() {
        XCTAssertEqual(sut.host, "example.com")
        XCTAssertEqual(sut.key, "abc123")
    }
    
    func test_urlRequestGeneration_happyPath() throws {
        let request = CollectionEndpoint(culture: .nl, p: 3, ps: 15)
        let urlRequest = try sut.asURLRequest(request)
        guard let url = urlRequest.url else { return XCTFail("Expected non-empty URL") }
        XCTAssertEqual(url.absoluteString, "https://example.com/api/nl/collection?p=3&ps=15&key=abc123&format=json")
    }
}
