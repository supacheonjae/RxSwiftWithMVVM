import Foundation
import RxSwift
import RxAlamofire
import ObjectMapper

class APIManager {
    
    static func repositoriesBy(_ githubID: String) -> Observable<[Repository]> {
        
        
        guard !githubID.isEmpty,
            let url = URL(string: "https://api.github.com/users/\(githubID)/repos") else {
                return Observable.just([])
        }
        
        return RxAlamofire.requestJSON(.get, url)
            .debug()
            .catchError{ error in
                // 에러시 처리를 멈춤
                return Observable.never()
            }
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map { (response, json) -> [Repository] in
                if let repos = Mapper<Repository>().mapArray(JSONObject: json) {
                    return repos
                } else {
                    return []
                }
            }
    }
    
}
