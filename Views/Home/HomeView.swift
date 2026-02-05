import SwiftUI
import Combine
import CoreLocation

struct HomeView: View {
    @StateObject private var dataService = SportsDataService.shared
    @StateObject private var locationManager = LocationManager()
    @ObservedObject private var userManager = UserManager.shared
    
    @State private var showProfileSheet = false
    
    // STATO FILTRO
    @State private var selectedCategory: SHSportCategory? = nil
    private let categories: [SHSportCategory] = [.soccer, .volleyball, .basketball, .tennis, .running]
    
    // MARK: - LOGICA FILTRAGGIO
    
    var filteredTopRated: [SHPOIPlace] {
        let places = dataService.allPlaces
        let filtered = selectedCategory == nil ? places : places.filter { $0.category == selectedCategory }
        
        return filtered
            .sorted { $0.averageRating > $1.averageRating }
            .prefix(8)
            .map { $0 }
    }
    
    var filteredAroundYou: [SHPOIPlace] {
        let places = dataService.allPlaces
        let filtered = selectedCategory == nil ? places : places.filter { $0.category == selectedCategory }
        
        guard let userLoc = locationManager.userLocation else {
            return Array(filtered.prefix(8))
        }
        
        return filtered
            .sorted {
                let loc1 = CLLocation(latitude: $0.latitude, longitude: $0.longitude)
                let loc2 = CLLocation(latitude: $1.latitude, longitude: $1.longitude)
                return userLoc.distance(from: loc1) < userLoc.distance(from: loc2)
            }
            .prefix(8)
            .map { $0 }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. SFONDO PERSONALIZZATO (Dark Premium: Ciano -> Nero)
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
                
                // 2. CONTENUTO
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) { // Spaziatura ridotta per avvicinare i filtri
                        
                        // --- BARRA FILTRI (Stile Explore View) ---
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // Tasto "All"
                                FilterChipHome(
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
                                    FilterChipHome(
                                        icon: category.systemImage,
                                        label: category.rawValue,
                                        isSelected: selectedCategory == category
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedCategory = category
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 15) // Padding identico alla ExploreView
                        }
                        
                        // --- FAVOURITES ---
                        if userManager.isLoggedIn {
                            let favorites = dataService.getFavorites()
                            if !favorites.isEmpty {
                                VStack(alignment: .leading, spacing: 15) {
                                    SectionHeader(title: "Saved")
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 16) {
                                            ForEach(favorites) { place in
                                                if let index = dataService.allPlaces.firstIndex(where: { $0.id == place.id }) {
                                                    NavigationLink(destination: DetailView(place: $dataService.allPlaces[index])) {
                                                        PlaceCard(place: place, userLocation: locationManager.userLocation)
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.bottom, 25)
                                    }
                                }
                            }
                        }
                        
                        // --- TOP RATED ---
                        if !filteredTopRated.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                SectionHeader(title: "Top Rated")
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(filteredTopRated) { place in
                                            if let index = dataService.allPlaces.firstIndex(where: { $0.id == place.id }) {
                                                NavigationLink(destination: DetailView(place: $dataService.allPlaces[index])) {
                                                    PlaceCard(place: place, userLocation: locationManager.userLocation)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 25)
                                }
                            }
                            .transition(.opacity)
                        }
                        
                        // --- AROUND YOU ---
                        if !filteredAroundYou.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                SectionHeader(title: "Around You")
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(filteredAroundYou) { place in
                                            if let index = dataService.allPlaces.firstIndex(where: { $0.id == place.id }) {
                                                NavigationLink(destination: DetailView(place: $dataService.allPlaces[index])) {
                                                    PlaceCard(place: place, userLocation: locationManager.userLocation)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 25)
                                }
                            }
                            .transition(.opacity)
                        }
                        
                        // Fallback vuoto
                        if filteredTopRated.isEmpty && filteredAroundYou.isEmpty {
                            ContentUnavailableView(
                                "No places found",
                                systemImage: "magnifyingglass",
                                description: Text("Try selecting a different category.")
                            )
                            .padding(.top, 50)
                            .foregroundColor(.white)
                        }
                        
                        Spacer(minLength: 50)
                    }
                }
                .navigationTitle("Hub")
                .toolbarBackground(.hidden, for: .navigationBar)
            }
            // TOOLBAR
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showProfileSheet = true }) {
                        if let user = userManager.currentUser {
                            // Avatar Utente
                            Text(String(user.fullName.prefix(1)).uppercased())
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .frame(width: 34, height: 34)
                                .background(Color.cyan)
                                .clipShape(Circle())
                        } else {
                            // Icona Login (Solo SF Symbol)
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 28))
                                .foregroundColor(.cyan)
                        }
                    }
                }
            }
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showProfileSheet) {
                UserProfileView()
            }
        }
    }
}

// MARK: - FILTER CHIP (Copiato dalla Explore View)
struct FilterChipHome: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.bold())
                Text(label)
                    .font(.subheadline.weight(.semibold))
            }
            .padding(.horizontal, 16) // Padding come Explore
            .padding(.vertical, 10)   // Padding come Explore
            .background(isSelected ? Color.blue : Color(.secondarySystemBackground).opacity(0.3)) // Colore Blue come Explore
            .foregroundColor(isSelected ? .white : .white)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.blue : Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        // Animazione opzionale rimossa per matchare esattamente lo stile grafico, ma l'effetto scale c'è
    }
}

// MARK: - SECTION HEADER
struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.leading, 20)
            Spacer()
        }
    }
}

// MARK: - PLACE CARD (Invariata)
struct PlaceCard: View {
    let place: SHPOIPlace
    var userLocation: CLLocation? = nil
    
    var distanceString: String? {
        guard let userLocation = userLocation else { return nil }
        let placeLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
        return String(format: "%.1f km", userLocation.distance(from: placeLocation) / 1000.0)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Immagine
            Image(place.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 260, height: 320)
                .clipped()
            
            // Gradiente
            LinearGradient(colors: [.black.opacity(0), .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
            
            // Info Panel
            VStack(alignment: .leading, spacing: 8) {
                Text(place.category.rawValue.uppercased())
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 0.5))
                
                Text(place.name)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
                
                HStack(spacing: 8) {
                    if let dist = distanceString {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption2)
                            Text(dist)
                                .font(.caption.bold())
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                        Text(place.address ?? "Naples")
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 260, height: 320)
        .mask(RoundedRectangle(cornerRadius: 24, style: .continuous))
        
        // Rating Badge
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption.bold())
                    .foregroundColor(.yellow)
                
                Text(String(format: "%.1f", place.averageRating))
                    .font(.callout.weight(.heavy))
                    .foregroundColor(.primary)
                
                if place.isFavorite {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 1, height: 12)
                        .padding(.horizontal, 4)
                    
                    Image(systemName: "bookmark.fill")
                        .font(.caption.bold())
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule().stroke(Color.white.opacity(0.5), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
            .padding(14)
        }
        .shadow(color: .black.opacity(0.5), radius: 15, x: 0, y: 10)
    }
}
