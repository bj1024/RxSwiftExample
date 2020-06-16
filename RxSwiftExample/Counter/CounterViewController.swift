
import UIKit
import RxCocoa
import RxSwift


class CounterViewController: UIViewController {

  @IBOutlet weak var countLabel: UILabel!
  @IBOutlet weak var btnPlus: UIButton!
  @IBOutlet weak var btnMinus: UIButton!


  private var viewModel:CounterViewModelProtocol = CounterViewModel()

  private let disposeBag = DisposeBag()



  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
//    setViewModel(viewModel: CounterViewModel())
    bind()
  }

  func setViewModel(viewModel:CounterViewModelProtocol){
    self.viewModel = viewModel
  }


  func bind(){
    btnPlus.rx.tap
      .subscribe(onNext: {[unowned self] _ in
        self.viewModel.count.accept(self.viewModel.count.value + 1)

      })
      .disposed(by: disposeBag)

    btnMinus.rx.tap
      .subscribe(onNext: {[unowned self] _ in
        self.viewModel.count.accept(self.viewModel.count.value - 1)

      })
      .disposed(by: disposeBag)

    viewModel.count.asDriver()
      .drive(onNext: { (element) in
        print(element)
        self.countLabel.text = "\(element)"
      })
      .disposed(by: disposeBag)
    

  }
  /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */

}
