//
//  FirebaseDatabase.swift
//  WellnessWave
//
//  Created by Ho sun Song on 2/5/24.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class FirebaseService {
    static let shared = FirebaseService() // Singleton instance
    private let databaseRef: DatabaseReference //reference to realtime database
    
    private init() {
        databaseRef = Database.database().reference()
    }
    
    //fetch user data from database
    func getUserData(userID: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        databaseRef.child("users").child(userID).observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data found for the user."])))
                return
            }
            completion(.success(value))
        }) { error in
            completion(.failure(error))
        }
    }
}
