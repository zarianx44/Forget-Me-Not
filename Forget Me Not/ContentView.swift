import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

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
                        isLoggedIn = false // triggers AppRootView to show LoginView
                    } catch {
                        print("Error logging out: \(error.localizedDescription)")
                    }
                }
                .foregroundColor(.red)
                .padding()

                Spacer()
                Text("Who are you?")
                    .font(.system(size: 40, weight: .bold))
                    .padding(.bottom, 10)

                LazyVGrid(columns: columns, spacing: 20) {
                    // CAREGIVER
                    NavigationLink(destination: CareView()) {
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
                    .simultaneousGesture(TapGesture().onEnded {
                        setUserRole(role: "caregiver")
                    })

                    // CLIENT
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
                    .simultaneousGesture(TapGesture().onEnded {
                        setUserRole(role: "client")
                    })
                }
                .padding(.horizontal, 40)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
    }

    func setUserRole(role: String) {
        guard let user = Auth.auth().currentUser else {
            print("❌ Not signed in")
            return
        }

        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(user.uid)

        userDocRef.setData([
            "role": role,
            "uid": user.uid,
            "createdAt": FieldValue.serverTimestamp()
        ], merge: true) { error in
            if let error = error {
                print("❌ Error saving role: \(error.localizedDescription)")
            } else {
                print("✅ Role '\(role)' saved successfully!")
            }
        }
    }
}
