import SwiftUI

struct SHTabsRootView: View {
    @State private var selection: Int = 0

    var body: some View {
        // iOS 17: standard TabView
        TabView(selection: $selection) {

            // 1. HOME
            HomeView()
                .tabItem { Label("Hub", systemImage: "house") }
                .tag(0)

            // 2. MAP
            SHMapScreen()
                .tabItem { Label("Map", systemImage: "map") }
                .tag(1)

            // 3. EXPLORE
            // Here we call the SHExploreView defined in the separate file DIRECTLY.
            // The wrapper at the bottom of the file is no longer needed.
            SHExploreView()
                .tabItem { Label("Explore", systemImage: "binoculars.fill") }
                .tag(2)
           
            // 4. REVIEWS
            // Here we use the wrapper defined below (SHReviewsView) because
            // ReviewsList needs us to pass the data ($).
            SHReviewsView()
                .tabItem { Label("Reviews", systemImage: "checkmark.seal.text.page.fill") }
                .tag(3)
        }
    }
}

// MARK: - Wrapper Views

struct SHReviewsView: View {
    // Observe shared data
    @ObservedObject var dataService = SportsDataService.shared
    
    var body: some View {
        // Calls your ReviewsList passing the Binding to places
        ReviewsList(places: $dataService.allPlaces)
    }
}
