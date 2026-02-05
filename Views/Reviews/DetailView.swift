import SwiftUI

struct DetailView: View {
    @Binding var place: SHPOIPlace
    @State private var showAddReview = false
    
    // Observe the manager to know if we should show the heart and handle login
    @ObservedObject var userManager = UserManager.shared

    var body: some View {
        ZStack {
            // MARK: - 1. SFONDO PERSONALIZZATO (Dark Premium: Ciano -> Nero)
            // Preso identico dalla HomeView e ExploreView
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
            
            // MARK: - 2. CONTENUTO SCROLLABILE
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // HERO HEADER "LIQUID GLASS"
                    GeometryReader { geo in
                        ZStack(alignment: .bottom) {
                            
                            // A. Expanded Image (Bound to width)
                            Image(place.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geo.size.width, height: 320)
                                .clipped()
                            
                            // Gradiente per staccare il testo
                            LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
                            
                            // B. "Glass" Info Panel
                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading, spacing: 6) {
                                    
                                    // Category
                                    Text(place.category.rawValue.uppercased())
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white.opacity(0.9))
                                        .padding(.bottom, 2)
                                    
                                    // Place Name
                                    Text(place.name)
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    // Address
                                    HStack(spacing: 5) {
                                        Image(systemName: "mappin.and.ellipse")
                                            .font(.subheadline)
                                        Text(place.address ?? "Address not available")
                                            .font(.subheadline)
                                            .lineLimit(1)
                                    }
                                    .foregroundColor(.white.opacity(0.95))
                                }
                                
                                Spacer()
                            }
                            .padding(20)
                            .padding(.bottom, 10)
                        }
                    }
                    .frame(height: 320)
                    
                    // Rating Badge & Heart (Floating top right)
                    .overlay(alignment: .topTrailing) {
                        HStack(spacing: 12) {
                            
                            // Rating
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.caption.bold())
                                    .foregroundColor(.yellow)
                                
                                Text(String(format: "%.1f", place.averageRating))
                                    .font(.callout)
                                    .fontWeight(.heavy)
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 0.5))
                            
                            // Heart (Only if logged in)
                            if userManager.isLoggedIn {
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        place.isFavorite.toggle()
                                    }
                                }) {
                                    Image(systemName: place.isFavorite ? "bookmark.fill" : "bookmark")
                                        .font(.title3)
                                        .foregroundColor(place.isFavorite ? .red : .primary)
                                        .padding(8)
                                        .background(.ultraThinMaterial, in: Circle())
                                        .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 0.5))
                                }
                            }
                        }
                        .padding(.top, 60)
                        .padding(.trailing, 20)
                    }

                    // INFO CONTENT
                    VStack(alignment: .leading, spacing: 30) {
                        
                        // A. Description
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white) // Bianco su sfondo scuro
                            
                            Text(place.description)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8)) // Grigio chiaro
                                .lineSpacing(5)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.2)) // Divisore chiaro
                        
                        // B. Reviews
                        VStack(alignment: .leading, spacing: 15) {
                            
                            // Reviews Header
                            HStack {
                                Text("Reviews")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                if !userManager.isLoggedIn {
                                    Text("Log in to review")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            
                            // 1. YOUR REVIEW
                            if let myReview = place.myReview {
                                ReviewRowDetail(review: myReview, isMine: true)
                            } else if userManager.isLoggedIn {
                                // "Write Review" Button
                                Button(action: { showAddReview = true }) {
                                    HStack {
                                        Image(systemName: "square.and.pencil")
                                        Text("Write a review")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    // Gradiente Ciano/Blu
                                    .background(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .shadow(color: .cyan.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                            }
                            
                            // 2. MOCK REVIEWS
                            ForEach(place.mockReviews) { review in
                                ReviewRowDetail(review: review, isMine: false)
                            }
                        }
                    }
                    .padding(24)
                    .padding(.bottom, 50)
                }
            }
            .edgesIgnoringSafeArea(.top)
            .toolbar(.hidden, for: .navigationBar)
            
            // Custom Back Button
            .overlay(alignment: .topLeading) {
                DismissButtonDetail()
                    .padding(.top, 60)
                    .padding(.leading, 20)
            }
            
            .sheet(isPresented: $showAddReview) {
                AddReview(place: $place)
            }
        }
    }
}

// MARK: - SUBVIEWS & UTILITIES

// "Glass" Back Button
struct DismissButtonDetail: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}

// Review Row Design (Optimized for Dark Detail View)
struct ReviewRowDetail: View {
    let review: UserReview
    let isMine: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(isMine ? Color.cyan.opacity(0.2) : Color.white.opacity(0.1))
                    .frame(width: 42, height: 42)
                    .overlay(
                        Text(String(review.author.prefix(1)))
                            .font(.headline)
                            .foregroundColor(isMine ? .cyan : .white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(isMine ? "You" : review.author)
                        .font(.headline)
                        .foregroundColor(.white) // Nome bianco
                    
                    // Stars
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { i in
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(i <= review.score ? .yellow : .white.opacity(0.2))
                        }
                    }
                }
                
                Spacer()
                
                if isMine {
                    Text("Your review")
                        .font(.caption2.bold())
                        .foregroundColor(.cyan)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.cyan.opacity(0.1), in: Capsule())
                        .overlay(Capsule().stroke(Color.cyan.opacity(0.5), lineWidth: 0.5))
                } else {
                    Text("2d ago")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Text(review.comment)
                .font(.body)
                .foregroundColor(.white.opacity(0.8)) // Testo grigio chiaro
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        // Sfondo Vetro Scuro (UltraThinMaterial) invece di grigio solido
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        )
    }
}
