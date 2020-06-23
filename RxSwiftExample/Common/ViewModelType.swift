
//
// RxSwift + MVVM Example
//

// ViewModelの形を定義するprotocol。
// ViewModelは次を保持する。（わかりやすいように、入出力、外部依存別に分ける。）
//
//  Input:ViewController → ViewModel
//  Output:ViewModel → ViewController
//  Dependancy: ViewModelが依存する処理（REST APICALLなど）
//
//  Input Output Dependancyの詳細な型はわからないので、associatedtypeとし、
//  各ViewModel実装時に任せる。
//  このprotocolでは Input Output Dependancyが必要ですよと宣言するのみ。
//
protocol ViewModelType {
  associatedtype Input
  associatedtype Output
  associatedtype Dependency
  var input: Input { get }
  var output: Output { get }
  var dependency: Dependency { get }
}
