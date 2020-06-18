//
// Copyright (c) 2020, mycompany All rights reserved. 
//

import UIKit
import RxCocoa
import RxSwift


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

  @IBAction func onTapReload(_ sender: Any) {
  }

}
