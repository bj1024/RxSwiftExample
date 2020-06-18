//
// Copyright (c) 2020, mycompany All rights reserved.
//

import Foundation

import RxCocoa
import RxDataSources
import RxSwift

struct CustomData {
  var anInt: Int
  var aString: String
  var aCGPoint: CGPoint
}

struct SectionOfCustomData {
  var header: String
  var items: [Item]
}

extension SectionOfCustomData: SectionModelType {
  typealias Item = CustomData

  init(original: SectionOfCustomData, items: [Item]) {
    self = original
    self.items = items
  }
}

protocol RxDatasourceTableModelProtocol {
  var sections: BehaviorRelay<[SectionOfCustomData]> { get }
  var runnningTimer: BehaviorRelay<DispatchSourceTimer?> { get }
  func toggleRun()
}

class RxDatasourceTableViewModel: RxDatasourceTableModelProtocol {
  // let myDatasourceQueue = DispatchQueue(label: "キュー2", qos: .userInitiated, attributes: .concurrent)

  var runnningTimer = BehaviorRelay<DispatchSourceTimer?>(value: nil)

  var sections = BehaviorRelay<[SectionOfCustomData]>(value:
    [
      SectionOfCustomData(header: "First section",
                          items: [
                            CustomData(anInt: 0, aString: "zero", aCGPoint: CGPoint.zero),
                            CustomData(anInt: 1, aString: "one", aCGPoint: CGPoint(x: 1, y: 1))
                          ])
    ])

  func toggleRun() {
    if let timer = runnningTimer.value {
      timer.cancel()
      runnningTimer.accept(nil)
    }
    else {
      let timer = DispatchSource.makeTimerSource(flags: [],
                                                 queue: DispatchQueue.global(qos: .default))

      timer.schedule(deadline: .now(), repeating: 1.0)

      timer.setEventHandler { [weak self] in
        print(Date())
        self?.randData()
      }
      timer.resume()
      runnningTimer.accept(timer)
    }
  }

  private func randData() {
    let num = Int.random(in: 0..<1000)
    print("num=\(num)")

    var newItems: [CustomData] = []
    for i in 0..<num {
      print("i=\(i)")
      newItems.append(CustomData(
        anInt: i + 1,
        aString: randomString(length: 5),
        aCGPoint: CGPoint(x: i, y: i)
      )
      )
    }

    sections.accept(
      [
        SectionOfCustomData(header: "First section",
                            items: newItems)
      ]
    )
  }

  func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map { _ in letters.randomElement()! })
  }

}
