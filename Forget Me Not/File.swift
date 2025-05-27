//
//  LoginView.swift
//  Forget Me Not
//
//  Created by Zara on 2025-05-01.
//

import SwiftUI
import Firebase
import FirebaseAuth
import Combine

struct LoginView: View {
    @ObservedObject private var keyboard = KeyboardResponder()

    @State private var showAlert = false
    @State private var errorMessage = ""

    @State private var userIsLoggedIn = false
    @State private var isCheckingAuth = true

    @State private var isLoginMode = false

    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        if userIsLoggedIn {
            ContentView()
        } else {
            content
        }
    }

    var content: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .foregroundStyle(.linearGradient(colors: [.indigo, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 1000, height: 400)
                .offset(y: -350)

            ScrollView {
                VStack(spacing: 20) {
                    Text("Welcome to")
                        .foregroundColor(.white)
                        .font(.system(size: 45))
                        .offset(y: 60)

                    Text("RememberMe")
                        .foregroundColor(.white)
                        .font(.system(size: 54, weight: .bold))
                        .offset(y: 30)

                    TextField("Email", text: $email)
                        .foregroundColor(.black)
                        .textFieldStyle(.plain)
                        .padding(.top, 150)
                        .placeholder(when: email.isEmpty) {
                            Text("Email")
                                .padding(.top, 150)
                                .foregroundColor(.black)
                                .bold()
                                .font(.system(size: 22))
                        }

                    Rectangle()
                        .frame(width: 350, height: 1)

                    SecureField("Password", text: $password)
                        .foregroundColor(.black)
                        .textFieldStyle(.plain)
                        .placeholder(when: password.isEmpty) {
                            Text("Password")
                                .foregroundColor(.black)
                                .bold()
                                .font(.system(size: 22))
                        }

                    Rectangle()
                        .frame(width: 350, height: 1)
                        .padding(.bottom, 20)

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
                                .padding(.top, -10)
                        }
                    }

                    Button {
                        if isLoginMode {
                            login()
                        } else {
                            register()
                        }
                    } label: {
                        Text(isLoginMode ? "Login" : "Sign Up")
                            .bold()
                            .frame(width: 250, height: 60)
                            .foregroundColor(.white)
                            .font(.system(size: 25))
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.linearGradient(colors: [.teal, .blue], startPoint: .top, endPoint: .bottomTrailing))
                            )
                    }
                    
                    
                    .padding(.top)
                    .offset(y: 100)
                    
//                    if !isLoginMode {
//                        Button("Resend Verification Email") {
//                            if let user = Auth.auth().currentUser, !user.isEmailVerified {
//                                user.sendEmailVerification { error in
//                                    if let error = error {
//                                        errorMessage = error.localizedDescription
//                                    } else {
//                                        errorMessage = "Verification email resent."
//                                    }
//                                    showAlert = true
//                                }
//                            } else {
//                                errorMessage = "Please register or log in first."
//                                showAlert = true
//                            }
//                        }
//                        .foregroundColor(.blue)
//                        .underline()
//                        .font(.system(size: 16))
//                    }

                    Button {
                        isLoginMode.toggle()
                    } label: {
                        Text(isLoginMode ? "Don't have an account? Sign up here" : "Already have an account? Login here")
                            .bold()
                            .underline()
                            .font(.system(size: 17, weight: .medium))
                    }
                    .padding(.top)
                    .offset(y: 100)
                }
                .frame(width: 350)
                .padding(.bottom, keyboard.keyboardHeight)
                .animation(.easeOut(duration: 0.25), value: keyboard.keyboardHeight)
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                Auth.auth().addStateDidChangeListener { auth, user in
                    if user != nil {
                        userIsLoggedIn = true
                    }
                }
            }
        }
    }

    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
            } else if let user = result?.user {
                user.sendEmailVerification { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                    } else {
                        errorMessage = "Verification email sent. Please check your inbox."
                    }
                    showAlert = true
                }
            }
        }
    }


    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
            } else if let user = Auth.auth().currentUser, !user.isEmailVerified {
                errorMessage = "Email not verified. Please check your inbox."
                showAlert = true
                try? Auth.auth().signOut() // log them out
            } else {
                isLoggedIn = true
            }
        }
    }

}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    LoginView()
}
