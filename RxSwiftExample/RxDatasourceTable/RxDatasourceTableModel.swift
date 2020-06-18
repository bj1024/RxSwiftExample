//
// Copyright (c) 2020, mycompany All rights reserved. 
//

import Foundation

import RxSwift
import RxCocoa
import RxDataSources

protocol RxDatasourceTableModelProtocol {
  var results:BehaviorRelay<[String]> {get}
}

class RxDatasourceTableModel:RxDatasourceTableModelProtocol{
  var results = BehaviorRelay<[String]>(value: ["a","b","c"])

}

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

