import SwiftUI
import Combine

struct AppUser: Codable {
    var name: String
    var surname: String // <-- NEW FIELD
    var avatar: String = "person.crop.circle.fill"
    
    // Computed property to get the full name
    var fullName: String {
        return "\(name) \(surname)"
    }
}

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var currentUser: AppUser? {
        didSet {
            saveUser()
        }
    }
    
    var isLoggedIn: Bool {
        return currentUser != nil
    }
    
    init() {
        loadUser()
    }
    
    // --- UPDATED ACTIONS ---
    
    // Now requesting Name and Surname
    func login(name: String, surname: String) {
        self.currentUser = AppUser(name: name, surname: surname)
    }
    
    // Simulated function for Social Login
    func loginWithSocial(provider: String) {
        // Simulate a dummy user when clicking on Apple or Email
        self.currentUser = AppUser(name: "User", surname: provider)
    }

    func logout() {
        self.currentUser = nil
        
        // When logging out, reset favorites in the places database
        Task { @MainActor in
            SportsDataService.shared.resetAllFavorites()
        }
    }
    
    // --- PERSISTENCE ---
    
    private func saveUser() {
        if let encoded = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(encoded, forKey: "SavedUser")
        } else {
            UserDefaults.standard.removeObject(forKey: "SavedUser")
        }
    }
    
    private func loadUser() {
        if let data = UserDefaults.standard.data(forKey: "SavedUser"),
           let decoded = try? JSONDecoder().decode(AppUser.self, from: data) {
            self.currentUser = decoded
        }
    }
}
