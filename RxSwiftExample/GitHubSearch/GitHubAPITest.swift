//
// Copyright (c) 2020, mycompany All rights reserved.
//

import XCTest

import RxCocoa
import RxSwift

@testable import RxSwiftExample

class GitHubAPITest: XCTestCase {
  private let disposeBag = DisposeBag()

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testSearch() throws {
    let expectation = XCTestExpectation(description: "Test")

    let api = GitHubAPI()
    api.search(keyword: "swift") { result in
      switch result {
      case let .success(searchResult):
        print("searchResult=\(searchResult)")
      case let .failure(error):
        print("error=\(error)")
//        self.XCTAssert(false, "\(error)")(
      }

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 30.0)
  }

  func testCancel() throws {
    let expectation = XCTestExpectation(description: "Test")

    let api = GitHubAPI()
    api.search(keyword: "swift") { result in
      switch result {
      case let .success(searchResult):
        print("searchResult=\(searchResult)")
      case let .failure(error):
        print("error=\(error)")
        //        self.XCTAssert(false, "\(error)")(
      }

      expectation.fulfill()
    }

    api.cancelSearch()
    wait(for: [expectation], timeout: 30.0)
  }
}
