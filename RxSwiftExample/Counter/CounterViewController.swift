
import RxCocoa
import RxSwift
import UIKit

class CounterViewController: UIViewController {
  @IBOutlet weak var countLabel: UILabel!
  @IBOutlet weak var btnPlus: UIButton!
  @IBOutlet weak var btnMinus: UIButton!

  private var viewModel: CounterViewModelProtocol = CounterViewModel()

  private let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    print("viewDidLoad CounterViewController")

    // Do any additional setup after loading the view.
    //    setViewModel(viewModel: CounterViewModel())
    bind()
  }

  deinit {
    print("deinit CounterViewController")
  }

  func setViewModel(viewModel: CounterViewModelProtocol) {
    self.viewModel = viewModel
  }

  func bind() {
    btnPlus.rx.tap
      .subscribe(onNext: { [unowned self] _ in
        self.viewModel.countUp()
      })
      .disposed(by: disposeBag)

    btnMinus.rx.tap
      .subscribe(onNext: { [unowned self] _ in
        self.viewModel.countDown()

      })
      .disposed(by: disposeBag)

    viewModel.count.map { "\($0)" }
      .bind(to: countLabel.rx.text)
      .disposed(by: disposeBag)
  }
}
