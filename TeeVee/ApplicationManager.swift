//
//  ApplicationManager.swift
//  TeeVee
//
//  Created by Iyinoluwa Tugbobo on 4/2/23.
//

import FirebaseFirestore
import FirebaseAuth
import UIKit

struct Agents {
    var firebase: FirebaseAgent
    var firestore: FirestoreAgent
    var network: NetworkAgent
    var auth: AuthenticationAgent
}


class ApplicationManager {
    
    static let shared = ApplicationManager()
    var agents: Agents?
    private init() {
        agents = Agents(
            firebase: FirebaseAgent.shared,
            firestore: FirestoreAgent(),
            network: NetworkAgent(),
            auth: AuthenticationAgent()
        )
    }
    
    //    private let networkManager = NetworkManager.shared
    //    private let authManager = AuthManager.shared
    //    private let navigationManager = NavigationManager.shared
    
    //    var authListenerHandle: AuthStateDidChangeListenerHandle?
    
    // 0: for error,
    // 1: success
    // 2: message
    // 3: user-related-a
    static func debugMessage(status: Int, with: String) {
        switch status {
        case 0: print("✅ \(with)")
        case 1: print("❌ \(with)")
        case 2: print("💬 \(with)")
        case 3: print("👤 \(with)")
        default: print("🔸 \(with)")
        }
    }
    
    func handleResult<T>(_ result: Result<T, Error>, completion: @escaping (Result<T, Error>) -> Void) {
        switch result {
        case .success(let data):
            completion(.success(data))
        case .failure(let error):
            ApplicationManager.debugMessage(status: 1, with: error.localizedDescription)
            completion(.failure(error))
        }
    }

    func fetchDataFromFirestoreCollection(collection: String, completion: @escaping (Result<[QueryDocumentSnapshot], Error>) -> Void) {
        agents?.firestore.fetchDataFromFirestoreCollection(collection: collection) { result in
            self.handleResult(result, completion: completion)
        }
    }

    func addNewShowsToDatabase(shows: [Show], completion: @escaping (Result<Void, Error>) -> Void) {
        agents?.firestore.addNewShowsToDatabase(shows: shows) { result in
            self.handleResult(result, completion: completion)
        }
    }

    func getShowsFromAPI(endpoints: [String], completion: @escaping ([String: [Show]]) -> Void) {
        agents?.network.getShowsFromAPI(endpoints: endpoints) { result in
            completion(result)
        }
    }

    func signInWithGoogle(from viewController: UIViewController, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        agents?.auth.continueWithGoogle(from: viewController) { result in
            self.handleResult(result, completion: completion)
        }
    }

    func signInWithFirebase(email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        agents?.auth.signInWithFirebase(email: email, password: password) { result in
            self.handleResult(result, completion: completion)
        }
    }

    func signUpWithFirebase(email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        agents?.auth.signUpWithFirebase(email: email, password: password) { result in
            self.handleResult(result, completion: completion)
        }
    }



}
