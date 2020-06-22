
import Foundation
import RxCocoa
import RxSwift
protocol GitHubAPIProtocol{
  func search(keyword:String,completion: @escaping (Result<[String],Error>)-> Void)
}

enum GitHubAPIError: Error {
    case url(String)
    case request(String)
}


class GitHubAPI:GitHubAPIProtocol{
  //  let queue = DispatchQueue(label: "com.myapp.GitHubAPI", qos: .utility)

  private let disposeBag = DisposeBag()


  func search(keyword: String, completion: @escaping (Result<[String], Error>) -> Void) {
    print("GitHubAPI searching")

//    guard let url = URL(string: "https://api.github.com/search/repositories?q=\(keyword)") else {
      guard let url = URL(string: "https://api2.github.com/search/repositories?q=\(keyword)") else {
      completion(.failure(GitHubAPIError.url("url create error.")))
      return
    }


    let session = URLSession.shared.rx.json(url: url)
      .map { json -> ([String]) in
        guard let dict = json as? [String: Any] else {
          return []
        }
        guard let items = dict["items"] as? [[String: Any]] else {
          return []
        }
        let repos = items.compactMap { $0["full_name"] as? String }
        //        let nextPage = repos.isEmpty ? nil : page + 1
        //        return (repos, nextPage)

        return repos
    }
    .subscribe(
      onNext: { repos in
        print(repos)
        completion(.success(repos))
    },
      onError: { error in

        if case let .some(.httpRequestFailed(response, _)) = error as? RxCocoaURLError, response.statusCode == 403 {
          print("⚠️ GitHub API rate limit exceeded. Wait for 60 seconds and try again.")

          completion(.failure(GitHubAPIError.request("⚠️ GitHub API rate limit exceeded. Wait for 60 seconds and try again.")))
        }
        else{
            completion(.failure(GitHubAPIError.request("request error ")))
        }
    })
.disposed(by: disposeBag)
//    .do(onNext:{ value in
//      completion(.success(value))
//    },
//        onError: { error in
//          if case let .some(.httpRequestFailed(response, _)) = error as? RxCocoaURLError, response.statusCode == 403 {
//            print("⚠️ GitHub API rate limit exceeded. Wait for 60 seconds and try again.")
//
//            completion(.failure(GitHubAPIError.request("⚠️ GitHub API rate limit exceeded. Wait for 60 seconds and try again.")))
//          }
////    })
//      .disposed(by: disposeBag)
//
//
//    Thread.sleep(forTimeInterval: 3.0)
//    var newValue:[String] = ["keyword is [\(keyword)]"]
//    newValue.append(contentsOf:
//      "🍎🐶🍊🐺🍋🐱🍒🐭🍇🐹🍉🐰🍓🐸🍑🐯🍈🐨🍌🐻🍐🐷🍍🐥🍠🐢🍆🐝🍅🐞🌽🐳".map { String($0) }
//    )
//    completion(.success(newValue))
  }
}



class GitHubAPIDummy:GitHubAPIProtocol{

  func search(keyword: String, completion: @escaping (Result<[String], Error>) -> Void) {
    print("GitHubAPI searching")
    Thread.sleep(forTimeInterval: 3.0)
    var newValue:[String] = ["keyword is [\(keyword)]"]
    newValue.append(contentsOf:
      "🍎🐶🍊🐺🍋🐱🍒🐭🍇🐹🍉🐰🍓🐸🍑🐯🍈🐨🍌🐻🍐🐷🍍🐥🍠🐢🍆🐝🍅🐞🌽🐳".map { String($0) }
    )
    completion(.success(newValue))
  }
}
