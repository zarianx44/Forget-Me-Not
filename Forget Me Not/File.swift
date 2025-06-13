import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    @State private var showAlert = false
    @State private var errorMessage = ""
    
    @State private var isLoginMode = false

    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        loginScreen
    }

    var loginScreen: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Top gradient header stays fixed
                RoundedRectangle(cornerRadius: 30)
                    .foregroundStyle(.linearGradient(colors: [.indigo, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 300)
                    .ignoresSafeArea(edges: .top)

                Spacer()
            }

            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("Welcome to")
                        .foregroundColor(.white)
                        .font(.system(size: 36, weight: .semibold))

                    Text("RememberMe")
                        .foregroundColor(.white)
                        .font(.system(size: 48, weight: .bold))
                }
                .padding(.top, 60)

                ScrollView {
                    VStack(spacing: 20) {
                        // Email Field
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                            .shadow(radius: 2)


                        // Password Field
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                            .shadow(radius: 2)


                        // Forgot Password
                        if isLoginMode {
                            Button(action: {
                                if email.isEmpty {
                                    errorMessage = "Please enter your email to reset password."
                                    showAlert = true
                                    return
                                }
                                Auth.auth().sendPasswordReset(withEmail: email) { error in
                                    if let error = error {
                                        errorMessage = error.localizedDescription
                                    } else {
                                        errorMessage = "Password reset email sent!"
                                    }
                                    showAlert = true
                                }
                            }) {
                                Text("Forgot Password?")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.blue)
                                    .underline()
                            }
                        }

                        // Login / Sign Up Button
                        Button {
                            isLoginMode ? login() : register()
                        } label: {
                            Text(isLoginMode ? "Login" : "Sign Up")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .foregroundColor(.white)
                                .font(.system(size: 22))
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.linearGradient(colors: [.teal, .blue], startPoint: .top, endPoint: .bottomTrailing))
                                )
                        }

                        // Toggle login/signup
                        Button {
                            isLoginMode.toggle()
                        } label: {
                            Text(isLoginMode ? "Don't have an account? Sign up here" : "Already have an account? Login here")
                                .bold()
                                .underline()
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .padding(.top, 40)
                }
                .onTapGesture {
                    hideKeyboard()
                }

                Spacer()
            }
            .padding(.top, 20)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Notice"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            Auth.auth().addStateDidChangeListener { _, user in
                if user != nil {
                  
                }
            }
        }
    }

    func register() {
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please enter both email and password."
            showAlert = true
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
            } else {
                isLoggedIn = true
            }
        }
    }


    func login() {
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please enter both email and password."
            showAlert = true
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
            } else {
                isLoggedIn = true
            }
        }
    }


    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
