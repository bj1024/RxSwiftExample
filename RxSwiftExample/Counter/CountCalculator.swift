

import Foundation
import RxSwift

class SimpleCountCalculator:CountCalculator{

  func countUp(val: Int, completion: @escaping (Result<Int, Error>) -> Void) {
    Thread.sleep(forTimeInterval: 0)

    let newValue = val + 1
    print("countUp \(val) -> \(newValue)")
    completion(.success(newValue))
  }

  func countDown(val: Int, completion: @escaping (Result<Int, Error>) -> Void) {
    Thread.sleep(forTimeInterval: 0)
    let newValue = val - 1
    print("countDown \(val) -> \(newValue)")
    completion(.success(newValue))
  }
}



//class ThouthandCountCalculator:CountCalculator{
//  func countUp(val: Int) -> Int {
//   let newValue = val + 1000
//    print("countUp \(val) -> \(newValue)")
//    return newValue
//  }
//
//  func countDown(val: Int) -> Int {
//    let newValue = val - 1000
//    print("countDown \(val) -> \(newValue)")
//    return newValue
//  }
//}
//

// なんと計算に3秒もかかるCalculator
class HeavyCountCalculator:CountCalculator{
  let queue = DispatchQueue(label: "com.myapp.countcalculator", qos: .utility)

  func countUp(val: Int, completion: @escaping (Result<Int, Error>) -> Void) {
    Thread.sleep(forTimeInterval: 3.0)
    let newValue = val + 1
    print("countUp \(val) -> \(newValue)")
    completion(.success(newValue))

  }

  func countDown(val: Int, completion: @escaping (Result<Int, Error>) -> Void) {
    Thread.sleep(forTimeInterval: 3.0)
    let newValue = val - 1
    print("countDown \(val) -> \(newValue)")
    completion(.success(newValue))

  }
}
