import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var userManager = UserManager.shared
    
    // --- MODE STATE (Login vs Registration) ---
    @State private var isLoginMode = true
    
    // Field states
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    // Errors
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - 1. SFONDO (Dark Premium: Ciano -> Nero)
                // Identico alle altre schermate
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.cyan.opacity(0.7),    // Ciano luminoso in alto a sx
                        Color.black.opacity(0.85),  // Transizione scura al centro
                        Color.black                 // Nero profondo in basso a dx
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        
                        // Check if user is already logged in
                        if let user = userManager.currentUser {
                            LoggedInView(user: user)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else {
                            // --- NON-LOGGED IN USER FORM ---
                            
                            // 1. DYNAMIC HEADER
                            VStack(spacing: 15) {
                                Image(systemName: isLoginMode ? "person.circle.fill" : "person.badge.plus")
                                    .font(.system(size: 70))
                                    .foregroundStyle(
                                        LinearGradient(colors: [.cyan, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .padding(.top, 30)
                                    .shadow(color: .cyan.opacity(0.5), radius: 10, x: 0, y: 5)
                                    .contentTransition(.symbolEffect(.replace))
                                
                                Text(isLoginMode ? "Login" : "Create Account")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text(isLoginMode ? "Login to customize your app" : "Join SportHUB today")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            // 2. FORM CARD (Glass)
                            VStack(spacing: 25) {
                                
                                // LOGIN / SIGN UP SWITCH
                                Picker("Mode", selection: $isLoginMode) {
                                    Text("Log In").tag(true)
                                    Text("Sign Up").tag(false)
                                }
                                .pickerStyle(.segmented)
                                .padding(.bottom, 10)
                                // Colora il picker per sfondo scuro
                                .colorScheme(.dark)
                                
                                // TEXT FIELDS
                                VStack(spacing: 15) {
                                    
                                    // Name
                                    CustomTextField(
                                        icon: "person.fill",
                                        placeholder: isLoginMode ? "Name / Email" : "Name",
                                        text: $name
                                    )
                                    
                                    // Surname
                                    if !isLoginMode {
                                        CustomTextField(icon: "person", placeholder: "Surname", text: $surname)
                                            .transition(.move(edge: .top).combined(with: .opacity))
                                    }
                                    
                                    // Password
                                    CustomSecureField(icon: "lock.fill", placeholder: "Password", text: $password)
                                    
                                    // Confirm Password
                                    if !isLoginMode {
                                        CustomSecureField(icon: "lock.shield", placeholder: "Confirm Password", text: $confirmPassword)
                                            .transition(.move(edge: .top).combined(with: .opacity))
                                    }
                                }
                                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isLoginMode)
                                
                                // Error Message
                                if !errorMessage.isEmpty {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                        Text(errorMessage)
                                    }
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.top, 5)
                                    .transition(.opacity)
                                }
                                
                                // ACTION BUTTON
                                Button(action: performAuthAction) {
                                    Text(isLoginMode ? "Log In" : "Register")
                                        .font(.headline)
                                        .foregroundColor(.black) // Testo nero su bottone luminoso
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(LinearGradient(colors: [.cyan, .white], startPoint: .leading, endPoint: .trailing))
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        .shadow(color: .cyan.opacity(0.5), radius: 8, x: 0, y: 4)
                                }
                                .padding(.top, 5)
                            }
                            .padding(24)
                            // Sfondo VETRO SCURO (UltraThinMaterial)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 5)
                            .padding(.horizontal, 20)
                            
                            // 3. SOCIAL LOGIN
                            VStack(spacing: 20) {
                                HStack {
                                    Rectangle().frame(height: 1).foregroundColor(.white.opacity(0.2))
                                    Text("Or continue with")
                                        .font(.footnote)
                                        .foregroundColor(.white.opacity(0.6))
                                    Rectangle().frame(height: 1).foregroundColor(.white.opacity(0.2))
                                }
                                .padding(.horizontal, 40)
                                
                                HStack(spacing: 15) {
                                    SocialIconButton(icon: "apple.logo", bg: .white, fg: .black) {
                                        userManager.loginWithSocial(provider: "AppleUser")
                                    }
                                    
                                    SocialIconButton(icon: "envelope.fill", bg: .blue, fg: .white) {
                                        userManager.loginWithSocial(provider: "EmailUser")
                                    }
                                    
                                    SocialIconButton(icon: "g.circle.fill", bg: .red, fg: .white) {
                                        // Mock Google action
                                    }
                                }
                            }
                            .padding(.top, 10)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
        }
    }
    
    // --- AUTHENTICATION LOGIC ---
    func performAuthAction() {
        withAnimation {
            // Reset errors
            errorMessage = ""
            
            if isLoginMode {
                // LOGIN LOGIC
                guard !name.isEmpty, !password.isEmpty else {
                    errorMessage = "Please enter name and password."
                    return
                }
                // Simulate login (in mock app, just passing name is enough)
                userManager.login(name: name, surname: "") // Empty surname for quick login
                
            } else {
                // REGISTRATION LOGIC
                guard !name.isEmpty, !surname.isEmpty, !password.isEmpty else {
                    errorMessage = "Please fill in all fields."
                    return
                }
                
                guard password == confirmPassword else {
                    errorMessage = "Passwords do not match."
                    return
                }
                
                // Create new user
                userManager.login(name: name, surname: surname)
            }
        }
    }
}

// MARK: - LOGGED IN VIEW (USER CARD - DARK)
struct LoggedInView: View {
    let user: AppUser
    @ObservedObject var userManager = UserManager.shared
    
    var body: some View {
        VStack(spacing: 30) {
            
            // Avatar Card
            VStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(Color.cyan.opacity(0.2))
                        .frame(width: 140, height: 140)
                    
                    Image(systemName: user.avatar)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 70)
                        .foregroundColor(.cyan)
                }
                .overlay(Circle().stroke(Color.cyan.opacity(0.5), lineWidth: 1))
                .shadow(color: .cyan.opacity(0.3), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 5) {
                    Text(user.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("SportHUB Member")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
            )
            .padding(.horizontal, 20)
            .padding(.top, 40)
            
            // Logout
            Button(action: {
                withAnimation { userManager.logout() }
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Sign Out")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }
}

// MARK: - REUSABLE UI COMPONENTS (DARK MODE)

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.words)
                .foregroundColor(.white)
                // Placeholder color fix manually not easily possible without custom modifier,
                // but default gray on dark background is readable.
        }
        .padding()
        // Sfondo campo più scuro
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct CustomSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 24)
            
            SecureField(placeholder, text: $text)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// Round Social Buttons
struct SocialIconButton: View {
    let icon: String
    let bg: Color
    let fg: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(fg)
                .frame(width: 60, height: 60)
                .background(bg)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
}

#Preview {
    UserProfileView()
        .preferredColorScheme(.dark)
}
