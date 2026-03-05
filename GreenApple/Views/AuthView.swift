//
//  AuthView.swift
//  GreenApple
//
//  Created by Can Arda on 04.03.26.
//

import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var username = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    
                    // Logo
                    VStack(spacing: 12) {
                        Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .font(.system(size: 60))
                            .foregroundColor(Color("AppGreen"))
                        
                        Text("GreenApple")
                            .font(.system(size: 32, weight: .bold))
                        
                        Text(isLogin ? "Welcome back! 👋" : "Create your account")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Toggle
                    HStack(spacing: 0) {
                        Button {
                            withAnimation(.spring(response: 0.3)) { isLogin = true }
                        } label: {
                            Text("Sign In")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(isLogin ? .white : .secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(isLogin ? Color("AppGreen") : Color.clear)
                                .clipShape(Capsule())
                        }
                        
                        Button {
                            withAnimation(.spring(response: 0.3)) { isLogin = false }
                        } label: {
                            Text("Sign Up")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(!isLogin ? .white : .secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(!isLogin ? Color("AppGreen") : Color.clear)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(4)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                    .padding(.horizontal, 20)
                    
                    // Fields
                    VStack(spacing: 16) {
                        if !isLogin {
                            AuthField(icon: "person.fill", placeholder: "Full Name", text: $name)
                            AuthField(icon: "at", placeholder: "Username", text: $username)
                                .autocapitalization(.none)
                        }
                        
                        AuthField(icon: "envelope.fill", placeholder: "Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        AuthField(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                    }
                    .padding(.horizontal, 20)
                    
                    // Error
                    if showError {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.horizontal, 20)
                    }
                    
                    // Button
                    Button {
                        isLogin ? signIn() : signUp()
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(isLogin ? "Sign In" : "Create Account")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isFormValid ? Color("AppGreen") : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(!isFormValid || isLoading)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
        }
    }
    
    private var isFormValid: Bool {
        if isLogin {
            return !email.isEmpty && !password.isEmpty
        } else {
            return !email.isEmpty && !password.isEmpty && !username.isEmpty && !name.isEmpty
        }
    }
    
    private func signIn() {
        isLoading = true
        showError = false
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else if let user = result?.user {
                viewModel.currentUser = user
                viewModel.fetchUsername(uid: user.uid)
                viewModel.isLoggedIn = true
            }
        }
    }
    
    private func signUp() {
        isLoading = true
        showError = false
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else if let user = result?.user {
                viewModel.saveUsername(uid: user.uid, username: username)
                viewModel.currentUser = user
                viewModel.isLoggedIn = true
            }
        }
    }
}

// MARK: - Auth Field
struct AuthField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color("AppGreen"))
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 15))
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 15))
                    .autocorrectionDisabled()
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    AuthView()
        .environmentObject(AppViewModel())
}
