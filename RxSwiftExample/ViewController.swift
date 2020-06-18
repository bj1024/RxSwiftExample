//
// Copyright (c) 2020, mycompany All rights reserved. 
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!

  private var isBinded:Bool  = false
  private let disposeBag = DisposeBag()

  enum ViewControllerDef{
    case counter
    case gitHubSearch
    case rxDatasourceTable


    func getVC() -> UIViewController{
      var storyboardName:String
      var id:String
      switch self {

      case .counter:
        storyboardName="Counter"
        id="CounterViewController"
      case .gitHubSearch:
        storyboardName="GitHubSearch"
        id="GitHubSearchViewController"


      case .rxDatasourceTable:
        storyboardName="RxDatasourceTable"
        id="RxDatasourceTableViewController"
      }

      let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
      let vc = storyboard.instantiateViewController(withIdentifier: id)
      return vc
    }

  }
  struct Menu{
    var name:String
    var vcdef:ViewControllerDef
  }
  
  //  let menus:[Menu] = [
  //    Menu(name:"Counter",vcdef:.counter),
  //    Menu(name:"GitHub Search",vcdef:.gitHubSearch)
  //  ]

  let menus = Observable<[Menu]>.just([
    Menu(name:"Counter",vcdef:.counter),
    Menu(name:"GitHub Search",vcdef:.gitHubSearch),
    Menu(name:"RxDatasource Table",vcdef:.rxDatasourceTable)
  ])
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    

  }


  override func viewDidAppear(_ animated: Bool) {

    super.viewDidAppear(animated)

    if !isBinded {
      bind()
      isBinded = true
    }
  }

  private func bind(){
    menus.bind(to:tableView.rx.items(cellIdentifier:"tableViewCell")){   (index,menu,cell) in
      cell.accessoryType = .disclosureIndicator
      cell.textLabel?.text = "\(index + 1)  \(menu.name)"
    }
    .disposed(by: disposeBag)

    tableView.rx.modelSelected(Menu.self)
      .subscribe(onNext:  {[weak self] menu in

        print("itemSelected \(menu) ")
        self?.showVC(menu:menu)
      })
      .disposed(by: disposeBag)

  }

  func showVC(menu:Menu){
      let vc  = menu.vcdef.getVC()

      self.navigationController?.pushViewController(vc, animated: true)
      //    self.present(vc, animated: true, completion: nil)
    }
}

//
//
//extension ViewController:UITableViewDelegate{
//
//}
//
//extension ViewController:UITableViewDataSource{
//
//  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//    return menus.count
//  }
//
//  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//    let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
//
//    let menuIdx = indexPath.row
//    cell.accessoryType = .disclosureIndicator
//    cell.textLabel?.text = "\(menuIdx + 1)  \(menus[menuIdx].name)"
//    return cell
//  }
//  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    let menuIdx = indexPath.row
//    showVC(menu:menus[menuIdx])
//  }
//
//  func numberOfSections(in tableView: UITableView) -> Int {
//    return 1
//  }
//

//
//}
//
