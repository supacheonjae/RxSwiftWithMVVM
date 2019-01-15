import RxSwift
import RxCocoa

class RepositoriesViewModel {
    
    // 객체의 초기화에 맞게 늦게 초기화(바인딩된 data를 토대로 통보(방출)할 Subject)
    lazy var rx_respositories: Driver<[Repository]> = self.fetchRepositories()
    // 감시 대상 변수 선언 (View에서 바인딩할, 모니터링할 data)
    private var repositoryName: Observable<String>
    
    // 감시할 변수 초기화
    init(withNameObservable nameObservable: Observable<String>) {
        self.repositoryName = nameObservable
    }
    
    /*
     API에 엑세스하여 데이터를 검색하고 ViewController 측의 UI 처리와
     바인딩을 위하여 Driver로 변환하는 처리
     */
    private func fetchRepositories() -> Driver<[Repository]> {
        return repositoryName
            // Phase 1. 데이터 수신 중 외형에 대한 처리
            .subscribeOn(MainScheduler.instance) // UI 부분이라 메인 스레드에서 작업을 수행
            .do(onNext: { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            })
            // Phase 2. RxAlamofire를 통한 API 엑세스 처리는 백그라운드에서
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest { githubID in
                // Phase 3. API 결과를 통한 Data 클래스 반환 과정은 APIManager에서..
                return APIManager.repositoriesBy(githubID)
            }
            // Phase 4. 데이터 수신 완료 후 외형에 대한 처리
            .observeOn(MainScheduler.instance)
            .do(onNext: { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            })
            // UI 처리와 바인딩을 위하여 Driver로 반환
            .asDriver(onErrorJustReturn: []) // 에러시 빈 배열을 통지.
    }
}
