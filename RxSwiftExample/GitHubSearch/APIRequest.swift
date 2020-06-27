import Foundation
import RxCocoa
import RxSwift

protocol APIRequest {
  associatedtype RequestDataType
  associatedtype ResponseDataType
  func makeRequest(from data: RequestDataType) throws -> URLRequest
  func parseResponse(data: Data) throws -> ResponseDataType
}

enum APIError: Error {
  case canceled
  case data
}

class APIRequestLoader<T: APIRequest> {
  let apiRequest: T
  let urlSession: URLSession

  init(apiRequest: T, urlSession: URLSession = .shared) {
    self.apiRequest = apiRequest
    self.urlSession = urlSession
  }

  func loadAPIRequest(requestData: T.RequestDataType,
                      completion: @escaping (Result<T.ResponseDataType, Error>) -> Void) -> URLSessionDataTask? {
    do {
      let urlRequest = try apiRequest.makeRequest(from: requestData)
      let task = urlSession.dataTask(with: urlRequest) { data, _, error in
        guard let data = data else { return completion(.failure(error ?? APIError.data)) }
        do {
          let parsedResponse = try self.apiRequest.parseResponse(data: data)
          completion(.success(parsedResponse))
        } catch {
          completion(.failure(error))
        }
      }
      task.resume()
      return task
    } catch { completion(.failure(error)); return nil }
  }

  func loadAPIRequest(requestData: T.RequestDataType) -> Single<T.ResponseDataType> {
    return Single<T.ResponseDataType>.create { single in
      do {
        let urlRequest = try self.apiRequest.makeRequest(from: requestData)

        let task = self.urlSession.dataTask(with: urlRequest) { data, _, error in
          guard let data = data else {
            single(.error(error ?? APIError.data))
            return
          }
          do {
            let parsedResponse = try self.apiRequest.parseResponse(data: data)
            single(.success(parsedResponse))

          } catch {
            single(.error(error))
          }
        }
        task.resume()
        return Disposables.create {
          task.cancel()
        }
      }
      catch {
        single(.error(error))
        return Disposables.create()
      }
    }
  }
}
