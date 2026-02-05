import Foundation
import SwiftUI
import CoreLocation
import MapKit
import Combine

@MainActor
class SportsDataService: ObservableObject {
    static let shared = SportsDataService()
    
    @Published var allPlaces: [SHPOIPlace] = []

    private init() {
        var places = loadInitialPlaces()
        
        // Generate stable reviews
        for i in 0..<places.count {
            places[i].mockReviews = generateStableReviews(for: places[i].category, placeName: places[i].name)
        }
        
        self.allPlaces = places
    }
    
    // MARK: - Filtering Functions
    
    func getFavorites() -> [SHPOIPlace] {
        return allPlaces.filter { $0.isFavorite }
    }
    
    func resetAllFavorites() {
        for index in allPlaces.indices {
            allPlaces[index].isFavorite = false
        }
    }
    
    func getAroundYou(userLoc: CLLocation?) -> [SHPOIPlace] {
        guard let userLoc else {
            return Array(allPlaces.prefix(8))
        }
        
        return allPlaces
            .sorted {
                let loc1 = CLLocation(latitude: $0.latitude, longitude: $0.longitude)
                let loc2 = CLLocation(latitude: $1.latitude, longitude: $1.longitude)
                return userLoc.distance(from: loc1) < userLoc.distance(from: loc2)
            }
            .prefix(8)
            .map { $0 }
    }
    
    func getTopRated() -> [SHPOIPlace] {
        return allPlaces
            .sorted { $0.averageRating > $1.averageRating }
            .prefix(8)
            .map { $0 }
    }
    
    // MARK: - Initial Data with 40 Unique Descriptions
    
    private func loadInitialPlaces() -> [SHPOIPlace] {
        return [
            // --- SOCCER (8) ---
            SHPOIPlace(
                name: "Arturo Collana Stadium",
                category: .soccer,
                latitude: 40.8465, longitude: 14.2270,
                address: "4 Francesco Rossellini Street, 80128 Naples",
                imageName: "stadio arturo collana",
                description: "The historical heart of sports in Vomero. Originally built in the 1920s, this stadium offers a professional-grade synthetic turf and grandstands that echo with the passion of local tournaments. It's the closest you can get to a pro experience in the city center."
            ),
            SHPOIPlace(
                name: "San Gennaro dei Poveri Pitch",
                category: .soccer,
                latitude: 40.8601, longitude: 14.2485,
                address: "25 San Gennaro dei Poveri Lane, 80136 Naples",
                imageName: "san-gennaro-gallery1",
                description: "Hidden within the vibrant Rione Sanità, this pitch is more than just a sports field; it's a social hub. The recently renovated surface is perfect for fast-paced 5-a-side games, surrounded by the unique architecture of the historic district."
            ),
            SHPOIPlace(
                name: "San Domenico Soccer Field",
                category: .soccer,
                latitude: 40.8480, longitude: 14.2550,
                address: "148 San Domenico Street, 80126 Naples",
                imageName: "San Domenico",
                description: "Located on the hills, this facility offers fresh air and well-maintained locker rooms. It is a favorite among local amateur leagues due to its spacious field and excellent night lighting system."
            ),
            SHPOIPlace(
                name: "Santa Maria della Libera Field",
                category: .soccer,
                latitude: 40.8405, longitude: 14.2215,
                address: "113 Belvedere Street, 80127 Naples",
                imageName: "Santa Maria della Libera Field.peg",
                description: "A compact but intense arena for technical players. Nestled in a residential area, this pitch is known for its high-quality synthetic grass that mimics natural turf, reducing injuries and improving ball control."
            ),
            SHPOIPlace(
                name: "Materdei Soccer Playground",
                category: .soccer,
                latitude: 40.8530, longitude: 14.2410,
                address: "3 San Gennaro Square, 80136 Naples",
                imageName: "Materdei Soccer Playground",
                description: "A legendary spot for street soccer enthusiasts. This playground captures the raw essence of Neapolitan football, where skill and grit matter more than equipment. Great for casual pick-up games."
            ),
            SHPOIPlace(
                name: "San Luigi Youth Center Pitch",
                category: .soccer,
                latitude: 40.8245, longitude: 14.2110,
                address: "115 Francesco Petrarca Street, 80123 Naples",
                imageName: "San Luigi Youth Center Pitch",
                description: "With a stunning view over the gulf, playing here feels like a privilege. The San Luigi center offers top-tier facilities, clean showers, and a pitch that is meticulously cared for by the Jesuit community."
            ),
            SHPOIPlace(
                name: "San Gioacchino Soccer Field",
                category: .soccer,
                latitude: 40.8280, longitude: 14.2185,
                address: "139 Orazio Street, 80122 Naples",
                imageName: "San gioacchino",
                description: "Located in the Posillipo area, this field is an exclusive spot for organized matches. The atmosphere is quiet and focused, perfect for teams who take their weekly tactical training seriously."
            ),
            SHPOIPlace(
                name: "Denza Sports Center",
                category: .soccer,
                latitude: 40.8160, longitude: 14.1850,
                address: "9 Coroglio Descent, 80123 Naples",
                imageName: "Denza Sports Cente",
                description: "Surrounded by greenery near the coastline, Denza is one of the most complete sports complexes in Naples. The soccer pitches are wide, professional, and often host regional youth championships."
            ),

            // --- VOLLEYBALL (8) ---
            SHPOIPlace(
                name: "Collana Stadium Gym",
                category: .volleyball,
                latitude: 40.8468, longitude: 14.2272,
                address: "4 Francesco Rossellini Street, 80128 Naples",
                imageName: "Collana Stadium Gym",
                description: "Part of the historic Collana complex, this indoor gym features a high ceiling and a professional parquet floor. It is the home ground for many local teams and offers excellent acoustics for match days."
            ),
            SHPOIPlace(
                name: "Dante Square Sports Center",
                category: .volleyball,
                latitude: 40.8495, longitude: 14.2505,
                address: "Dante Square, 80135 Naples",
                imageName: "Dante Square Sports Center",
                description: "Right in the city center, this gym is an urban gem. Despite the busy location, inside it offers a focused environment with modern net systems and shock-absorbing flooring ideal for jumps."
            ),
            SHPOIPlace(
                name: "Soccavo Multi-purpose Center",
                category: .volleyball,
                latitude: 40.8385, longitude: 14.1910,
                address: "Adriano Avenue, 80126 Naples",
                imageName: "Soccavo Multi-purpose Center",
                description: "A massive facility designed for large tournaments. The Soccavo center offers multiple courts, ample parking, and bleachers for spectators, making it the best choice for league finals."
            ),
            SHPOIPlace(
                name: "Partenope Volleyball Gym",
                category: .volleyball,
                latitude: 40.8345, longitude: 14.2395,
                address: "40 Medina Street, 80133 Naples",
                imageName: "Partenope Volleyball Gym",
                description: "Steeped in history, this gym belongs to one of the oldest sports societies in Naples. The vintage feel combines with updated equipment to offer a unique, traditional training atmosphere."
            ),
            SHPOIPlace(
                name: "Sannazaro Sports Club",
                category: .volleyball,
                latitude: 40.8410, longitude: 14.2510,
                address: "12 Giacomo Puccini Street, 80127 Naples",
                imageName: "annazaro Sports Club",
                description: "Located near the vibrant Chiaia district, this club is exclusive and well-kept. It focuses on youth development and technical training courses, with highly qualified instructors."
            ),
            SHPOIPlace(
                name: "Nazionale Square Gym",
                category: .volleyball,
                latitude: 40.8540, longitude: 14.2740,
                address: "34 Foggia Street, 80143 Naples",
                imageName: "Nazionale Square Gym",
                description: "A key spot for the industrial area, this gym is practical, rugged, and always open. It's the go-to place for after-work matches and intense physical preparation sessions."
            ),
            SHPOIPlace(
                name: "Nestore Athletics Gym",
                category: .volleyball,
                latitude: 40.8650, longitude: 14.2200,
                address: "Nestore Street, 80145 Naples",
                imageName: "Nestore Street,",
                description: "Known for its rigorous training programs, Nestore is where champions are made. The facility focuses on athletics and volleyball, providing specific equipment for vertical jump training."
            ),
            SHPOIPlace(
                name: "Galizia Sports Hall",
                category: .volleyball,
                latitude: 40.8430, longitude: 14.2530,
                address: "Mercato Square, 80133 Naples",
                imageName: "Galizia Sports Hall",
                description: "A newly renovated hall that brings sports to the heart of the Mercato district. Bright, clean, and colorful, it aims to engage the local community in team sports."
            ),

            // --- BASKETBALL (8) ---
            SHPOIPlace(
                name: "Spanish Quarters Court",
                category: .basketball,
                latitude: 40.8395, longitude: 14.2440,
                address: "Fornelli Avenue, 80132 Naples",
                imageName: "spanish quarters",
                description: "An iconic streetball court hidden in the maze of the Quartieri Spagnoli. The vibrant graffiti art and the energy of the neighborhood make every game here feel like an urban movie scene."
            ),
            SHPOIPlace(
                name: "Kodokan Naples",
                category: .basketball,
                latitude: 40.8630, longitude: 14.2640,
                address: "1 Carlo III Square, 80137 Naples",
                imageName: "kodokan",
                description: "Housed in the majestic Albergo dei Poveri, Kodokan is a temple of sports. The basketball court is indoors, immense, and breathes history, offering a unique silence and focus for players."
            ),
            SHPOIPlace(
                name: "Viviani Park Court",
                category: .basketball,
                latitude: 40.8435, longitude: 14.2385,
                address: "14 Girolamo Santacroce Street, 80129 Naples",
                imageName: "viviani park",
                description: "A playground with a view. Located in a panoramic park, this court allows you to shoot hoops while overlooking the city. It's popular for sunset games and chill 1v1 sessions."
            ),
            SHPOIPlace(
                name: "San Pasquale Playground",
                category: .basketball,
                latitude: 40.8345, longitude: 14.2375,
                address: "San Pasquale Street, 80121 Naples",
                imageName: "San Pasquale Playgrund",
                description: "The meeting point for the Chiaia basketball community. It's a small, intense concrete court where local legends and newcomers clash every afternoon. Bring your A-game."
            ),
            SHPOIPlace(
                name: "Medaglie d'Oro Square Court",
                category: .basketball,
                latitude: 40.8490, longitude: 14.2305,
                address: "Medaglie d'Oro Square, 80128 Naples",
                imageName: "medaglie d'oro",
                description: "Right in the middle of a busy roundabout, this fenced court is an urban cage. It's perfect for fast, aggressive 3v3 games where the noise of the city fades into the background."
            ),
            SHPOIPlace(
                name: "Molosiglio Waterfront Court",
                category: .basketball,
                latitude: 40.8350, longitude: 14.2515,
                address: "35 Acton Admiral Street, 80133 Naples",
                imageName: "molosiglio.peg",
                description: "Play right next to the sea. The Molosiglio court offers a refreshing sea breeze and a view of Vesuvius. It's one of the most scenic spots to play basketball in Italy."
            ),
            SHPOIPlace(
                name: "Robinson Park Playground",
                category: .basketball,
                latitude: 40.8250, longitude: 14.1890,
                address: "54 J.F. Kennedy Avenue, 80125 Naples",
                imageName: "robinson park",
                description: "Located inside the Mostra d'Oltremare area, this court is surrounded by pine trees. It offers plenty of shade, making it the best choice for playing during hot summer days."
            ),
            SHPOIPlace(
                name: "Caravaggio Basketball Gym",
                category: .basketball,
                latitude: 40.8251, longitude: 14.1855,
                address: "382 Terracina Street, 80125 Naples",
                imageName: "caravaggio",
                description: "A professional indoor facility used by local league teams. The hardwood floor is top-notch, and the electronic scoreboard makes it ideal for organized tournaments and serious practice."
            ),

            // --- TENNIS (8) ---
            SHPOIPlace(
                name: "Naples Tennis Club",
                category: .tennis,
                latitude: 40.8322, longitude: 14.2345,
                address: "Anton Dohrn Avenue, 80122 Naples",
                imageName: "napoli tennis club",
                description: "Founded in 1905, this is the most prestigious club in the city. Hosting international tournaments, its red clay courts are legendary. Playing here is a dive into the aristocracy of tennis."
            ),
            SHPOIPlace(
                name: "Vomero Tennis Academy",
                category: .tennis,
                latitude: 40.8420, longitude: 14.2250,
                address: "6 Gioacchino Rossini Street, 80128 Naples",
                imageName: "tennis academy vomero",
                description: "A modern academy focused on performance. It features both clay and hard courts, with video analysis technology available for students who want to perfect their swing."
            ),
            SHPOIPlace(
                name: "Villa Comunale Tennis Center",
                category: .tennis,
                latitude: 40.8315, longitude: 14.2330,
                address: "Anton Dohrn Avenue, 80121 Naples",
                imageName: "villa comunale tennis center",
                description: "Nestled within the historic Villa Comunale park, these courts offer a unique mix of nature and sport. It's a relaxing place to play a friendly match just steps away from the seafront."
            ),
            SHPOIPlace(
                name: "Petrarca Tennis Club",
                category: .tennis,
                latitude: 40.8210, longitude: 14.2155,
                address: "147 Petrarca Street, 80123 Naples",
                imageName: "petrarca tennis club",
                description: "Panoramic courts overlooking the Bay of Naples. This club is famous for its social events and its exclusive atmosphere. The perfect spot for a sunset match followed by an aperitif."
            ),
            SHPOIPlace(
                name: "Orientale Tennis Club",
                category: .tennis,
                latitude: 40.8445, longitude: 14.2720,
                address: "Marina Street, 80133 Naples",
                imageName: "orientale tennis club",
                description: "Conveniently located near the university area, this club is popular among students and young professionals. It offers affordable rates and a vibrant, energetic community."
            ),
            SHPOIPlace(
                name: "Belvedere Tennis Courts",
                category: .tennis,
                latitude: 40.8425, longitude: 14.2220,
                address: "102 Belvedere Street, 80127 Naples",
                imageName: "belvedere tennis court",
                description: "Hidden in a quiet courtyard in Vomero, Belvedere offers privacy and silence. The courts are meticulously cared for, ensuring a perfect bounce for clay lovers."
            ),
            SHPOIPlace(
                name: "Via Manzoni Tennis Club",
                category: .tennis,
                latitude: 40.8260, longitude: 14.2050,
                address: "142 Alessandro Manzoni Street, 80123 Naples",
                imageName: "via manzoni tennis club",
                description: "An elegant club on the Posillipo hill. It features a swimming pool for post-match relaxation and high-quality coaching staff for all levels, from beginners to pros."
            ),
            SHPOIPlace(
                name: "Le Terrazze Tennis Club",
                category: .tennis,
                latitude: 40.8390, longitude: 14.2180,
                address: "54 Aniello Falcone Street, 80127 Naples",
                imageName: "le terrazze tennis club",
                description: "As the name suggests, this club is built on terraces that offer stunning views. It combines sport with a trendy location, often hosting social mixers and amateur tournaments."
            ),

            // --- RUNNING (8) ---
            SHPOIPlace(
                name: "Caracciolo Waterfront",
                category: .running,
                latitude: 40.8306, longitude: 14.2468,
                address: "Francesco Caracciolo Street, 80122 Naples",
                imageName: "carracciolo",
                description: "The most famous running route in Naples. A flat, wide sidewalk right next to the sea, stretching from Mergellina to Castel dell'Ovo. Ideal for long-distance training with no traffic interruptions."
            ),
            SHPOIPlace(
                name: "Villa Comunale Park",
                category: .running,
                latitude: 40.8300, longitude: 14.2369,
                address: "Anton Dohrn Avenue, 80121 Naples",
                imageName: "villa comunale",
                description: "Run under the shade of centuries-old trees. This park offers a soft dirt path that is kind to your joints, making it perfect for recovery runs or interval training away from the sun."
            ),
            SHPOIPlace(
                name: "Floridiana Park",
                category: .running,
                latitude: 40.8410, longitude: 14.2290,
                address: "77 Domenico Cimarosa Street, 80127 Naples",
                imageName: "floridiana",
                description: "A green lung in the Vomero district. The paths here are winding and offer elevation changes, providing a good cardio challenge. The view from the Belvedere terrace is a great reward."
            ),
            SHPOIPlace(
                name: "Vittorio Emanuele Route",
                category: .running,
                latitude: 40.8400, longitude: 14.2350,
                address: "Vittorio Emanuele Avenue, 80135 Naples",
                imageName: "vittorio emanuele route",
                description: "A panoramic road that cuts through the city hills. This route is for endurance runners who love urban landscapes. It offers a continuous gentle slope, great for building stamina."
            ),
            SHPOIPlace(
                name: "San Martino Historical Steps",
                category: .running,
                latitude: 40.8445, longitude: 14.2415,
                address: "20 San Martino Square, 80129 Naples",
                imageName: "san martino",
                description: "The ultimate challenge for your legs. This route consists of the Pedamentina stairs, connecting the hilltop castle to the city center. Perfect for high-intensity interval training (HIIT)."
            ),
            SHPOIPlace(
                name: "Petraio Steps Route",
                category: .running,
                latitude: 40.8425, longitude: 14.2380,
                address: "Petraio Street, 80127 Naples",
                imageName: "petraio",
                description: "A scenic, vertical run through one of Naples' oldest paths. The Petraio offers a mix of stairs and flat stretches, winding through colorful houses and quiet gardens. Tough but rewarding."
            ),
            SHPOIPlace(
                name: "Via Petrarca Scenic Route",
                category: .running,
                latitude: 40.8230, longitude: 14.2140,
                address: "Petrarca Street, 80123 Naples",
                imageName: "via petrarca",
                description: "Known as the 'postcard route'. Running here gives you the classic view of the Gulf of Naples with Vesuvius in the background. The sidewalk is wide and popular among morning joggers."
            ),
            SHPOIPlace(
                name: "Botanical Garden Perimeter",
                category: .running,
                latitude: 40.8615, longitude: 14.2630,
                address: "223 Foria Street, 80139 Naples",
                imageName: "orto botanico",
                description: "A quiet loop around the Real Orto Botanico walls. It's a flat, measured route often used by locals to track their lap times. The area is peaceful, especially in the early morning."
            )
        ]
    }
    
    // MARK: - Deterministic Review Generator
    private func generateStableReviews(for category: SHSportCategory, placeName: String) -> [UserReview] {
        var reviews: [UserReview] = []
        
        // MODIFIED: Added international names to the mix
        let names = [
            "Luca", "Marco", "Giulia", "Sofia", "Alessandro", "Francesca", "Matteo", "Chiara", "Davide", "Elena", "Fabio", "Valentina", // Italian
            "John", "Sarah", "Liam", "Emma", "Hans", "Chloe", "Hiro", "Fatima", "Carlos", "Yuki", "Amara", "Sven" // International
        ]
        
        let surnameInitials = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let seed = placeName.utf8.reduce(0) { $0 + Int($1) }
        
        for i in 0..<3 {
            let currentSeed = seed + (i * 100)
            let score: Int
            if i == 0 { score = 4 + (currentSeed % 2) }
            else if i == 1 { score = 3 + (currentSeed % 2) }
            else { score = 2 + (currentSeed % 4) }
            
            let nameIndex = (currentSeed) % names.count
            let initialIndex = (currentSeed) % surnameInitials.count
            let name = names[nameIndex]
            let initialCharIndex = surnameInitials.index(surnameInitials.startIndex, offsetBy: initialIndex)
            let initial = surnameInitials[initialCharIndex]
            let authorName = "\(name) \(initial)."
            
            let possibleComments = getCommentsList(category: category, score: score)
            let commentIndex = (currentSeed) % possibleComments.count
            let comment = possibleComments[commentIndex]
            reviews.append(UserReview(author: authorName, comment: comment, score: score))
        }
        return reviews
    }
    
    private func getCommentsList(category: SHSportCategory, score: Int) -> [String] {
        if score >= 5 {
            switch category {
            case .soccer: return ["The best turf in Naples!", "Perfect lighting for night matches.", "Well maintained and clean.", "Great facility for 5v5."]
            case .basketball: return ["The rims are perfect, love it!", "Amazing court grip.", "Great atmosphere at sunset.", "Best playground in the city."]
            case .tennis: return ["Clay court is in perfect condition.", "Very professional staff.", "Quiet and exclusive environment.", "Great bounce consistency."]
            case .volleyball: return ["High ceiling and perfect floor.", "Professional net equipment.", "Clean locker rooms.", "Best gym for volleyball."]
            case .running: return ["Breathtaking view while running!", "Perfect flat surface for sprints.", "Safe and peaceful area.", "Clean air and good vibes."]
            }
        } else if score == 4 {
            switch category {
            case .soccer: return ["Good pitch, but parking is hard.", "Nice field, changing rooms are ok.", "Solid synthetic grass."]
            case .basketball: return ["Good hoops, floor a bit dusty.", "Nice court but crowded.", "Good for a quick game."]
            case .tennis: return ["Good value for money.", "Nice courts, friendly people.", "Lighting could be better."]
            case .volleyball: return ["Decent gym for training.", "Good net, but a bit hot inside.", "Spacious court."]
            case .running: return ["Nice path, but some pedestrians.", "Good route, a bit short.", "Scenic but sometimes windy."]
            }
        } else if score == 3 {
            return ["It's okay for a casual game.", "Average facilities, nothing special.", "Decent, but needs maintenance.", "Crowded during weekends.", "Acceptable, but could be cleaner."]
        } else {
            return ["Not recommended.", "Needs urgent renovation.", "Too expensive for the quality.", "Bad experience."]
        }
    }
}
