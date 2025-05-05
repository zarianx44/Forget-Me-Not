//
//  File.swift
//  Forget Me Not
//
//  Created by Zara on 2025-05-01.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    @State private var userIsLoggedIn = false
    @State private var isCheckingAuth = true

    @State private var isLoginMode = false
    
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        if userIsLoggedIn{
            ContentView()
        } else{
            content
        }
    }
    
    var content: some View{
        ZStack{
            Color.white
            RoundedRectangle(cornerRadius:30, style: .continuous)
                .foregroundStyle(.linearGradient(colors: [.indigo, .teal], startPoint: .topLeading , endPoint: .bottomTrailing))
                .frame(width:1000, height:400)
                .rotationEffect(.degrees(0))
                .offset(y: -350)
            
            VStack(spacing:20){
                Text("Welcome to")
                    .foregroundColor(.white)
                    .font(.system(size: 45))
                    .offset(x:-0, y: -100)
                Text("RememberMe")
                    .foregroundColor(.white)
                    .font(.system(size: 54, weight: .bold))
                    .offset(x:-0, y: -115)
                
                TextField("Email", text: $email)
                    .foregroundColor(.black)
                    .textFieldStyle(.plain)
                    .placeholder(when: email.isEmpty){
                        Text("Email")
                            .foregroundColor(.black)
                            .bold()
                            .font(.system(size: 22))
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                
                SecureField("Password", text: $password)
                    .foregroundColor(.black)
                    .textFieldStyle(.plain)
                    .placeholder(when: password.isEmpty){
                        Text("Password")
                            .foregroundColor(.black)
                            .bold()
                            .font(.system(size: 22))
                    }
                
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .padding(.bottom, 20)
                
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
                                .fill(.linearGradient(colors: [.teal, .blue], startPoint: .top , endPoint: .bottomTrailing))
                        )
                }

                .padding(.top)
                .offset(y:100)
                
                Button {
                    isLoginMode.toggle()
                } label: {
                    Text(isLoginMode ? "Don't have an account? Sign up here" : "Already have an account? Login here")
                        .bold()
                        .underline()
                }
                .padding(.top)
                .offset(y:100)
                
                
                
            }
            .frame(width: 350)
            .onAppear {
                Auth.auth().addStateDidChangeListener { auth, user in
                    if user != nil {
                        userIsLoggedIn = true
                    }
                }
            }

        }
    }
    func register(){
        Auth.auth().createUser(withEmail: email, password: password) { result, error in if error != nil{
            print(error!.localizedDescription)
        }
        }
    }
    

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
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
