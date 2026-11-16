
import SwiftUI
import FirebaseCore

@main
struct FirebaseToDo2207015App: App {
    @StateObject var auth = AuthViewModel()
    
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(auth)
        }
    }
}
