import SwiftUI

/// AuthView handles user login and registration.
/// It toggles between login and signup modes and calls appropriate Firebase Auth functions via UserViewModel.
struct AuthView: View {
    @Bindable var userVM: UserViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isRegistering = false

    var body: some View {
        VStack(spacing: 20) {
            Text(isRegistering ? "Create Account" : "Log In")
                .font(.title)
                .bold()

            if isRegistering {
                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)
            }

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)

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
            .frame(maxWidth: .infinity)

            Button(isRegistering ? "Already have an account? Log in" : "No account? Register now") {
                isRegistering.toggle()
            }
            .font(.footnote)
        }
        .padding()
        .frame(maxWidth: 400)
    }
}
