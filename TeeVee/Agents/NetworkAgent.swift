// Import necessary frameworks
import Foundation
import Alamofire
import FirebaseFirestore
import FirebaseAuth
import UIKit

// Define a singleton NetworkManager class
class NetworkAgent {
    
    // Initialize private API key and Firebase/Firestore instance variables
    let baseURL = "https://api.themoviedb.org/3/tv/"
    private let key: String = "32d3d96bbd7c27a2ebe60ebeb83393c9"
    var page: Int = 1
    
    let db = FirebaseAgent.shared.db
    
    // Fetch data from API with completion block to handle response
    func fetchDataFromAPI(url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

        
    func getShowsFromAPI(endpoints: [String], completion: @escaping ([String: [Show]]) -> Void) {
        var results = [String: [Show]]()
        let dispatchGroup = DispatchGroup()
        
        for endpoint in endpoints {
            dispatchGroup.enter()
            AF.request("\(baseURL)/\(endpoint)", method: .get, parameters: [
                "api_key": key,
                "page": page,
                "sort_by": "popularity.desc",
                "with_origin_country": "US"
            ]).responseDecodable(of: TMDBResponse.self) { response in
                switch response.result {
                case .success(let response):
                    let shows = response.results
//                    ApplicationManager.shared.addNewShowsToDatabase(shows: shows, completion: ApplicationManager.shared.han)
                    results[endpoint] = shows
                case .failure(let error):
                    print(error.localizedDescription)
                    results[endpoint] = []
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(results)
        }
    }
}
