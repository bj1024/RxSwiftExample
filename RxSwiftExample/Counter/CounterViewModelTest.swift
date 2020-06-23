//
// Copyright (c) 2020, mycompany All rights reserved.
//

import XCTest

import RxCocoa
import RxSwift

@testable import RxSwiftExample

class CountCalculatorMock: CountCalculator {
  var countUpCalledCount: Int = 0
  var countDownCalledCount: Int = 0

  var isMainThread: Bool = false // MainThreadでCallされた場合にTrue

  let calculator: CountCalculator // 処理を委譲するプロトコル。

  init(calculator: CountCalculator) {
    self.calculator = calculator
  }

  func countUp(val: Int, completion: @escaping (Result<Int, Error>) -> Void) {
    isMainThread = Thread.isMainThread
    countUpCalledCount += 1
    calculator.countUp(val: val, completion: completion)
  }

  func countDown(val: Int, completion: @escaping (Result<Int, Error>) -> Void) {
    isMainThread = Thread.isMainThread

    countDownCalledCount += 1
    calculator.countUp(val: val, completion: completion)
  }
}

class CounterViewModelTest: XCTestCase {
  private let disposeBag = DisposeBag()

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testCreateCounterViewModel() throws {
    let vm = CounterViewModel()
    XCTAssertNotNil(vm)
  }

  func testCountUp() throws {
    let expectation = XCTestExpectation(description: "Test")

    let vm = CounterViewModel()

    // 0 → 1 → 2 → 3をチェック
    var cnt: Int = 0
    vm.output.countLabel.drive(onNext: { v in
      //      print("[\(cnt+1)]times [\(v)]")
      XCTAssertEqual(v, cnt)
      cnt += 1

    })
      .disposed(by: disposeBag)
    vm.output.countLabel.asObservable()
      .elementAt(3)
      .subscribe(onNext: { _ in
        expectation.fulfill()
    }).disposed(by: disposeBag)
    // 3回イベントEmit
    let event = Observable<Void>.from([(), (), ()])
    event.bind(to: vm.input.countUp)
      .disposed(by: disposeBag)

    wait(for: [expectation], timeout: 5.0)
  }

  func testCountUpCalled() throws {
    let expectation = XCTestExpectation(description: "Test")

    let calculatorMock = CountCalculatorMock(
      calculator: SimpleCountCalculator()
    )

    let vm = CounterViewModel(
      dependency: CounterViewModel.Dependency(calculator: calculatorMock )
    )

    vm.output.countLabel.asObservable()
      .elementAt(3)
      .subscribe(onNext: { val in
        print("val=\(val)")
        XCTAssertEqual(val, 3)
        XCTAssertEqual(calculatorMock.countUpCalledCount, 3) // ３回分発生するはず
        XCTAssertEqual(calculatorMock.countDownCalledCount, 0) // CountDownがCallされないこともチェック
        XCTAssertFalse(calculatorMock.isMainThread, "run on background thread")
        XCTAssertTrue(Thread.isMainThread, "run on Main thread") // Output MainThreadのチェック

        expectation.fulfill()
    })
      .disposed(by: disposeBag)

    let event = Observable<Void>.from([(), (), ()])
    event.bind(to: vm.input.countUp)
      .disposed(by: disposeBag)

    wait(for: [expectation], timeout: 5.0)
  }

  func testCountDown() throws {
    let expectation = XCTestExpectation(description: "Test")

    let vm = CounterViewModel()

    var cnt: Int = 0
    vm.output.countLabel.drive(onNext: { v in
      print("drive [\(v)]")
      XCTAssertEqual(v, cnt)
      cnt -= 1
    })
      .disposed(by: disposeBag)

    vm.output.countLabel.asObservable()
      .elementAt(3)
      .subscribe(onNext: { _ in
        expectation.fulfill()
    })
      .disposed(by: disposeBag)

    let event = Observable<Void>.from([(), (), ()])
    event.bind(to: vm.input.countDown)
      .disposed(by: disposeBag)

    wait(for: [expectation], timeout: 5.0)
  }

  func testCountDownCalled() throws {
    let expectation = XCTestExpectation(description: "Test")

    let calculatorMock = CountCalculatorMock(
      calculator: SimpleCountCalculator()
    )

    let vm = CounterViewModel(
      dependency: CounterViewModel.Dependency(calculator: calculatorMock )
    )

    let event = Observable<Void>.from([(), (), ()])

    vm.output.countLabel.asObservable()
      .elementAt(3)
      .subscribe(onNext: { val in
        print("val=\(val)")
        XCTAssertEqual(val, 3)
        XCTAssertEqual(calculatorMock.countUpCalledCount, 0)
        XCTAssertEqual(calculatorMock.countDownCalledCount, 3)
        XCTAssertFalse(calculatorMock.isMainThread, "run on background thread")
        XCTAssertTrue(Thread.isMainThread, "run on Main thread")
        expectation.fulfill()
      })
      .disposed(by: disposeBag)

    event.bind(to: vm.input.countDown)
      .disposed(by: disposeBag)

    wait(for: [expectation], timeout: 5.0)
  }

//
//
//  func testPerformanceExample() throws {
//    // This is an example of a performance test case.
//    self.measure {
//      // Put the code you want to measure the time of here.
//    }
//  }
}
