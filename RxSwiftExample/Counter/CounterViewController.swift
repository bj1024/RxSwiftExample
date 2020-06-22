
import RxCocoa
import RxSwift
import UIKit

class CounterViewController: UIViewController {
  @IBOutlet weak var countLabel: UILabel!
  @IBOutlet weak var btnPlus: UIButton!
  @IBOutlet weak var btnMinus: UIButton!

  @IBOutlet weak var waitIndicator: UIActivityIndicatorView!
  private var viewModel = CounterViewModel(
    dependancy:CounterViewModel.Dependancy(calculator: HeavyCountCalculator())
  )

  private let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    print("viewDidLoad CounterViewController")

    // Do any additional setup after loading the view.
    //    setViewModel(viewModel: CounterViewModel())
    bindViewModel()
  }

  deinit {
    print("deinit CounterViewController")
  }


  func bindViewModel() {
    btnPlus.rx.tap
      .bind(to: viewModel.input.countUp)
      .disposed(by: disposeBag)

    btnMinus.rx.tap
      .bind(to: viewModel.input.countDown)
      .disposed(by: disposeBag)

    viewModel.output.countLabel
      .map{"\($0)"}
      .drive(countLabel.rx.text)
    .disposed(by: disposeBag)

//    viewModel.output.isProcessing
//         .map{!$0}
//         .drive(btnPlus.rx.isEnabled)
//       .disposed(by: disposeBag)
//    viewModel.output.isProcessing
//      .map{!$0}
//      .drive(btnMinus.rx.isEnabled)
//    .disposed(by: disposeBag)

    viewModel.output.isProcessing
    .distinctUntilChanged()
      .drive(onNext:{ [unowned self] isProcessing in

        if isProcessing{
          self.waitIndicator.isHidden = false
          self.waitIndicator.startAnimating()
          self.btnPlus.isEnabled = false
          self.btnMinus.isEnabled = false

        }
        else{
          self.waitIndicator.isHidden = true
          self.waitIndicator.stopAnimating()
          self.btnPlus.isEnabled = true
          self.btnMinus.isEnabled = true
        }


      })
    .disposed(by: disposeBag)




  }
}
