//
//  AuthenticationAgent.swift
//  TeeVee
//
//  Created by Iyinoluwa Tugbobo on 4/2/23.
//
import FirebaseAuth
import GoogleSignIn

class AuthenticationAgent {
    
    let auth = FirebaseAgent.shared.auth
    let app = FirebaseAgent.shared.app
    
    func checkIfFirebaseUserExists(email: String, completion: @escaping (Bool) -> Void) {
        auth.fetchSignInMethods(forEmail: email) { (methods, error) in
            if let error = error {
                ApplicationManager.debugMessage(status: 1, with: error.localizedDescription)
                completion(false)
            } else {
                let isFirebaseEmail = methods?.contains("password") ?? false
                ApplicationManager.debugMessage(status: 2, with: "Firebase email check -> \(isFirebaseEmail)")
                completion(isFirebaseEmail)
            }
        }
    }
        
    func createFirebaseUser(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
            auth.createUser(withEmail: email, password: password) { (authResult, error) in
                guard error != nil else {
                    ApplicationManager.debugMessage(status: 1, with: error!.localizedDescription)
                    return
                }
                ApplicationManager.debugMessage(status: 0, with: "Successfully created new Firebase user \(email).")
                completion(authResult, error)
            }
    }
        
    func signInWithFirebase(email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let authResult = authResult else {
                let error = NSError(domain: "com.example.app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected error: authResult is nil"])
                completion(.failure(error))
                return
            }
            completion(.success(authResult))
        }
    }
        
    func signUpWithFirebase(email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let authResult = authResult else {
                let error = NSError(domain: "com.example.app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected error: authResult is nil"])
                completion(.failure(error))
                return
            }
            completion(.success(authResult))
        }
    }

    func continueWithGoogle(from viewController: UIViewController, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        let provider = OAuthProvider(providerID: "google.com")
        provider.getCredentialWith(nil) { credential, error in
            if let error = error {
                ApplicationManager.debugMessage(status: 1, with: error.localizedDescription)
                completion(.failure(error))
                return
            }

            guard let credential = credential else {
                completion(.failure(error!))
                return
            }

            self.auth.signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let authResult = authResult else {
                    completion(.failure(error!))
                    return
                }

                completion(.success(authResult))
            }
        }
    }
}
