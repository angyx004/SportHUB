import SwiftUI

struct ReviewsList: View {
    @Binding var places: [SHPOIPlace]
    
    // Variables to manage the deletion alert
    @State private var showDeleteAlert = false
    @State private var placeIdToDelete: UUID? = nil
    
    // Filter places with reviews to clean up the view code
    var reviewedPlaces: [SHPOIPlace] {
        places.filter { $0.myReview != nil }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - 1. SFONDO (Dark Premium: Ciano -> Nero)
                // Preso identico dalla HomeView
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
                
                if reviewedPlaces.isEmpty {
                    // EMPTY STATE (Adattato per sfondo scuro)
                    ContentUnavailableView(
                        "No reviews yet",
                        systemImage: "square.and.pencil",
                        description: Text("Visit a place and share your experience to see it here.")
                    )
                    .foregroundColor(.white) // Testo bianco
                } else {
                    // CARD LIST
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(reviewedPlaces) { place in
                                if let review = place.myReview {
                                    ReviewCard(
                                        place: place,
                                        review: review,
                                        onDelete: {
                                            placeIdToDelete = place.id
                                            showDeleteAlert = true
                                        }
                                    )
                                }
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("My Reviews")
            // Forza la navigation bar scura per leggere il titolo bianco
            .toolbarColorScheme(.dark, for: .navigationBar)
            
            // DELETION ALERT
            .alert("Delete Review?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    placeIdToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let id = placeIdToDelete,
                       let index = places.firstIndex(where: { $0.id == id }) {
                        withAnimation {
                            places[index].myReview = nil
                        }
                    }
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
}

// MARK: - REVIEW CARD COMPONENT (Liquid/Clean Design - Dark Optimized)
struct ReviewCard: View {
    let place: SHPOIPlace
    let review: UserReview
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            // 1. HEADER (Place Image + Name + Trash)
            HStack(spacing: 15) {
                // Place Image
                Image(place.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white) // Bianco per sfondo scuro
                        .lineLimit(1)
                    
                    Text(place.category.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.7)) // Grigio chiaro
                }
                
                Spacer()
                
                // Trash Button
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red.opacity(0.9))
                        .background(Circle().fill(.white).padding(2)) // White background to make it pop
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.3)) // Divisore chiaro
            
            // 2. STARS AND COMMENT
            VStack(alignment: .leading, spacing: 8) {
                // Stars
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(i <= review.score ? .yellow : .white.opacity(0.2))
                    }
                    
                    Spacer()
                    
                    Text("You")
                        .font(.caption2.bold())
                        .foregroundColor(.cyan) // Ciano per coerenza col tema
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.cyan.opacity(0.2), in: Capsule())
                        .overlay(Capsule().stroke(Color.cyan.opacity(0.5), lineWidth: 0.5))
                }
                
                // Comment
                Text(review.comment)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9)) // Bianco leggibile
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        // Sfondo VETRO SCURO (UltraThinMaterial) invece di bianco solido
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5) // Bordo sottile
        )
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ReviewsList(
        places: .constant([
            SHPOIPlace(
                name: "Maradona Stadium",
                category: .soccer,
                latitude: 0, longitude: 0,
                address: nil, imageName: "soccer",
                description: "Test description",
                myReview: UserReview(author: "You", comment: "Amazing place, incredible experience!", score: 5)
            )
        ])
    )
    .preferredColorScheme(.dark)
}
