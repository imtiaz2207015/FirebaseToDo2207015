
import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var user: User? = Auth.auth().currentUser
    @Published var errorMessage = ""

    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { r, e in
            DispatchQueue.main.async {
                if let e = e { self.errorMessage = e.localizedDescription }
                else { self.user = r?.user; self.errorMessage = "" }
            }
        }
    }

    func register(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { r, e in
            DispatchQueue.main.async {
                if let e = e { self.errorMessage = e.localizedDescription }
                else { self.user = r?.user; self.errorMessage = "" }
            }
        }
    }

    func logout() {
        try? Auth.auth().signOut()
        user = nil
    }
}
