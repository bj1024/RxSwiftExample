import Foundation
import RxCocoa
import RxSwift


//
// RxSwift + MVVM Example
//



//
// RxSwift + MVVM: how to feed ViewModels - BlaBlaCar Tech - Medium https://medium.com/blablacar-tech/rxswift-mvvm-66827b8b3f10

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
  associatedtype Dependancy
  var input: Input { get }
  var output: Output { get }
  var dependancy: Dependancy{ get }
}

// CounterViewModelでの カウント処理のprotocol
// MVVM参考実装として、カウント処理を外部依存として実装してみる。
protocol CountCalculator{
  func countUp(val:Int)->Int
  func countDown(val:Int)->Int
}

class CounterViewModel: ViewModelType {
  var input: Input
  var output: Output
  var dependancy: Dependancy

  // PublishRelay: onNextのみ発生するSubject
  // Subject:Observer、Observableにもなれる。
  // Pub

  //
  // ObservableType Protocol（subscribe可能）なオブジェクトを設定する。
  // View側はUIオブジェクトをObservbableとして、Input要素とbindする。
  //  ※ bind時にsubscribeされる。
  // AnyObserver<T>： Observerを指定する場合。
  // PublishRelay: ボタンタップのようなイベント
  // BehaviorRelay:値の更新？（TODO）
  struct Input{
    let countUp:AnyObserver<Void>

    let countDown:PublishRelay<Void>

  }

  struct Output{
    let countLabel:Driver<Int>
  }

  struct Dependancy{
    let calculator:CountCalculator
  }

//  private let countUpSubject = PublishSubject<Void>()
//  private let countDownSubject = PublishSubject<Void>()
  private let disposeBag = DisposeBag()

  init(dependancy:Dependancy = Dependancy(calculator: SimpleCountCalculator())){
    let countSubject = BehaviorRelay<Int>(value: 0)

//    let countUpRelay = PublishRelay<Void>() // InputがPublishRelayの場合
    let countUpRelay = PublishSubject<Void>() // InputがAnyObserverの場合
    countUpRelay.subscribe(onNext: {  _ in
      let newVal = dependancy.calculator.countUp(val: countSubject.value)
      countSubject.accept( newVal)
    })
    .disposed(by: disposeBag)

    
    let countDownSubject = PublishRelay<Void>()
    countDownSubject.subscribe(onNext: {_ in
      let newVal = dependancy.calculator.countDown(val: countSubject.value)
      countSubject.accept(newVal)
    })
      .disposed(by: disposeBag)


    self.output = Output(countLabel: countSubject.asDriver())

    self.input = Input(
      countUp: countUpRelay.asObserver(),
      countDown: countDownSubject
    )

    self.dependancy = dependancy


  }

}

