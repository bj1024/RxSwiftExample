
import UIKit
import RxCocoa
import RxSwift


class CounterViewController: UIViewController {

  @IBOutlet weak var countLabel: UILabel!
  @IBOutlet weak var btnPlus: UIButton!
  @IBOutlet weak var btnMinus: UIButton!

  private var count = BehaviorRelay<Int>(value: 0)

  private let disposeBag = DisposeBag()


  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    bind()
  }


  func bind(){
    btnPlus.rx.tap
      .subscribe(onNext: {[unowned self] _ in
        self.count.accept(self.count.value + 1)

      })
      .disposed(by: disposeBag)

    btnMinus.rx.tap
      .subscribe(onNext: {[unowned self] _ in
        self.count.accept(self.count.value - 1)

      })
      .disposed(by: disposeBag)

    count.asDriver()
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
