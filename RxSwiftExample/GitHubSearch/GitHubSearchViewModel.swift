
import Foundation
import RxCocoa
import RxSwift


protocol GitHubSearchViewModelProtocol {
  var keyword:BehaviorRelay<String> {get}
  var results:BehaviorRelay<[String]> {get}
  var isProcessing:BehaviorRelay<Bool> {get}
  func setKeyword(kw:String)
}

class GitHubSearchViewModel:GitHubSearchViewModelProtocol{

  
  var keyword  =  BehaviorRelay<String>(value: "")

  var results = BehaviorRelay<[String]>(value: ["a","b","c"])
  var isProcessing  =  BehaviorRelay<Bool>(value:false)


  private let disposeBag = DisposeBag()


  func setKeyword(kw:String){
    keyword.accept(kw)


    print("GitHubSearchViewModel isProcessing = \(self.isProcessing.value)")
    isProcessing.accept(true)

    let observableResult = search(keyword: kw)
    .subscribe(onNext: { [unowned self] repos in
//        print(repos)
      self.isProcessing.accept(false)
      self.results.accept(repos)
    })
     .disposed(by: disposeBag)
//
//    let cancelRequest = responseJSON
//        // this will fire the request
//        .subscribe(onNext: { json in
//            print(json)
//        })

//    Thread.sleep(forTimeInterval: 3.0)

    // if you want to cancel request after 3 seconds have passed just call
//    observableResult.dispose()
  //    DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + .seconds(3)){
  //      DispatchQueue.main.async {
  //          self.isProcessing.accept(false)
  //        print("GitHubSearchViewModel isProcessing = \(self.isProcessing.value)")
  //      }
  //    }


}

private func search(keyword:String) -> Observable<[String]>{

  guard let url =  URL(string: "https://api.github.com/search/repositories?q=\(keyword)") else {return .just([])}
  let observableResult:Observable<[String]> = URLSession.shared.rx.json(url: url)
    .map { json -> ([String]) in
      guard let dict = json as? [String: Any] else { return [] }
      guard let items = dict["items"] as? [[String: Any]] else { return [] }
      let repos = items.compactMap { $0["full_name"] as? String }
      //              let nextPage = repos.isEmpty ? nil : page + 1

      return repos
  }

  .do(onError: { error in
    if case let .some(.httpRequestFailed(response, _)) = error as? RxCocoaURLError, response.statusCode == 403 {
      print("⚠️ GitHub API rate limit exceeded. Wait for 60 seconds and try again.")
    }
  })
    .catchErrorJustReturn([])

  return observableResult


}

//   private func search(query: String?, page: Int) -> Observable<(repos: [String], nextPage: Int?)> {
//      let emptyResult: ([String], Int?) = ([], nil)
//      guard let url = self.url(for: query, page: page) else { return .just(emptyResult) }
//      return URLSession.shared.rx.json(url: url)
//        .map { json -> ([String], Int?) in
//          guard let dict = json as? [String: Any] else { return emptyResult }
//          guard let items = dict["items"] as? [[String: Any]] else { return emptyResult }
//          let repos = items.compactMap { $0["full_name"] as? String }
//          let nextPage = repos.isEmpty ? nil : page + 1
//          return (repos, nextPage)
//        }
//        .do(onError: { error in
//          if case let .some(.httpRequestFailed(response, _)) = error as? RxCocoaURLError, response.statusCode == 403 {
//            print("⚠️ GitHub API rate limit exceeded. Wait for 60 seconds and try again.")
//          }
//        })
//        .catchErrorJustReturn(emptyResult)
//    }
//  }
}
