import SwiftUI

struct SHFiltersSheet: View {
    // Receive state from ViewModel
    let selected: Set<SHSportCategory>
    
    // Closures to communicate actions to the ViewModel
    let onToggle: (SHSportCategory) -> Void
    let onReset: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    // Grid layout: two columns for a spacious and touch-friendly feel
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]

    var body: some View {
        VStack(spacing: 24) {
            
            // 1. HEADER (Title + Reset Button)
            // Replaces the standard NavigationBar for a cleaner look
            HStack {
                Text("Filter Sports")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Reset Button "Glass Capsule"
                Button(action: {
                    withAnimation(.spring()) {
                        onReset()
                    }
                }) {
                    Text("Reset")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(
                            Capsule().stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                        )
                }
            }
            .padding(.top, 20)
            
            // 2. CATEGORIES GRID
            ScrollView {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(SHSportCategory.allCases) { category in
                        FilterOptionButton(
                            category: category,
                            isSelected: selected.contains(category),
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    onToggle(category)
                                }
                            }
                        )
                    }
                }
                .padding(.vertical, 10)
            }
            
            // 3. FOOTER INFO
            Text("Select at least one category to see results.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
    }
}

// MARK: - FILTER BUTTON DESIGN (Liquid Glass)
struct FilterOptionButton: View {
    let category: SHSportCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Large Icon
                Image(systemName: category.systemImage)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .white : .blue)
                
                // Category Name
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110) // Fixed height for uniformity
            
            // DYNAMIC BACKGROUND
            .background {
                if isSelected {
                    // ACTIVE State: Solid Blue Color
                    Color.blue
                } else {
                    // INACTIVE State: Liquid Glass
                    Rectangle()
                        .fill(.ultraThinMaterial)
                }
            }
            // ROUNDED CORNERS (Apple Style)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
            // THIN BORDER (Only if not selected)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isSelected ? Color.clear : Color.primary.opacity(0.1), lineWidth: 1)
            )
            // SHADOW
            .shadow(color: isSelected ? .blue.opacity(0.3) : .black.opacity(0.05), radius: 8, x: 0, y: 4)
            // ZOOM SELECTION EFFECT
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(ScaleButtonStyle()) // Touch animation
    }
}

// Helper for button press animation
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        SHFiltersSheet(
            selected: [.soccer, .tennis],
            onToggle: { _ in },
            onReset: {}
        )
        .background(.ultraThinMaterial)
    }
}
