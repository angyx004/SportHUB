import SwiftUI
import MapKit
import CoreLocation

struct SHMapScreen: View {
    @StateObject private var vm = SHMapScreenViewModel()
    @StateObject private var locationManager = LocationManager()
    @Namespace private var mapScope
    @State private var sheetDetent: PresentationDetent = .medium
    
    var body: some View {
        ZStack(alignment: .top) {
            
            // 1. MAP LAYER
            Map(position: $vm.position, scope: mapScope) {
                UserAnnotation()
                
                ForEach(vm.filteredPlaces) { place in
                    Annotation(place.name, coordinate: place.coordinate) {
                        Button {
                            // Reset the selection first to ensure a clean sheet transition
                            if vm.selectedPOIPlace != nil {
                                vm.selectedPOIPlace = nil
                                
                                // Small delay to allow the sheet to reset before showing the new one
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    sheetDetent = .medium
                                    withAnimation(.spring()) {
                                        vm.selectedPOIPlace = place
                                    }
                                }
                            } else {
                                sheetDetent = .medium
                                withAnimation(.spring()) {
                                    vm.selectedPOIPlace = place
                                }
                            }
                        } label: {
                            marker(systemImage: place.category.systemImage)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            // Pushes the "Legal" link just above the Tab Bar area
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }
            .safeAreaInset(edge: .top) {
                Color.clear.frame(height: 100)
            }
            .onMapCameraChange { context in
                vm.updateRegionFromMap(context.region)
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation {
                    vm.position = .userLocation(fallback: .region(vm.region))
                }
            }

            // 2. UI OVERLAY - SEARCH BAR & FILTERS
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search courts or streets", text: $vm.searchText)
                            .autocorrectionDisabled()
                            .submitLabel(.search)
                        
                        if !vm.searchText.isEmpty {
                            Button(action: { vm.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(.regularMaterial, in: Capsule())
                    .overlay(
                        Capsule().stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    Button {
                        vm.showFilters = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 50, height: 50)
                            .background(.regularMaterial, in: Circle())
                            .overlay(
                                Circle().stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.horizontal, 20)
                // MODIFIED: Padding reduced from 60 to 40 to move the search bar higher
                Spacer()
            }
            
            // 3. GPS BUTTON
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring()) {
                            vm.position = .userLocation(fallback: .region(vm.region))
                        }
                    }) {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .frame(width: 50, height: 50)
                            .background(.regularMaterial, in: Circle())
                            .overlay(
                                Circle().stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                            )
                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom)
                }
            }
        }
        .sheet(isPresented: $vm.showFilters) {
            SHFiltersSheet(
                selected: vm.selectedCategories,
                onToggle: { category in vm.toggleCategory(category) },
                onReset: { vm.resetFilters() }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationBackground(.regularMaterial)
        }
        .sheet(item: $vm.selectedPOIPlace) { place in
            SHPlaceDetailsSheetPOI(
                place: place,
                userLocation: locationManager.userLocation
            )
            .id(place.id)
            .presentationDetents([.medium, .large], selection: $sheetDetent)
            .presentationDragIndicator(.visible)
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            .presentationBackground(.regularMaterial)
        }
    }
    
    private func marker(systemImage: String) -> some View {
        ZStack {
            Circle()
                .fill(.regularMaterial)
                .frame(width: 44, height: 44)
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                .overlay(
                    Circle().stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
            
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.blue)
        }
        .overlay(alignment: .bottom) {
            Image(systemName: "triangle.fill")
                .resizable()
                .frame(width: 12, height: 10)
                .foregroundColor(.white.opacity(0.8))
                .rotationEffect(.degrees(180))
                .offset(y: 8)
                .shadow(color: .black.opacity(0.1), radius: 1, y: 1)
        }
    }
}
