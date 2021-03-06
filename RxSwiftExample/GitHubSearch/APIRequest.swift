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
  case nullData
  case param
}

class APIRequestLoader<T: APIRequest> {
  let apiRequest: T
  let urlSession: URLSession

  init(apiRequest: T, urlSession: URLSession = .shared) {
    self.apiRequest = apiRequest
    self.urlSession = urlSession
  }

  // Requestを送信する。Closureで完了通知するバージョン
  // Cancelする場合は、戻り値のURLSessionDataTaskのcancel()をCallする。
  func loadAPIRequest(requestData: T.RequestDataType,
                      completion: @escaping (Result<T.ResponseDataType, Error>) -> Void) -> URLSessionDataTask? {
    do {
      let urlRequest = try apiRequest.makeRequest(from: requestData)
      let task = urlSession.dataTask(with: urlRequest) { data, _, error in
        guard let data = data else { return completion(.failure(error ?? APIError.nullData)) }
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

  // Requestを送信する。Observable（Single）で完了通知するバージョン
  // Cancelする場合は、subscribe後のDisposableをdisposeする。
  func loadAPIRequest(requestData: T.RequestDataType) -> Single<T.ResponseDataType> {
    return Single<T.ResponseDataType>.create { single in
      do {
        let urlRequest = try self.apiRequest.makeRequest(from: requestData)

        let task = self.urlSession.dataTask(with: urlRequest) { data, _, error in
          guard let data = data else {
            single(.error(error ?? APIError.nullData))
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
