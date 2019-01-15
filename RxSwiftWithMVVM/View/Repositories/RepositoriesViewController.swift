import UIKit

import RxSwift
import RxCocoa
import RxAlamofire
import ObjectMapper

class RepositoriesViewController: ViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    /*
     ViewController에서는 View로부터 ViewModel에게 감시 대상(Observable)을 전달하고
     ViewModel의 Driver는 이를 감시 후 적절한 처리를 한다.
     (Driver인 이유는 View에게 전달받은 Observable의 처리 결과를 다시 View들에게 바인딩(드라이브)
     할 수 있도록 하기 위함?.. 아마도 ViewController에게 ViewModel의 output에 따른 처리를
     위임할 의도인 것 같음)
     */
    var repositoriesViewModel: RepositoriesViewModel!
    
    var rx_searchBarText: Observable<String> {
        return searchBar.rx.text
            .orEmpty
            .throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRx()
        setupUI()
        
    }
    
    
    // Rx 처리
    func setupRx() {
        
        repositoriesViewModel = RepositoriesViewModel(withNameObservable: rx_searchBarText)
        
        repositoriesViewModel
            .rx_respositories
            .drive(tableView.rx.items(cellIdentifier: "HaYunCell")) { (_, repository, cell) in
                cell.textLabel?.text = repository.name
                cell.detailTextLabel?.text = repository.url
            }
            .disposed(by: disposeBag)
    }
    
    
    // Rx 관련없는 처리
    func setupUI() {
        // UI 세팅 코드
        // 각종 Event 수신 관련 Notification 등록과 같은 코드를 작성
 
    }
    
}
