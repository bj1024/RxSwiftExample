
import Foundation
import RxCocoa
import RxSwift


protocol GitHubSearchViewModelProtocol {
  var count:BehaviorRelay<Int> {get}
}

class GitHubSearchViewModel:GitHubSearchViewModelProtocol{
 var count = BehaviorRelay<Int>(value: 0)
}
