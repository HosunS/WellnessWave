//
//  FirebaseDatabase.swift
//  WellnessWave
//
//  Created by Ho sun Song on 2/5/24.
//

import Foundation
import FirebaseDatabase

class FirebaseService {
    static let shared = FirebaseService() // Singleton instance
    private let databaseRef: DatabaseReference

    private init() {
        databaseRef = Database.database().reference()
    }

    func getUserData(userId: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        databaseRef.child("users").child(userId).observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data found."])))
                return
            }
            completion(.success(value))
        }) { error in
            completion(.failure(error))
        }
    }

    // Add more methods for interacting with the database here
}
