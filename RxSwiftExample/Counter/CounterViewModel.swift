//
// Copyright (c) 2020, mycompany All rights reserved. 
//

import Foundation
import RxCocoa
import RxSwift


protocol CounterViewModelProtocol {
  var count:BehaviorRelay<Int> {get}
}

class CounterViewModel:CounterViewModelProtocol{
 var count = BehaviorRelay<Int>(value: 0)
}
