//
//  NewDogView.swift
//  Forget Me Not
//
//  Created by Zara on 2025-05-02.
//

import Foundation
import SwiftUICore
import SwiftUI

import SwiftUI

struct NewDogView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var clientName = ""
    @State private var clientAddress = ""
    @State private var clientMedInfo = ""
    @State private var clientPhoneNumber = ""
    
    @State private var showAlert = false

    var allFieldsFilled: Bool {
        !clientName.isEmpty &&
        !clientAddress.isEmpty &&
        !clientMedInfo.isEmpty &&
        !clientPhoneNumber.isEmpty
    }

    var body: some View {
        VStack {
            TextField("Full Name", text: $clientName)
            TextField("Address", text: $clientAddress)
            TextField("Medical Information", text: $clientMedInfo)
            TextField("Phone Number", text: $clientPhoneNumber)

            Button("Save") {
                dataManager.addClient(
                    fullName: clientName,
                    address: clientAddress,
                    medInfo: clientMedInfo,
                    phoneNumber: clientPhoneNumber
                )
                showAlert = true
            }
            .disabled(!allFieldsFilled)
        }
        .padding()
        .navigationTitle("Add New Client") // Title still works inside a NavigationStack
        .alert("Saved!", isPresented: $showAlert) {
            Button("OK") {
                dismiss()
            }
        }
    }
}



struct NewDogView_Previews: PreviewProvider{
    static var previews: some View{
        NewDogView()
    }
}
