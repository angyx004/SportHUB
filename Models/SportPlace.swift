import Foundation
import CoreLocation

// MARK: - Sport Categories
enum SHSportCategory: String, CaseIterable, Identifiable, Codable {
    case soccer = "Soccer"
    case volleyball = "Volleyball"
    case basketball = "Basketball"
    case tennis = "Tennis"
    case running = "Running"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .soccer: return "soccerball"
        case .volleyball: return "volleyball.fill"
        case .basketball: return "basketball.fill"
        case .tennis: return "tennisball.fill"
        case .running: return "figure.run"
        }
    }
}

// MARK: - Review Structure
struct UserReview: Identifiable, Codable, Hashable {
    var id = UUID()
    var author: String   // Name of the writer (e.g., "Mario", "You")
    var comment: String
    var score: Int       // Rating from 1 to 5
    var date: Date = Date()
}

// MARK: - Manual Places Structure (Legacy/Parks)
struct SHManualPlace: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: SHSportCategory
    let latitude: Double
    let longitude: Double
    let note: String?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Main Places Structure (SHPOIPlace)
struct SHPOIPlace: Identifiable, Codable, Hashable {
    var id = UUID()
    let name: String
    let category: SHSportCategory
    let latitude: Double
    let longitude: Double
    let address: String?
    let imageName: String
    
    // --- NEW FIELD ADDED ---
    // Used to hold the 40 unique descriptions
    var description: String
    
    // 1. Logged-in user's review (initially nil)
    var myReview: UserReview? = nil
    
    // 2. System-generated reviews (will always be 3)
    var mockReviews: [UserReview] = []
    
    // 3. Favorite State
    var isFavorite: Bool = false
    
    // 4. DYNAMIC AVERAGE CALCULATION
    var averageRating: Double {
        var totalScore = 0
        var count = 0
        
        // A. Sum the scores of mock reviews
        for review in mockReviews {
            totalScore += review.score
            count += 1
        }
        
        // B. If the user added a review, add their score
        if let my = myReview {
            totalScore += my.score
            count += 1
        }
        
        // Avoid division by zero
        if count == 0 { return 0.0 }
        
        // C. Calculate the average
        let average = Double(totalScore) / Double(count)
        
        // Round to 1 decimal place (e.g., 4.7)
        return (average * 10).rounded() / 10
    }
    
    // Helper: Total review count to show in UI e.g.: (4)
    var totalReviewsCount: Int {
        return mockReviews.count + (myReview != nil ? 1 : 0)
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
