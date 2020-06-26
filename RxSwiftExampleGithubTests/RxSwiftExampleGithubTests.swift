//
// Copyright (c) 2020, mycompany All rights reserved.
//

import RxCocoa
import RxSwift
import XCTest

class RxSwiftExampleGithubTests: XCTestCase {
  private let disposeBag = DisposeBag()

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testSearchObservable() throws {
    let expectation = XCTestExpectation(description: "Test")

    let api = GitHubAPI()
    api.searchObservable(keyword: "swift")
      .subscribe { event in
        switch event {
        case let .success(searchResult):
          print("Result: ", searchResult)
        case let .error(error):
          print("Error: ", error)
        }

        expectation.fulfill()
      }
      .disposed(by: disposeBag)

    wait(for: [expectation], timeout: 30.0)
  }
}
