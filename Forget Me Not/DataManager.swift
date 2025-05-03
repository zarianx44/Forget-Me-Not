//
//  DataManager.swift
//  Forget Me Not
//
//  Created by Zara on 2025-05-02.
//

import Foundation
import Firebase

class DataManager: ObservableObject{
    @Published var info: [ClientInfo] = []
    
    init(){
        fetchInfo()
        print("Loaded \(self.info.count) clients.")
    }
    
    func fetchInfo(){
        info.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Client Info")
        
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    
                    let data = document.data()
                    
                    let address = data["address"] as? String ?? ""
                    let fullName = data["fullName"] as? String ?? ""
                    let medInfo = data["medInfo"] as? String ?? ""
                    let phoneNumber = data["phoneNumber"] as? String ?? ""
                    let id = document.documentID // <-- use Firestore doc ID
                    
                    let cInfo = ClientInfo(fullName: fullName, medInfo: medInfo, phoneNumber: phoneNumber, address: address, id: id)
                    self.info.append(cInfo)
                }
            }
        }
    }
    
    func addClient(fullName: String, address: String, medInfo: String, phoneNumber: String) {
        let db = Firestore.firestore()
        let newDoc = db.collection("Client Info").document() // auto-generated unique ID
        
        let data: [String: Any] = [
            "fullName": fullName,
            "address": address,
            "medInfo": medInfo,
            "phoneNumber": phoneNumber
        ]
        
        newDoc.setData(data) { error in
            if let error = error {
                print("Error adding client: \(error.localizedDescription)")
            } else {
                print("Client added with ID: \(newDoc.documentID)")
            }
        }
    }

}
