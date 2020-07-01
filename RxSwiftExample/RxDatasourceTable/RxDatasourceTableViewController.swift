import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class RxDatasourceTableViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var buttonReload: UIButton!

  private var viewModel: RxDatasourceTableModelProtocol = RxDatasourceTableViewModel()
  private var isBinded: Bool = false
  private let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()

    buttonReload.setTitle("", for: .normal)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    if !isBinded {
      bind()
      isBinded = true
    }
    viewModel.toggleRun()
  }

  func bind() {
    // RxSwiftCommunity/RxDataSources: UITableView and UICollectionView Data Sources for RxSwift (sections, animated updates, editing ...)
    // https://github.com/RxSwiftCommunity/RxDataSources

//    let dataSource = RxTableViewSectionedReloadDataSource<SectionOfCustomData>(
    let dataSource = RxTableViewSectionedAnimatedDataSource<SectionOfCustomData>(
      configureCell: { _, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        cell.textLabel?.text = "Item \(item.anInt): \(item.aString) - \(item.aCGPoint.x):\(item.aCGPoint.y)"

        cell.textLabel?.text = "Item \(String(format: "%3d", item.anInt)) \(item.aString) "
        return cell
      }
    )

    dataSource.titleForHeaderInSection = { dataSource, index in
      dataSource.sectionModels[index].header
    }

//    dataSource.titleForFooterInSection = { dataSource, index in
//      return dataSource.sectionModels[index].footer
//    }

    dataSource.canEditRowAtIndexPath = { _, _ in
      true
    }

    dataSource.canMoveRowAtIndexPath = { _, _ in
      true
    }

    viewModel.sections
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)

    buttonReload.rx.tap
      .subscribe { [unowned self] _ in
        self.viewModel.toggleRun()
      }
      .disposed(by: disposeBag)

    viewModel.runnningTimer
      .map { $0 == nil ? "Start" : "Stop" }
      .bind(to: buttonReload.rx.title())
      .disposed(by: disposeBag)

    viewModel.runnningTimer
      .map { $0 == nil ? UIColor.blue : UIColor.red }
      .bind(to: buttonReload.rx.backgroundColor)
      .disposed(by: disposeBag)
  }

  @IBAction func onTapReload(_ sender: Any) {}
}
