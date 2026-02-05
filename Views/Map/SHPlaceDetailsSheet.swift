import SwiftUI
import MapKit
import CoreLocation

// MARK: - SHEET FOR MANUAL PLACES (Legacy)
struct SHPlaceDetailsSheetManual: View {
    let place: SHManualPlace

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SheetHandle()
            
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: place.category.systemImage)
                    .font(.system(size: 22, weight: .semibold))
                    .frame(width: 40, height: 40)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name).font(.title3.weight(.semibold))
                    Text(place.category.rawValue).foregroundStyle(.secondary) // FIX: foregroundColor -> foregroundStyle
                }
                Spacer()
            }

            if let note = place.note {
                Text(note).foregroundStyle(.secondary) // FIX: foregroundColor -> foregroundStyle
            }

            Spacer()

            Button {
                openInAppleMaps(name: place.name, coordinate: place.coordinate)
            } label: {
                Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(20)
    }
}

// MARK: - SHEET FOR DATABASE PLACES (With Distance)
struct SHPlaceDetailsSheetPOI: View {
    let place: SHPOIPlace
    
    // NEW OPTIONAL PARAMETER
    var userLocation: CLLocation? = nil

    // Distance calculation
    var distanceString: String? {
        guard let userLoc = userLocation else { return nil }
        let placeLoc = CLLocation(latitude: place.latitude, longitude: place.longitude)
        let distance = userLoc.distance(from: placeLoc) // in meters
        
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            
            // 1. HANDLE
            SheetHandle()
                .padding(.top, 10)
                .padding(.bottom, 10)
            
            // 2. SCROLLABLE CONTENT
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Image
                    Image(place.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                    // Info Header
                    VStack(alignment: .leading, spacing: 8) {
                        
                        // Category & Distance Badge (Top Row)
                        HStack {
                            Text(place.category.rawValue.uppercased())
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundStyle(.blue) // FIX: foregroundColor -> foregroundStyle
                                .clipShape(RoundedRectangle(cornerRadius: 6)) // FIX: cornerRadius -> clipShape
                            
                            Spacer()
                            
                            // DISTANCE (If available)
                            if let dist = distanceString {
                                HStack(spacing: 4) {
                                    Image(systemName: "location.fill")
                                        .font(.caption2)
                                    Text(dist)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.1))
                                .foregroundStyle(.secondary) // FIX: foregroundColor -> foregroundStyle
                                .clipShape(RoundedRectangle(cornerRadius: 6)) // FIX: cornerRadius -> clipShape
                            }
                        }
                        
                        Text(place.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary) // FIX: foregroundColor -> foregroundStyle
                        
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundStyle(.red) // FIX: foregroundColor -> foregroundStyle
                            Text(place.address ?? "Address not available")
                                .foregroundStyle(.secondary) // FIX: foregroundColor -> foregroundStyle
                        }
                        .font(.body)
                    }
                    
                    Divider()
                    
                    // Description
                    VStack(alignment: .leading, spacing: 10) {
                        Text("About")
                            .font(.headline)
                        
                        Text(place.description)
                            .font(.body)
                            .foregroundStyle(.secondary) // FIX: foregroundColor -> foregroundStyle
                            .lineSpacing(4)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
            }
            
            // 3. DIRECTIONS BUTTON (Fixed at Bottom)
            VStack(spacing: 0) {
                Divider()
                
                Button {
                    openInAppleMaps(name: place.name, coordinate: place.coordinate)
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        Text("Get Directions")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(.bar)
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - UI Helpers

private struct SheetHandle: View {
    var body: some View {
        Capsule()
            .fill(Color.secondary.opacity(0.2))
            .frame(width: 40, height: 5)
    }
}

// MARK: - Universal Maps Launcher

// FIX: Using URL Scheme to completely bypass MKPlacemark/MKMapItem init deprecation issues
@MainActor
private func openInAppleMaps(name: String, coordinate: CLLocationCoordinate2D) {
    // Build the Apple Maps URL
    // daddr = Destination Address (lat,lon)
    // dirflg = Direction Flag (w = walking)
    // q = Point Label (place name)
    
    let lat = coordinate.latitude
    let lon = coordinate.longitude
    
    // Ensure the name is correctly encoded for a URL
    let label = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    
    let urlString = "http://maps.apple.com/?daddr=\(lat),\(lon)&dirflg=w&q=\(label)"
    
    if let url = URL(string: urlString) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
