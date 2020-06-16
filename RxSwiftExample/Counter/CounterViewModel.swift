//
// Copyright (c) 2020, mycompany All rights reserved. 
//

import Foundation
import RxCocoa
import RxSwift


protocol CounterViewModelProtocol {
  var count:BehaviorRelay<Int> {get}
  func countUp()
  func countDown()
}

class CounterViewModel:CounterViewModelProtocol{
  var count = BehaviorRelay<Int>(value: 0)

  func countUp(){
    count.accept(count.value + 1)
  }

  func countDown(){
    count.accept(count.value - 1)
  }

}
