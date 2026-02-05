import SwiftUI

struct AddReview: View {
    @Environment(\.dismiss) var dismiss
    @Binding var place: SHPOIPlace
    
    // 1. Observe UserManager
    @ObservedObject var userManager = UserManager.shared
    
    @State private var tempComment: String = ""
    @State private var tempRating: Int = 0
    
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
                        
                        // MARK: - 1. PLACE INFO (Context Card - Glass)
                        HStack(spacing: 15) {
                            // Round image
                            Image(place.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Reviewing")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7)) // Grigio chiaro su scuro
                                    .textCase(.uppercase)
                                
                                Text(place.name)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white) // Bianco
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                        // Sfondo VETRO SCURO (UltraThinMaterial)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        
                        // MARK: - 2. RATING (Stars)
                        VStack(spacing: 15) {
                            Text("Rate your experience")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                            
                            HStack(spacing: 12) {
                                ForEach(1...5, id: \.self) { index in
                                    Image(systemName: index <= tempRating ? "star.fill" : "star")
                                        .font(.system(size: 35, weight: .bold))
                                        .foregroundColor(index <= tempRating ? .yellow : .white.opacity(0.2)) // Stelle inattive bianche traslucide
                                        .scaleEffect(index == tempRating ? 1.2 : 1.0)
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                                tempRating = index
                                            }
                                        }
                                }
                            }
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        
                        // MARK: - 3. COMMENT
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Write a review")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.leading, 4)
                            
                            ZStack(alignment: .topLeading) {
                                // Custom placeholder
                                if tempComment.isEmpty {
                                    Text("Tell us about the facilities, atmosphere, etc...")
                                        .foregroundColor(.white.opacity(0.4))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                }
                                
                                TextEditor(text: $tempComment)
                                    .scrollContentBackground(.hidden) // Rimuove sfondo di default
                                    .foregroundColor(.white) // Testo bianco mentre scrivi
                                    .padding(8)
                                    .frame(height: 150)
                            }
                            // Sfondo leggermente più scuro per l'input
                            .background(Color.black.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                            )
                        }
                        .padding(16)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        
                        Spacer(minLength: 20)
                        
                        // MARK: - 4. SEND BUTTON (DetailView Style)
                        Button(action: submitReview) {
                            Text("Send Review")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    isDisabled
                                    ? LinearGradient(colors: [.gray.opacity(0.5), .gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: isDisabled ? .clear : .cyan.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .disabled(isDisabled)
                        .padding(.bottom, 20)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("New Review")
            .navigationBarTitleDisplayMode(.inline)
            // Forza navbar scura
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white) // Tasto Cancel bianco
                }
            }
        }
    }
    
    // Computed property to validate the form
    var isDisabled: Bool {
        return tempRating == 0 || tempComment.count < 5
    }
    
    // Submit action
    func submitReview() {
        // Retrieve the name
        let authorName = userManager.currentUser?.fullName ?? "You"
        
        // Save the review
        withAnimation {
            place.myReview = UserReview(
                author: authorName,
                comment: tempComment,
                score: tempRating
            )
        }
        
        dismiss()
    }
}

#Preview {
    AddReview(place: .constant(SHPOIPlace(name: "Test Stadium", category: .soccer, latitude: 0, longitude: 0, address: nil, imageName: "soccer", description: "")))
        .preferredColorScheme(.dark)
}
