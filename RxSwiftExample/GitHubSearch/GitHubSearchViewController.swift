
import UIKit

import RxCocoa
import RxSwift

class GitHubSearchViewController: UIViewController {
  private var viewModel = GitHubSearchViewModel()

  private var isBinded: Bool = false
  private let disposeBag = DisposeBag()

  @IBOutlet var tableView: UITableView!
  @IBOutlet var buttonShowAlert: UIButton!

  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  let searchController = UISearchController(searchResultsController: nil)

  override func viewDidLoad() {
    super.viewDidLoad()
    print("viewDidLoad GitHubSearchViewController")
//    tableView.delegate = self
//       tableView.dataSource = self

    tableView.scrollIndicatorInsets.top = tableView.contentInset.top
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.autocapitalizationType = .none
    navigationItem.searchController = searchController
  }

  deinit {
    print("deinit GitHubSearchViewController")
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    UIView.setAnimationsEnabled(false)
    searchController.isActive = true
    searchController.isActive = false
    UIView.setAnimationsEnabled(true)

    if !isBinded {
      bindViewModel()
      isBinded = true
    }
  }

  func bindViewModel() {
    // Action

    // orEmpty
//    let searchTextObservable = searchController.searchBar.rx.text.orEmpty.asObservable()

//    searchTextObservable
//      .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
//      .subscribe(onNext: { [unowned self] event in
//        print("tap event: \(event)")
//        self.viewModel.setKeyword(kw: event)
//      })

    searchController.searchBar.rx.text.orEmpty.bind(to: viewModel.input.keyword)
      .disposed(by: disposeBag)

    buttonShowAlert.rx.tap.bind(to: viewModel.input.showAlert )
      .disposed(by: disposeBag)
//
//    viewModel.keyword
//    .bind(to: tableView.rx.items(cellIdentifier: "cell")) { indexPath, repo, cell in
//      cell.textLabel?.text = repo
//    }
//    .disposed(by: disposeBag)

    viewModel.output.results
      .drive(tableView.rx.items(cellIdentifier: "cell")) { _, repo, cell in
        cell.textLabel?.text = repo
      }
      .disposed(by: disposeBag)

    viewModel.output.isProcessing
      .drive(onNext: { [unowned self] val in
        self.activityIndicator.isHidden = !val
        if val {
          self.activityIndicator.startAnimating()
        }
        else {
          self.activityIndicator.stopAnimating()
        }
      })
      .disposed(by: disposeBag)

    viewModel.output.showAlertMessage
      .drive(onNext: { [unowned self] val in
        guard let message = val else { return }
        self.showAlert(mes: message)

      })
      .disposed(by: disposeBag)

//    viewModel.isProcessing.map{ !$0 }
//      .bind(to: activityIndicator.rx.isHidden)
//    .disposed(by: disposeBag)
//    viewModel.isProcessing.map{ $0 }
//      .bind(to: activityIndicator.rx.isAnimating)
//    .disposed(by: disposeBag)
  }

  func showAlert( mes: String) {
    let alert = UIAlertController(title: "",
                                  message: mes,
                                  preferredStyle: UIAlertController.Style.alert)

    let defaultAction = UIAlertAction(title: "OK", style: .default) { _ in
      print("OK")
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
      print("cancel")
    }

    alert.addAction(cancelAction)
    alert.addAction(defaultAction)

    present(alert, animated: true, completion: nil)
  }
}

//
// extension GitHubSearchViewController:UITableViewDelegate{
//
// }
//
// extension GitHubSearchViewController:UITableViewDataSource{
//
//  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//    return 0
//  }
//
//  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//    let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
//
//    let menuIdx = indexPath.row
//    cell.accessoryType = .disclosureIndicator
//    cell.textLabel?.text = "\(indexPath.row + 1)"
//    return cell
//  }
//  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//  }
//
//  func numberOfSections(in tableView: UITableView) -> Int {
//    return 1
//  }
//
//
// }
