//
//  SaveConfirmation.swift
//  Forget Me Not
//
//  Created by Zara on 2025-05-02.
//

import Foundation
import SwiftUICore
import SwiftUI

struct SaveConfirmation: View{
    var body: some View{
        VStack {
            Text("Information saved!")
                .font(.system(size: 40, weight: .bold))
                .padding(.bottom, 10)
            NavigationLink(destination: ListView()) {
                Text("Return")
            }
        }
        .padding()
        
    }
}

struct SaveConfirmation_Previews: PreviewProvider{
    static var previews: some View{
        SaveConfirmation()
    }
}
