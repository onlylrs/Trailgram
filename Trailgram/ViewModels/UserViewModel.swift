import Foundation
import Observation
import FirebaseAuth

@Observable
class UserViewModel{
    var currentUser: User?
    
    func signUp(with email: String, password: String) async {
        do{
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            currentUser = result.user
        }catch{
            print(error)
        }
    }
    
    func signIn(with email: String, password: String) async {
        do{
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            currentUser = result.user
        }catch{
            print(error)
        }
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
        }catch{
            print(error)
        }
        currentUser = nil
    }
}
