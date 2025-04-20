//
//  SignupPage.swift
//  Trailgram
//
//  Created by 刘闰生 on 4/20/25.
//

import SwiftUI

struct SignupPage: View {
    @Environment(UserViewModel.self) var userViewModel
    @State var email = ""
    @State var password = ""
    var body: some View {
        VStack{
            TextField("Email", text: $email)
            .padding()
            TextField("Password", text: $password)
                .padding()
            Button("sign up"){
                Task{
                    await userViewModel.signUp(with: email, password: password)
                }
                
            }
            .padding()
        }
    }
}


#Preview {
    SignupPage()
}
