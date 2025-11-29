//
//  AuthView.swift
//  onthisday
//
//  Created by Kevin Rapkin on 11/28/25.
//


import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var isLoginMode: Bool = true
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("On this day")
                    .font(.largeTitle.weight(.bold))

                Picker("", selection: $isLoginMode) {
                    Text("Login").tag(true)
                    Text("Sign Up").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                if let error = authViewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button(action: submit) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(isLoginMode ? "Log In" : "Sign Up")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.accentColor)
                .cornerRadius(10)
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 40)
        }
    }

    private func submit() {
        guard !email.isEmpty, !password.isEmpty else { return }
        if isLoginMode {
            authViewModel.signIn(email: email, password: password)
        } else {
            authViewModel.signUp(email: email, password: password)
        }
    }
}