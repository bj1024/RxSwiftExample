
import RxCocoa
import RxSwift
import UIKit

class CounterViewController: UIViewController {
  @IBOutlet weak var countLabel: UILabel!
  @IBOutlet weak var btnPlus: UIButton!
  @IBOutlet weak var btnMinus: UIButton!

  private var viewModel = CounterViewModel()

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
  }
}
