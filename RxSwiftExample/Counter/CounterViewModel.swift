import Foundation
import RxCocoa
import RxSwift


//
// RxSwift + MVVM Example
//

//
// RxSwift + MVVM: how to feed ViewModels - BlaBlaCar Tech - Medium https://medium.com/blablacar-tech/rxswift-mvvm-66827b8b3f10

// CounterViewModelでの カウント処理のprotocol
// MVVM参考実装として、カウント処理を外部依存として実装してみる。
// カウント処理はなぜかとても時間のかかる処理としてみる。
//
// カウント処理終了を待つ方法としては、
// closure
// delegate
// observable
// など多数があるが、あまり難解にならないように、closureにする
protocol CountCalculator{
  func countUp(val:Int,completion: @escaping (Result<Int,Error>)-> Void)
  func countDown(val:Int,completion: @escaping (Result<Int,Error>)-> Void)
}

class CounterViewModel: ViewModelType {
  var input: Input
  var output: Output
  var dependancy: Dependancy

  // PublishRelay: onNextのみ発生するSubject
  // Subject:Observer、Observableにもなれる。
  // Pub

  // Input
  //
  // Observerなオブジェクトを設定する。
  // subscribe可能なObservableType Protocolを実装したオブジェクト。
  // View側はUI部品(Observbable)にbind(subscribe)する。
  //  ※ bind時にsubscribeされる。
  // AnyObserver<T>： Observerを指定する場合。
  // PublishRelay: ボタンタップのようなイベント
  // BehaviorRelay:値の更新？（TODO:INPUT では使わない？イベントを知るのみ）
  struct Input{
    let countUp:PublishRelay<Void>
    let countDown:PublishRelay<Void>
  }

  // Output
  //  Observerで返す。
  //  メインスレッド実行、エラーを流さない、Shareされることが保証されるDriver,Signalで返すのが良い。
  //  Share= 1つのObservableを共有する。 （2つ以上Subscribeされても、1つのObservableのOnNextを流す。）
  struct Output{
    let countLabel:Driver<Int>
    let isProcessing:Driver<Bool>
  }

  // ViewModelが依存する機能 APICallなどを指定する。
  //  Testabilityのために、コンストラクタで指定しViewModel内にハードコーディングしないようにする。
  //
  struct Dependancy{
    let calculator:CountCalculator
  }

//  private let countUpSubject = PublishSubject<Void>()
//  private let countDownSubject = PublishSubject<Void>()
  private let disposeBag = DisposeBag()

  //
  init(dependancy:Dependancy = Dependancy(calculator: SimpleCountCalculator())){

    // Countの状態を保持する変数。１つの状態を記憶する Subject BehaviorRelayを指定する。
    // BehaviorRelay なので、エラー・Completeは流さない。
    // Subjectのため、外部から値を変更でき、Observerに値を流すことができる。
    // OutputにはこのSubjectをDriver化してセットする。
    let countSubject = BehaviorRelay<Int>(value: 0)
    let isProcessingSubject = BehaviorRelay<Bool>(value:false)

    // Input 用のPublishRelay。Subscribeして、イベントを捉える。
    let countUpRelay = PublishRelay<Void>() // InputがPublishRelayの場合
    let countDownRelay = PublishRelay<Void>()


    countUpRelay
//      .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribe(onNext: {  _ in

        isProcessingSubject.accept(true)
        dependancy.calculator.countUp(val: countSubject.value){ result in
          switch(result){
          case .success(let newVal):
            countSubject.accept( newVal)
          case .failure(let error):
            print(error)
          }
          isProcessingSubject.accept(false)
        }
      })
      .disposed(by: disposeBag)


    countDownRelay
//      .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribe(onNext: {_ in

        isProcessingSubject.accept(true)
        dependancy.calculator.countDown(val: countSubject.value){ result in
          switch(result){
          case .success(let newVal):
            countSubject.accept( newVal)
          case .failure(let error):
            print(error)
          }
          isProcessingSubject.accept(false)
        }
      })
      .disposed(by: disposeBag)
//

    self.output = Output(
      countLabel: countSubject.asDriver(),
      isProcessing: isProcessingSubject.asDriver()
    )

    self.input = Input(
      countUp: countUpRelay,
      countDown: countDownRelay
    )

    self.dependancy = dependancy


  }

}

