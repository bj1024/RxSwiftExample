
import Foundation
import RxCocoa
import RxSwift

class GitHubSearchViewModel: ViewModelType {
  private let backgroundScheduler = SerialDispatchQueueScheduler(queue: .global(qos: .default), internalSerialQueueName: "com.myapp.background")

  struct Input {
    let keyword: PublishRelay<String>
    let showAlert: PublishRelay<Void>
  }

  struct Output {
    let results: Driver<[String]>
    let isProcessing: Driver<Bool>
    let showAlertMessage: Driver<String?>
  }

  struct Dependency {
    let gitHubAPI: GitHubAPIProtocol
  }

  var input: Input
  var output: Output
  var dependency: Dependency

  private let disposeBag = DisposeBag()

  init(dependency: Dependency = Dependency(gitHubAPI: GitHubAPI())) {
    let keyword = PublishRelay<String>()
    let showAlertTap = PublishRelay<Void>()
    let results = PublishRelay<[String]>()
    let isProcessingSubject = BehaviorRelay<Bool>(value: false)
    let showAlertMessageSubject = BehaviorRelay<String?>(value: nil)

    keyword
      .observeOn(backgroundScheduler) // 処理ThreadをBackgroundに変える。OutputのDriverでMainThreadに変更される。
      .debounce(.milliseconds(1000), scheduler: MainScheduler.instance)
      .filter { ($0.isEmpty || $0.count > 2) }
      .distinctUntilChanged()
      .flatMap { keyword -> Observable<GitHubRepoSearchResult> in

        if keyword.isEmpty {
          //          return Observable<GitHubRepoSearchResult>.of(GitHubRepoSearchResult.empty)
          return Observable.error(APIError.param)
            .catchErrorJustReturn(GitHubRepoSearchResult.empty)
        }
        isProcessingSubject.accept(true)

        return dependency.gitHubAPI.repositories(keyword: keyword).asObservable()
      }
      .subscribe { event in
        print(event) // if error happened, this will also print out error to console
        isProcessingSubject.accept(false)

        switch event {
        case let .next(val):
          print("onNext = [\(val)]")
          results.accept(val.items.map {
            $0.fullName
        })
        case let .error(error):
          print("onError = [\(error)]")
        case .completed:
          print("onCompleted")
        }
      }
      .disposed(by: disposeBag)

    showAlertTap
      .subscribe(onNext: { event in
        print("showAlertTap = [\(event)]")

        showAlertMessageSubject.accept(Date().description)

        })
      .disposed(by: disposeBag)

    output = Output(
      results: results.asDriver(onErrorJustReturn: []),
      isProcessing: isProcessingSubject.asDriver(),
      showAlertMessage: showAlertMessageSubject.asDriver()
    )

    input = Input(
      keyword: keyword,
      showAlert: showAlertTap
    )

    self.dependency = dependency
  }

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
