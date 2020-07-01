import XCTest

import RxCocoa
import RxSwift

@testable import RxSwiftExample

class MockURLProtocol: URLProtocol {
  override class func canInit(with request: URLRequest) -> Bool {
    return true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }

  static var isStopLoadingCalled: Bool = false

  static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
  override func startLoading() {
    guard let handler = MockURLProtocol.requestHandler else {
      XCTFail("Received unexpected request with no handler set")
      return
    }
    do {
      let (response, data) = try handler(request)
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: data)
      client?.urlProtocolDidFinishLoading(self)
    } catch {
      client?.urlProtocol(self, didFailWithError: error)
    }
  }

  override func stopLoading() {
    print("++++++++++++++ stopLoading ++++++++++++++")

    MockURLProtocol.isStopLoadingCalled = true
  }
}

class GitHubAPITest: XCTestCase {
  private let disposeBag = DisposeBag()

  private let backgroundScheduler = SerialDispatchQueueScheduler(queue: .global(qos: .default), internalSerialQueueName: "com.myapp.background")

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testGitHubAPIRepositories() throws {
    let expectation = XCTestExpectation(description: "Test")

    let json = """
    {
        "incomplete_results":true,
        "total_count":9999,
        "items":[{
                "full_name":"test_fullname",
                "id":1234567890,
                "name":"test_name"
        }]
    }
    """

    let keyword = "swift"

    // MockのClosureを指定して、テストする。
    let mockJSONData = json.data(using: .utf8)!
    MockURLProtocol.requestHandler = { request in

      // request に keywordが含まれているかチェックする。
      XCTAssertEqual(request.url?.query?.contains(keyword), true)

      // ダミーデータを返す。
      return (HTTPURLResponse(), mockJSONData)
    }

    // Mockを利用するURLSessionを定義する。
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    let urlSession = URLSession(configuration: configuration)

    let api = GitHubAPI()
    api.urlSession = urlSession

    api.repositories(keyword: keyword)
      .subscribe { event in
        switch event {
        case let .success(searchResult):
          print("Result: ", searchResult)
          XCTAssertEqual(searchResult.totalCount, 9999)
          XCTAssertEqual(searchResult.incompleteResults, true)
          XCTAssertEqual(searchResult.items[0].id, 1_234_567_890)
          XCTAssertEqual(searchResult.items[0].fullName, "test_fullname")

        case let .error(error):
          print("Error: ", error)
          XCTAssert(false)
        }
        expectation.fulfill()
      }
      .disposed(by: disposeBag)

    wait(for: [expectation], timeout: 30.0)
  }

  func testGitHubAPIRepositoriesCancel() throws {
    // MockのClosureを指定して、テストする。
//    let mockJSONData = json.data(using: .utf8)!
    MockURLProtocol.requestHandler = { _ in
      // ダミーデータを返す。
      (HTTPURLResponse(), "dummy".data(using: .utf8)!)
    }

    // Mockを利用するURLSessionを定義する。
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    let urlSession = URLSession(configuration: configuration)

    let api = GitHubAPI()
    api.urlSession = urlSession

    XCTAssertFalse(MockURLProtocol.isStopLoadingCalled) // StopLoading が未Callを確認

    let disposable = api.repositories(keyword: "swift")
      .debug("single")
      .observeOn( backgroundScheduler) // ThreadをBackgroundに変える
      .subscribe { event in
        switch event {
        case let .success(searchResult):
          print("Result: ", searchResult)

        case let .error(error):
          print("Error: ", error)
        }
      }
    Thread.sleep(forTimeInterval: 0.1)
    disposable.dispose()

    Thread.sleep(forTimeInterval: 0.5)
    XCTAssertTrue(MockURLProtocol.isStopLoadingCalled) // StopLoading がCallされたことを確認
  }
}
