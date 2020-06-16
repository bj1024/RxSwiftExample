//
// Copyright (c) 2020, mycompany All rights reserved. 
//

import UIKit

import RxCocoa
import RxSwift



class GitHubSearchViewController: UIViewController {

  private var viewModel:GitHubSearchViewModelProtocol = GitHubSearchViewModel()
  private let disposeBag = DisposeBag()

  @IBOutlet var tableView: UITableView!
  let searchController = UISearchController(searchResultsController: nil)


  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.scrollIndicatorInsets.top = tableView.contentInset.top
    searchController.obscuresBackgroundDuringPresentation = false
    navigationItem.searchController = searchController

    // Do any additional setup after loading the view.
    bind()
  }

  
  func setViewModel(viewModel:GitHubSearchViewModelProtocol){
    self.viewModel = viewModel
  }

  func bind(){
  }

  override func viewDidAppear(_ animated: Bool) {
     super.viewDidAppear(animated)
     UIView.setAnimationsEnabled(false)
     searchController.isActive = true
     searchController.isActive = false
     UIView.setAnimationsEnabled(true)
   }
}
