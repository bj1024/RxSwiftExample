
import Foundation
import RxCocoa
import RxSwift

public protocol APIRequest: Encodable {
  associatedtype Response: Decodable

  var path: String { get }
}

protocol GitHubAPIProtocol {
  func search(keyword: String, completion: @escaping (Result<[String], Error>) -> Void)
  func cancelSearch()
}

enum APIError: Error {
  case invalidBaseURL(String)
  case request(String)
  case decoding(String)
}

// Search | GitHub Developer Guide https://developer.github.com/v3/search/

class GitHubAPI: GitHubAPIProtocol {
  //  let queue = DispatchQueue(label: "com.myapp.GitHubAPI", qos: .utility)

  struct SearchResult: Decodable {
    let incompleteResults: Bool
    let totalCount: Int
    let items: [Item]

    struct Item: Decodable {
      let id: Int
      let fullName: String
    }
  }

  var searchDisposable: Disposable?

  private let disposeBag = DisposeBag()

  func search(keyword: String, completion: @escaping (Result<[String], Error>) -> Void) {
    print("GitHubAPI searching")

    // make url
    guard let url = URL(string: "https://api.github.com/search/repositories?q=\(keyword)") else {
//      guard let url = URL(string: "https://notexist.example.com/search/repositories?q=\(keyword)") else {  // error test
      completion(.failure(APIError.invalidBaseURL("url create error.")))
      return
    }

    var processDone: Bool = false
    // make URLRequest
    let req = URLRequest(url: url)

//    searchDisposable = URLSession.shared.rx.data(request: req)
    searchDisposable = URLSession.shared.rx.response(request: req)
      .subscribe(
        onNext: { data in
          print("data=[\(data)]" )

          let decoder = JSONDecoder()
          decoder.keyDecodingStrategy = .convertFromSnakeCase

          // debug
          if let dataStr = String(data: data, encoding: .utf8) {
            print("dataStr=\(dataStr)")
          }
          do {
            let json: SearchResult = try decoder.decode(SearchResult.self, from: data)
            print(json)
            completion(.success(["\(json)"]))

          } catch {
            print("error:", error.localizedDescription)
            completion(.failure(APIError.decoding(error.localizedDescription)))
          }
        },
        onError: { error in
          completion(.failure(APIError.request(error.localizedDescription)))
        },
        onCompleted: {
          print("onCompleted")

        },
        onDisposed: {
          print("onDisposed")
        }
      )
  }

  func cancelSearch() {
    guard let searchDisposable = self.searchDisposable else { return }
    print("cancelSearch")
    searchDisposable.dispose()

    self.searchDisposable = nil
  }

//
//    let session = URLSession.shared.rx.json(url: url)
//      .map { json -> ([String]) in
//        guard let dict = json as? [String: Any] else {
//          return []
//        }
//        guard let items = dict["items"] as? [[String: Any]] else {
//          return []
//        }
//        let repos = items.compactMap { $0["full_name"] as? String }
//        //        let nextPage = repos.isEmpty ? nil : page + 1
//        //        return (repos, nextPage)
//
//        return repos
//      }
//      .subscribe(
//        onNext: { repos in
//          print(repos)
//          completion(.success(repos))
//        },
//        onError: { error in
//
//          if case let .some(.httpRequestFailed(response, _)) = error as? RxCocoaURLError, response.statusCode == 403 {
//            print("⚠️ GitHub API rate limit exceeded. Wait for 60 seconds and try again.")
//
//            completion(.failure(GitHubAPIError.request("⚠️ GitHub API rate limit exceeded. Wait for 60 seconds and try again.")))
//          }
//          else {
//            completion(.failure(GitHubAPIError.request("request error ")))
//          }
//        }
//      )
//      .disposed(by: disposeBag)
//  }
}

class GitHubAPIDummy: GitHubAPIProtocol {
  func search(keyword: String, completion: @escaping (Result<[String], Error>) -> Void) {
    print("GitHubAPI searching")
    Thread.sleep(forTimeInterval: 3.0)
    var newValue: [String] = ["keyword is [\(keyword)]"]
    newValue.append(contentsOf:
      "🍎🐶🍊🐺🍋🐱🍒🐭🍇🐹🍉🐰🍓🐸🍑🐯🍈🐨🍌🐻🍐🐷🍍🐥🍠🐢🍆🐝🍅🐞🌽🐳".map { String($0) }
    )
    completion(.success(newValue))
  }

  func cancelSearch() {}
}
