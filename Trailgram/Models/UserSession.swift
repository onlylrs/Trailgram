//
//  UserSession.swift
//  Trailgram
//
//  Created by 刘闰生 on 4/20/25.
//

import Foundation
import Observation

/// Holds a reactive user session (auth state) that can be observed across the app.
/// Internally delegates to UserViewModel.
@Observable
class UserSession {
    var userVM = UserViewModel()
}
