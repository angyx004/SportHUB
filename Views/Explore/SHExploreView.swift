import SwiftUI

struct SHExploreView: View {
    @StateObject private var dataService = SportsDataService.shared
    
    // 1. STATI
    @State private var searchText: String = ""
    @State private var selectedCategory: SHSportCategory? = nil
    
    private let categories: [SHSportCategory] = [.soccer, .volleyball, .basketball, .tennis, .running]
    
    // 2. LOGICA DI FILTRAGGIO
    var filteredPlaces: [SHPOIPlace] {
        var places = dataService.allPlaces
        
        // Filtro Categoria
        if let selectedCategory = selectedCategory {
            places = places.filter { $0.category == selectedCategory }
        }
        
        // Filtro Testo
        if !searchText.isEmpty {
            places = places.filter { place in
                place.name.localizedCaseInsensitiveContains(searchText) ||
                (place.address?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return places
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - 1. SFONDO (UGUALE ALLA HOME)
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
                
                // MARK: - 2. CONTENUTO UNICO SCROLLABILE
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // A. TITOLO EXPLORE
                        Text("Explore")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        // B. SEARCH BAR (SOLO BARRA, NO TASTO FILTRO)
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            
                            TextField("Search courts or streets", text: $searchText)
                                .autocorrectionDisabled()
                                .submitLabel(.search)
                                .foregroundColor(.primary) // Il colore si adatta grazie al materiale sotto
                            
                            if !searchText.isEmpty {
                                Button(action: { withAnimation { searchText = "" } }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        // Stile "Liquid Glass" (Regular Material per contrasto su sfondo scuro)
                        .background(.regularMaterial, in: Capsule())
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 20)
                        
                        // C. BARRA FILTRI (Stile HomeView - Ciano/Nero)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // Tasto "All"
                                FilterChipExplore(
                                    icon: "square.grid.2x2.fill",
                                    label: "All",
                                    isSelected: selectedCategory == nil
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedCategory = nil
                                    }
                                }
                                
                                // Categorie
                                ForEach(categories, id: \.self) { category in
                                    FilterChipExplore(
                                        icon: category.systemImage,
                                        label: category.rawValue,
                                        isSelected: selectedCategory == category
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            if selectedCategory == category {
                                                selectedCategory = nil
                                            } else {
                                                selectedCategory = category
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)
                        }
                        
                        // D. EXPLORE LIST
                        if filteredPlaces.isEmpty {
                            ContentUnavailableView(
                                "No places found",
                                systemImage: "magnifyingglass",
                                description: Text("Try changing your search or filters.")
                            )
                            .padding(.top, 50)
                            .foregroundColor(.white)
                        } else {
                            LazyVStack(spacing: 25) {
                                ForEach(filteredPlaces) { place in
                                    if let index = dataService.allPlaces.firstIndex(where: { $0.id == place.id }) {
                                        NavigationLink(destination: DetailView(place: $dataService.allPlaces[index])) {
                                            ExplorePlaceCard(place: place)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationTitle("Explore")
            .toolbar(.hidden, for: .navigationBar) // Nasconde la navbar standard
        }
    }
}

// MARK: - FILTER DESIGN (STILE HOME VIEW - CIANO)
struct FilterChipExplore: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption.bold())
                Text(label)
                    .font(.subheadline.weight(.semibold))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                isSelected
                ? AnyShapeStyle(LinearGradient(colors: [Color.cyan, Color.cyan.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                : AnyShapeStyle(.ultraThinMaterial)
            )
            .foregroundColor(.white)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.cyan.opacity(0.8) : Color.cyan.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: isSelected ? .cyan.opacity(0.6) : .black.opacity(0.5), radius: 10, x: 0, y: 5)
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

// MARK: - EXPLORE CARD (LIQUID GLASS - DARK OPTIMIZED)
struct ExplorePlaceCard: View {
    let place: SHPOIPlace
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // 1. Immagine
            GeometryReader { geometry in
                Image(place.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .frame(height: 260)
            
            // Gradiente Nero
            LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
            
            // 2. Info Panel
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(place.category.rawValue.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.ultraThinMaterial, in: Capsule())
                    
                    HStack(spacing: 6) {
                        Text(place.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .shadow(color: .black, radius: 2)
                        
                        if place.myReview != nil {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundColor(.cyan)
                                .background(Circle().fill(.white).padding(1))
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.caption2)
                        Text(place.address ?? "Naples, Italy")
                            .font(.caption)
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(16)
            .background(.ultraThinMaterial)
        }
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        
        // 3. Badge Rating
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(.yellow)
                
                Text(String(format: "%.1f", place.averageRating))
                    .font(.caption)
                    .fontWeight(.black)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 0.5))
            .padding(12)
        }
        .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
    }
}
