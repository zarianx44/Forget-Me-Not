//
//  ListView.swift
//  Forget Me Not
//
//  Created by Zara on 2025-05-02.
//

import SwiftUI

import SwiftUI

struct ListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showPopup = false
    @Environment(\.dismiss) var dismiss // Access to the dismiss action
    
    var body: some View {
        NavigationView {
            List(dataManager.info, id: \.id) { info in
                Text(info.fullName)
            }
            .navigationTitle("Client Info")
            .navigationBarItems(trailing: Button(action: {
                showPopup.toggle()
            }, label: {
                Image(systemName: "plus")
            }))
            .sheet(isPresented: $showPopup, onDismiss: {
                // Reset state if necessary
            }) {
                NewDogView() // Sheet content
                    .onDisappear {
                        // Ensure state is reset on disappearance
                        showPopup = false
                    }
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
            .environmentObject(DataManager())
    }
}
