
import Foundation

protocol GitHubAPIProtocol{
  func search(keyword:String,completion: @escaping (Result<[String],Error>)-> Void)
}

class GitHubAPI:GitHubAPIProtocol{
  //  let queue = DispatchQueue(label: "com.myapp.GitHubAPI", qos: .utility)

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

