

import Foundation


class SimpleCountCalculator:CountCalculator{
  func countUp(val: Int) -> Int {
    let newValue = val + 1
    print("countUp \(val) -> \(newValue)")
    return newValue
  }

  func countDown(val: Int) -> Int {
    let newValue = val - 1
    print("countDown \(val) -> \(newValue)")
    return newValue
  }
}


class ThouthandCountCalculator:CountCalculator{
  func countUp(val: Int) -> Int {
   let newValue = val + 1000
    print("countUp \(val) -> \(newValue)")
    return newValue
  }

  func countDown(val: Int) -> Int {
    let newValue = val - 1000
    print("countDown \(val) -> \(newValue)")
    return newValue
  }
}
