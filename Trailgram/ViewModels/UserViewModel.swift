import Foundation
import Observation
import FirebaseAuth

/// Manages Firebase Auth state and user login/signup/logout operations.
@Observable
class UserViewModel{
    var currentUser: User?
    
    /// Signs up a new user with email and password.
    /// - Parameters:
    ///   - email: The user's email.
    ///   - password: The user's chosen password.
    func signUp(with email: String, password: String) async {
        do{
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            currentUser = result.user
        }catch{
            print(error)
        }
    }
    
    /// Signs in an existing user.
    /// - Parameters:
    ///   - email: The user's email.
    ///   - password: The user's password.
    func signIn(with email: String, password: String) async {
        do{
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            currentUser = result.user
        }catch{
            print(error)
        }
    }
    
    /// Signs out an existing user.
    func signOut(){
        do{
            try Auth.auth().signOut()
        }catch{
            print(error)
        }
        currentUser = nil
    }
}
