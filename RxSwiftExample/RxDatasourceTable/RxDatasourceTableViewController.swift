//
// Copyright (c) 2020, mycompany All rights reserved. 
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class RxDatasourceTableViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var buttonReload: UIButton!


  private var isBinded:Bool  = false
  private let disposeBag = DisposeBag()


  override func viewDidLoad() {
        super.viewDidLoad()


    }

  override func viewDidAppear(_ animated: Bool) {
     super.viewDidAppear(animated)

    if !isBinded {
      bind()
      isBinded = true
    }
  }

  func bind(){

    // RxSwiftCommunity/RxDataSources: UITableView and UICollectionView Data Sources for RxSwift (sections, animated updates, editing ...)
    // https://github.com/RxSwiftCommunity/RxDataSources

    let dataSource = RxTableViewSectionedReloadDataSource<SectionOfCustomData>(
      configureCell: { dataSource, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Item \(item.anInt): \(item.aString) - \(item.aCGPoint.x):\(item.aCGPoint.y)"
        return cell
    })

    dataSource.titleForHeaderInSection = { dataSource, index in
      return dataSource.sectionModels[index].header
    }

//    dataSource.titleForFooterInSection = { dataSource, index in
//      return dataSource.sectionModels[index].footer
//    }

    dataSource.canEditRowAtIndexPath = { dataSource, indexPath in
      return true
    }

    dataSource.canMoveRowAtIndexPath = { dataSource, indexPath in
      return true
    }

    let sections = [
      SectionOfCustomData(header: "First section", items: [CustomData(anInt: 0, aString: "zero", aCGPoint: CGPoint.zero), CustomData(anInt: 1, aString: "one", aCGPoint: CGPoint(x: 1, y: 1)) ]),
      SectionOfCustomData(header: "Second section", items: [CustomData(anInt: 2, aString: "two", aCGPoint: CGPoint(x: 2, y: 2)), CustomData(anInt: 3, aString: "three", aCGPoint: CGPoint(x: 3, y: 3)) ])
    ]

    Observable.just(sections)
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
//
//    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Int>>(configureCell: configureCell)
//    Observable.just([SectionModel(model: "title", items: [1, 2, 3])])
//        .bind(to: tableView.rx.items(dataSource: dataSource))
//        .disposed(by: disposeBag)


  }
  @IBAction func onTapReload(_ sender: Any) {


  }

}
