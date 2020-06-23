
import Foundation
import RxCocoa
import RxSwift

class GitHubSearchViewModel: ViewModelType {
  private let backgroundScheduler = SerialDispatchQueueScheduler(queue: .global(qos: .default), internalSerialQueueName: "com.myapp.background")

  struct Input {
    let keyword: PublishRelay<String>
  }

  struct Output {
    let results: Driver<[String]>
    let isProcessing: Driver<Bool>
  }

  struct Dependency {
    let apiGitHub: GitHubAPIProtocol
  }

  var input: Input
  var output: Output
  var dependency: Dependency

  private let disposeBag = DisposeBag()

  init(dependency: Dependency = Dependency(apiGitHub: GitHubAPI())) {
    let keyword = PublishRelay<String>()
    let results = PublishRelay<[String]>()
    let isProcessingSubject = BehaviorRelay<Bool>(value: false)

    keyword
      .debounce(.milliseconds(1000), scheduler: MainScheduler.instance)
      .filter { ($0.isEmpty || $0.count > 2) }
      .observeOn( backgroundScheduler) // ThreadをBackgroundに変える OutputのDriverでMainThreadに変更される。
      .subscribe(onNext: { str in

        if str.isEmpty {
          results.accept([])
          return
        }

        isProcessingSubject.accept(true)
        dependency.apiGitHub.search(keyword: str) { result in
          switch result {
          case let .success(newVal):
            results.accept(newVal )
          case let .failure(error):
            print(error)
          }
          isProcessingSubject.accept(false)
        }
      })
      .disposed(by: disposeBag)

    output = Output(
      results: results.asDriver(onErrorJustReturn: []),
      isProcessing: isProcessingSubject.asDriver()
    )

    input = Input(
      keyword: keyword
    )

    self.dependency = dependency
  }

//  var keyword = BehaviorRelay<String>(value: "")
//  var results = BehaviorRelay<[String]>(value: ["a", "b", "c"])
//  var isProcessing = BehaviorRelay<Bool>(value: false)

//
//
//  func setKeyword(kw: String) {
//    keyword.accept(kw)
//
//    print("GitHubSearchViewModel isProcessing = \(isProcessing.value)")
//    isProcessing.accept(true)
//
//    let observableResult = search(keyword: kw)
//      .subscribe(onNext: { [unowned self] repos in
  ////        print(repos)
//        self.isProcessing.accept(false)
//        self.results.accept(repos)
//      })
//      .disposed(by: disposeBag)
  ////
  ////    let cancelRequest = responseJSON
  ////        // this will fire the request
  ////        .subscribe(onNext: { json in
  ////            print(json)
  ////        })
//
  ////    Thread.sleep(forTimeInterval: 3.0)
//
//    // if you want to cancel request after 3 seconds have passed just call
  ////    observableResult.dispose()
//    //    DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + .seconds(3)){
//    //      DispatchQueue.main.async {
//    //          self.isProcessing.accept(false)
//    //        print("GitHubSearchViewModel isProcessing = \(self.isProcessing.value)")
//    //      }
//    //    }
//  }

  private func search(keyword: String) -> Observable<[String]> {
    guard let url = URL(string: "https://api.github.com/search/repositories?q=\(keyword)") else { return .just([]) }
    let observableResult: Observable<[String]> = URLSession.shared.rx.json(url: url)
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
