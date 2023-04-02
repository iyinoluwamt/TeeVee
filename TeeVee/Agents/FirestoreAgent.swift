import Firebase
import FirebaseFirestore

class FirestoreAgent {
    
    var db = FirebaseAgent.shared.db
    
    func collection(_ collectionPath: String) -> CollectionReference {
        return db.collection(collectionPath)
    }
    
    func batch() -> WriteBatch {
        return db.batch()
    }
    
    // Upload image data to Firebase storage with completion block to handle response
    func uploadImageToFirebaseStorage(imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        // TODO: Implement Firebase Storage upload code here
    }
    
    // Fetch data from a Firestore collection with completion block to handle response
    func fetchDataFromFirestoreCollection(collection: String, completion: @escaping (Result<[QueryDocumentSnapshot], Error>) -> Void) {
        db.collection(collection).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let snapshot = snapshot {
                completion(.success(snapshot.documents))
            }
        }
    }
    
    // Fetch data from a Firestore document with completion block to handle response
    func fetchDataFromFirestoreDocument(document: String, completion: @escaping (Result<DocumentSnapshot, Error>) -> Void) {
        db.document(document).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let snapshot = snapshot {
                completion(.success(snapshot))
            }
        }
    }
    
    func addNewShowsToDatabase(shows: [Show], completion: @escaping (Result<Void, Error>) -> Void) {
        let activityRef = db.collection("activity")
        let showIds = shows.map { $0.id }

        let chunkSize = 10
        let chunks = stride(from: 0, to: showIds.count, by: chunkSize).map {
            Array(showIds[$0..<min($0 + chunkSize, showIds.count)])
        }

        for chunk in chunks {
            activityRef.whereField(FieldPath.documentID(), in: chunk.map { String($0) }).getDocuments { (querySnapshot, error) in
                guard error == nil else {
                    completion(.failure(error!))
                    return
                }

                for showId in chunk {
                    if !querySnapshot!.documents.contains(where: { $0.documentID == String(showId) }) {
                        activityRef.document("\(showId)").setData([
                            "likes": 0,
                            "views": 0
                        ]) { err in
                            guard err == nil else {
                                completion(.failure(err!))
                                return
                            }
                        }
                    }
                }
                completion(.success(()))
            }
        }
    }    
}
