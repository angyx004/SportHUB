import Foundation
import SwiftUI
import MapKit
import Combine
import CoreLocation

@MainActor
final class SHMapScreenViewModel: ObservableObject {
    
    // MARK: - Services
    private let dataService = SportsDataService.shared
    
    // 1. IMPORTANT: Keep LocationManager alive here in the ViewModel
    // This ensures permissions are checked and GPS is active when opening the map.
    private let locationManager = LocationManager()

    // MARK: - Region & Camera
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.8450, longitude: 14.2450),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    // 2. MODIFIED: The initial position now looks for the user (.userLocation)
    // If GPS is not found, it uses the fallback (Naples).
    @Published var position: MapCameraPosition = .userLocation(fallback: .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.8450, longitude: 14.2450),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    ))

    // MARK: - UI State
    @Published var searchText: String = ""
    @Published var selectedCategories: Set<SHSportCategory> = Set(SHSportCategory.allCases)
    @Published var showFilters: Bool = false
    @Published var selectedPOIPlace: SHPOIPlace? = nil

    // MARK: - Filter Logic

    /// Toggles a category. Prevents deselecting if it's the last one active.
    func toggleCategory(_ category: SHSportCategory) {
        if selectedCategories.contains(category) {
            // Only remove if there's more than one selected
            if selectedCategories.count > 1 {
                selectedCategories.remove(category)
            } else {
                // Trigger a "Warning" haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
            }
        } else {
            selectedCategories.insert(category)
            // Light tap feedback when adding
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }

    /// Resets to all categories
    func resetFilters() {
        selectedCategories = Set(SHSportCategory.allCases)
    }

    // MARK: - Public API

    func updateRegionFromMap(_ newRegion: MKCoordinateRegion) {
        region = newRegion
    }

    func refreshPOIs() {
        objectWillChange.send()
    }
    
    func clearSearch() {
        searchText = ""
    }

    // MARK: - Filtered Data
    var filteredPlaces: [SHPOIPlace] {
        dataService.allPlaces
            .filter { selectedCategories.contains($0.category) }
            .filter { matchesSearch(name: $0.name, address: $0.address, category: $0.category) }
    }

    private func matchesSearch(name: String, address: String?, category: SHSportCategory) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if query.isEmpty { return true }
        return name.lowercased().contains(query) ||
               (address?.lowercased().contains(query) ?? false) ||
               category.rawValue.lowercased().contains(query)
    }
}
