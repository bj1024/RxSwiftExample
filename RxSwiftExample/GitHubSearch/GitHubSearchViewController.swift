//
// Copyright (c) 2020, mycompany All rights reserved. 
//

import UIKit

import RxCocoa
import RxSwift



class GitHubSearchViewController: UIViewController {

  private var viewModel:GitHubSearchViewModelProtocol = GitHubSearchViewModel()
  private let disposeBag = DisposeBag()



  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    bind()
  }

  func setViewModel(viewModel:GitHubSearchViewModelProtocol){
    self.viewModel = viewModel
  }

  func bind(){
  }

}
