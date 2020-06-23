//
// Copyright (c) 2020, mycompany All rights reserved.
//

import Foundation

import RxCocoa
import RxDataSources
import RxSwift

struct CustomData: IdentifiableType, Equatable {
  typealias Identity = Int

  var anInt: Int
  var aString: String
  var aCGPoint: CGPoint

  var identity: Int {
    return anInt
  }
}

struct SectionOfCustomData {
  var header: String
  var items: [Item]
}

extension SectionOfCustomData: AnimatableSectionModelType {
  typealias Item = CustomData

  init(original: SectionOfCustomData, items: [Item]) {
    self = original
    self.items = items
  }

  var identity: String {
    // headerをSectionのIDとする。Headerを変更するとSectionがすり替わる。
    return header
  }
}

protocol RxDatasourceTableModelProtocol {
  var sections: BehaviorRelay<[SectionOfCustomData]> { get }
  var runnningTimer: BehaviorRelay<DispatchSourceTimer?> { get }
  var status: BehaviorRelay<String> { get }
  func toggleRun()
}

class RxDatasourceTableViewModel: RxDatasourceTableModelProtocol {
  // let myDatasourceQueue = DispatchQueue(label: "キュー2", qos: .userInitiated, attributes: .concurrent)

  var runnningTimer = BehaviorRelay<DispatchSourceTimer?>(value: nil)
  var status = BehaviorRelay<String>(value: "")

  let sectionTitle = ["items"]
  let characters = Array("🍎🐶🍊🐺🍋🐱🍒🐭🍇🐹🍉🐰🍓🐸🍑🐯🍈🐨🍌🐻🍐🐷🍍🐥🍠🐢🍆🐝🍅🐞🌽🐳")

  enum RunStep {
    case create
    case sort
    case insert
    case delete
  }

  private var step: RunStep = .create

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
        guard let self = self else { return }

        print(Date())
        self.stepData()
      }
      timer.resume()
      runnningTimer.accept(timer)
    }
  }

  private func stepData() {
    switch step {
    case .create:
      createData()
      step = .sort
    case .sort:
      sortData()
      step = .insert
    case .insert:
      insertData()
      step = .delete
    case .delete:
      deleteData()
      step = .create
    }
  }

  private func createData() {
    let num = Int.random(in: 1 ..< 30)
    print("num=\(num)")

    var newItems: [CustomData] = []
    for i in 0 ..< num {
//      print("i=\(i)")
      newItems.append(
        createItem(idx: i)
      )
    }

    sections.accept(
      [
        SectionOfCustomData(header: sectionTitle[0],
                            items: newItems)
      ]
    )

    status.accept("create \(num) items")
  }

  private func sortData() {
    var newItems = sections.value[0].items

    newItems.shuffle()
    sections.accept(
      [
        SectionOfCustomData(header: sectionTitle[0],
                            items: newItems)
      ]
    )
    status.accept("sort items")
  }

  private func insertData() {
    var newItems = sections.value[0].items

    let insNum = min(Int.random(in: 1 ... newItems.count), 100)

    for _ in 0 ..< insNum {
      let insIdx = Int.random(in: 0 ..< newItems.count)
      let newItem = createItem(idx: newItems.count + 1)
      newItems.insert(newItem, at: insIdx)
    }

    sections.accept(
      [
        SectionOfCustomData(header: sectionTitle[0],
                            items: newItems)
      ]
    )
    status.accept("insert \(insNum) items")
  }

  private func deleteData() {
    var newItems = sections.value[0].items

    let delNum = min(Int.random(in: 1 ... newItems.count), 100)

    for _ in 0 ..< delNum {
      let delidx = Int.random(in: 0 ..< newItems.count)
      newItems.remove(at: delidx)
    }

    sections.accept(
      [
        SectionOfCustomData(header: sectionTitle[0],
                            items: newItems)
      ]
    )
    status.accept("remove \(delNum) items")
  }

  private func createItem(idx: Int) -> CustomData {
    let str = String(characters[idx % characters.count])
    return CustomData(
      anInt: idx,
      aString: str,
      aCGPoint: CGPoint(x: idx, y: idx)
    )
  }

  func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0 ..< length).map { _ in letters.randomElement()! })
  }
}
