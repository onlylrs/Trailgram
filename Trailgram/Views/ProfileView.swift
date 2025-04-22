//
//  ProfileView.swift
//  Trailgram
//
//  Created by 刘闰生 on 4/20/25.
//

import SwiftUI

/// ProfileView shows the logged-in user's information and allows logout.
/// If not logged in, it shows the login/registration form.
struct ProfileView: View {
    @Bindable var userVM: UserViewModel
        @State private var name = ""
        @State private var email = ""
        @State private var password = ""
        @State private var isRegistering = false
    var body: some View {
        NavigationView {
            if let user = userVM.currentUser {
                VStack(spacing: 20) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(.blue)
                    Text(user.email ?? "").font(.subheadline)

                    HStack {
                        VStack {
                            Text("0").bold()
                            Text("Posts")
                        }
                        Spacer()
                        VStack {
                            Text("120").bold()
                            Text("Followers")
                        }
                        Spacer()
                        VStack {
                            Text("230").bold()
                            Text("Following")
                        }
                    }
                    .padding(.horizontal, 40)

                    Spacer()
                    Button("Sign Out") {
                        userVM.signOut()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .navigationTitle("Profile")
            } else {
                VStack(spacing: 16) {
                    TextField("Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)

                    Button(isRegistering ? "Register" : "Login") {
                        Task {
                            if isRegistering {
                                await userVM.signUp(with: email, password: password)
                            } else {
                                await userVM.signIn(with: email, password: password)
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    Button(isRegistering ? "Switch to Login" : "Switch to Register") {
                        isRegistering.toggle()
                    }
                    .font(.footnote)
                }
                .padding()
                .navigationTitle(isRegistering ? "Register" : "Login")
            }
        }
    }
}

//#Preview {
//    ProfileView()
//}
