import Foundation
import RxCocoa
import RxSwift

protocol GitHubAPIProtocol {
  func repositories(keyword: String) -> Single<GitHubRepoSearchResult>

  func cancelSearch()
}

enum GitHubAPIError: Error {
  case invalidBaseURL(String)
  case invalidurl
  case request(String)
  case nodata
  case decoding
}

struct GitHubRepoSearchResult: Codable {
  static var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy? = .convertFromSnakeCase
  struct Item: Decodable, Encodable {
    let id: Int
    let fullName: String
  }

  let incompleteResults: Bool
  let totalCount: Int
  let items: [Item]

  static var empty: GitHubRepoSearchResult {
    return GitHubRepoSearchResult(incompleteResults: false, totalCount: 0, items: [])
  }
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
}

class GitHubAPI: GitHubAPIProtocol {
  func cancelSearch() {}

  var urlSession: URLSession = URLSession.shared

  init(urlSession: URLSession = URLSession.shared) {
    self.urlSession = urlSession
  }

  func repositories_apiclosure(keyword: String) -> Single<GitHubRepoSearchResult> {
    return Single<GitHubRepoSearchResult>.create { [unowned self] single in
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
