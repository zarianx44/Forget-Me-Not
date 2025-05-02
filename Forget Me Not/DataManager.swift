//
//  DataManager.swift
//  Forget Me Not
//
//  Created by Zara on 2025-05-02.
//

import Foundation
import Firebase

class Datamanager: ObservableObject{
    @Published var dogs: [Dog] = []
    
    func fetchDogs(){
        dogs.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Dogs") //collection name in firestone db
        ref.getDocuments{ snapshop, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            
        }
    }
}
