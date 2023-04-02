import Firebase
import FirebaseFirestore
import FirebaseAuth

class FirebaseAgent {
    
    static var shared = FirebaseAgent()
    init() {
        
    }
    
    var db: Firestore {
        return Firestore.firestore()
    }
    
    var auth: Auth {
        return Auth.auth()
    }
    
    var app: FirebaseApp {
        return FirebaseApp.app()!
    }
    
    func configure() {
        FirebaseApp.configure()
        Firestore.firestore().settings = FirestoreSettings()
        ApplicationManager.debugMessage(status: 2, with: "Configured Firebase resources.")
    }
    

}
