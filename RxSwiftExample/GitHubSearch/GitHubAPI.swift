import Foundation
import RxCocoa
import RxSwift

protocol DecodeFromJson {
//  static func decode(fromJsonData data: Data) -> Result<Self, Error>

  static var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy? { get }
}

// protocol URLSessionDataTaskProtocol {
//  func resume()
//  func cancel()
// }
//
// protocol URLSessionProtocol { typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void
//    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
// }

// extension URLSessionDataTask: URLSessionDataTaskProtocol {}
//
// extension URLSession: URLSessionProtocol {
//
//  func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
//    return dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTaskProtocol
//  }
//
////    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
////        return dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTaskProtocol
////    }
// }

struct APIDecorder {
  static func decode<T: Decodable & DecodeFromJson>(fromJsonData data: Data) -> Result<T, Error> {
    do {
      let decoder = JSONDecoder()
      if let keyDecodingStrategy = T.keyDecodingStrategy {
        decoder.keyDecodingStrategy = keyDecodingStrategy
      }
      let result: T = try decoder.decode(T.self, from: data)
      return .success(result)

    } catch {
      print("error:", error.localizedDescription)
      return .failure(error)
    }
  }
}

struct APIEncoder {
  static func toJson<T: Encodable>(data: T) -> Result<String, Error> {
    let encoder = JSONEncoder()
    do {
      let data = try encoder.encode(data)
      let jsonstr: String = String(data: data, encoding: .utf8)!
      return .success(jsonstr)
    } catch {
      print(error.localizedDescription)
      return .failure(error)
    }
  }
}

struct GitHubRepoSearchResult: Decodable, Encodable, DecodeFromJson {
  static var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy? = .convertFromSnakeCase
  struct Item: Decodable, Encodable {
    let id: Int
    let fullName: String
  }

  let incompleteResults: Bool
  let totalCount: Int
  let items: [Item]
}

//
// public protocol APIRequest: Encodable {
//  associatedtype Response: Decodable
//
//  var path: String { get }
// }

protocol GitHubAPIProtocol {
  func search(keyword: String, completion: @escaping (Result<[String], Error>) -> Void)

  func searchObservable(keyword: String) -> Single<GitHubRepoSearchResult>

  func cancelSearch()
}

//
// class API  {
//  var searchDisposable: Disposable?
//
//  private let disposeBag = DisposeBag()
//
//  func searchObservable(keyword: String) -> Single<SearchResult> {
//    return Single<SearchResult>.create { single in
//
//      guard let url = URL(string: "https://api.github.com/search/repositories?q=\(keyword)") else {
//        single(.error(APIError.invalidBaseURL(keyword)))
//        return Disposables.create()
//      }
//      let request = URLRequest(url: url)
//
//      let task = URLSession.shared.dataTask(with: request) { data, _, error in
//        if let error = error {
//          single(.error(error))
//          return
//        }
//        guard let data = data else {
//          single(.error(APIError.nodata))
//          return
//        }
//        let decoded:Result<SearchResult,Error> = APIDecorder.decode(fromJsonData: data)
//        switch decoded {
//        case let .success(searchResult):
//          single(.success(searchResult))
//        case let .failure(error):
//          print("error:", error.localizedDescription)
//          single(.error(APIError.decoding))
//        }
//      }
//
//      task.resume()
//
//      return Disposables.create { task.cancel() }
//    }
//  }
// }

// Search | GitHub Developer Guide https://developer.github.com/v3/search/
class GitHubAPI: GitHubAPIProtocol {
  //  let queue = DispatchQueue(label: "com.myapp.GitHubAPI", qos: .utility)

  var searchDisposable: Disposable?
  private let disposeBag = DisposeBag()

  func searchObservable(keyword: String) -> Single<GitHubRepoSearchResult> {
    return Single<GitHubRepoSearchResult>.create { [unowned self] single in

      guard let url = URL(string: "https://api.github.com/search/repositories?q=\(keyword)") else {
        single(.error(GitHubAPIError.invalidBaseURL(keyword)))
        return Disposables.create()
      }
      let request = URLRequest(url: url)

      let task = URLSession.shared.dataTask(with: request) { data, _, error in
        if let error = error {
          single(.error(error))
          return
        }
        guard let data = data else {
          single(.error(GitHubAPIError.nodata))
          return
        }
        let decoded: Result<GitHubRepoSearchResult, Error> = APIDecorder.decode(fromJsonData: data)
        switch decoded {
        case let .success(searchResult):
          single(.success(searchResult))
        case let .failure(error):
          print("error:", error.localizedDescription)
          single(.error(GitHubAPIError.decoding))
        }
      }

      task.resume()

      return Disposables.create { task.cancel() }
    }
  }

  func search(keyword: String, completion: @escaping (Result<[String], Error>) -> Void) {
    print("GitHubAPI searching")

    // make url
    guard let url = URL(string: "https://api.github.com/search/repositories?q=\(keyword)") else {
//      guard let url = URL(string: "https://notexist.example.com/search/repositories?q=\(keyword)") else {  // error test
      completion(.failure(GitHubAPIError.invalidBaseURL("url create error.")))
      return
    }

    var processDone: Bool = false
    // make URLRequest
    let req = URLRequest(url: url)

//    searchDisposable = URLSession.shared.rx.data(request: req)
//    searchDisposable = URLSession.shared.rx.response(request: req)
//      .subscribe(
//        onNext: { data in
//          print("data=[\(data)]" )
//
//          let decoder = JSONDecoder()
//          decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//          // debug
//          if let dataStr = String(data: data, encoding: .utf8) {
//            print("dataStr=\(dataStr)")
//          }
//          do {
//            let json: SearchResult = try decoder.decode(SearchResult.self, from: data)
//            print(json)
//            completion(.success(["\(json)"]))
//
//          } catch {
//            print("error:", error.localizedDescription)
//            completion(.failure(APIError.decoding(error.localizedDescription)))
//          }
//        },
//        onError: { error in
//          completion(.failure(APIError.request(error.localizedDescription)))
//        },
//        onCompleted: {
//          print("onCompleted")
//
//        },
//        onDisposed: {
//          print("onDisposed")
//        }
//      )
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

//
// class GitHubAPIDummy: GitHubAPIProtocol {
//  func search(keyword: String, completion: @escaping (Result<[String], Error>) -> Void) {
//    print("GitHubAPI searching")
//    Thread.sleep(forTimeInterval: 3.0)
//    var newValue: [String] = ["keyword is [\(keyword)]"]
//    newValue.append(contentsOf:
//      "🍎🐶🍊🐺🍋🐱🍒🐭🍇🐹🍉🐰🍓🐸🍑🐯🍈🐨🍌🐻🍐🐷🍍🐥🍠🐢🍆🐝🍅🐞🌽🐳".map { String($0) }
//    )
//    completion(.success(newValue))
//  }
//
//  func cancelSearch() {}
// }

enum GitHubAPIError: Error {
  case invalidBaseURL(String)
  case invalidurl
  case request(String)
  case nodata
  case decoding
}

struct GitHubSearchAPIRequest: APIRequest {
  func makeRequest(from keyword: String) throws -> URLRequest {
    guard let url = URL(string: "https://api.github.com/search/repositories?q=\(keyword)") else {
      throw GitHubAPIError.invalidurl
    }
    return URLRequest(url: url)
  }

  func parseResponse(data: Data) throws -> GitHubRepoSearchResult {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(GitHubRepoSearchResult.self, from: data)
  }

//  func makeRequest(from coordinate: CLLocationCoordinate2D) throws -> URLRequest {
//    guard CLLocationCoordinate2DIsValid(coordinate) else {
//      throw RequestError.invalidCoordinate
//    }
//    var components = URLComponents(string: "https://example.com/locations")!
//    components.queryItems = [
//      URLQueryItem(name: "lat", value: "\(coordinate.latitude)"),
//      URLQueryItem(name: "long", value: "\(coordinate.longitude)")
//    ]
//    return URLRequest(url: components.url!)
//  }
//
//  func parseResponse(data: Data) throws -> [PointOfInterest] {
//    return try JSONDecoder().decode([PointOfInterest].self, from: data)
//  }
}

class GitHubSearch {
  var urlSession: URLSession = URLSession.shared

  init(urlSession: URLSession = URLSession.shared) {
    self.urlSession = urlSession
  }

  func repositories_apiclosure(keyword: String) -> Single<GitHubRepoSearchResult> {
    return Single<GitHubRepoSearchResult>.create { [unowned self] single in
//      let request = GitHubSearchAPIRequest()
//      let urlSession = URLSession.shared
      let request = GitHubSearchAPIRequest()
      let loader = APIRequestLoader(apiRequest: request, urlSession: self.urlSession)
      let task = loader.loadAPIRequest(requestData: keyword) { result in
        switch result {
        case let .success(searchResult):
          single(.success(searchResult))
        case let .failure(error):
          print("error:", error.localizedDescription)
          single(.error(GitHubAPIError.decoding))
        }
      }

      return Disposables.create { task?.cancel() }
    }
  }

  func repositories(keyword: String) -> Single<GitHubRepoSearchResult> {
    let request = GitHubSearchAPIRequest()
    let loader = APIRequestLoader(apiRequest: request, urlSession: urlSession)
    return loader.loadAPIRequest(requestData: keyword)
  }
}
