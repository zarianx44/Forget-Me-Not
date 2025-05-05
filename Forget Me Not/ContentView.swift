


import SwiftUI
import SwiftData
import Firebase
import FirebaseAuth

struct ContentView: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Button("Log Out") {
                    do {
                        try Auth.auth().signOut()
                        isLoggedIn = false
                        LoginView()
                    } catch {
                        print("Error logging out: \(error.localizedDescription)")
                    }
                }

                Spacer()
                Text("Who are you?")
                    .font(.system(size: 40, weight: .bold))
                    .padding(.bottom, 10)
                LazyVGrid(columns: columns, spacing: 20) {
                    NavigationLink(destination: LoginView()) {
                        VStack {
                            Image("caregiver")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 130, height: 120)
                            Text("Caregiver")
                                .font(.system(size: 25, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    NavigationLink(destination: MenuView()) {
                        VStack {
                            Image("client")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 130, height: 120)
                            Text("Client")
                                .font(.system(size: 25, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 40)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
    }
}
struct ContentView_Previews: PreviewProvider{
    static var previews: some View{
        ContentView()
    }
}
#Preview {
    ContentView()
}
