//
//  BottomTabBar.swift
//  SportHUB
//
//  Created by Foundation 8 on 29/01/26.
//

import SwiftUI
import UIKit

// MARK: - Root Tabs

enum SHRootTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case map = "Map"
    case reviews = "Reviews"
    case explore = "Explore"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .home: return "house"
        case .map: return "map"
        case .reviews: return "doc.text"
        case .explore: return "magnifyingglass"
        }
    }
}

// MARK: - Root View (this replaces TabView)

struct SHRootView: View {
    @State private var selectedTab: SHRootTab = .map

    var body: some View {
        ZStack {
            // Screen content
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .map:
                    SHMapScreen()   // <-- your Map screen
                case .reviews:
                    ReviewsView()
                case .explore:
                    ExploreView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Liquid glass tab bar overlay
            VStack {
                Spacer()
                SHLiquidTabBar(selected: $selectedTab)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 18)
            }
        }
    }
}

// MARK: - Liquid Glass Tab Bar + Bump

private struct SHLiquidTabBar: View {
    @Binding var selected: SHRootTab
    @Namespace private var ns
    @State private var pressedTab: SHRootTab? = nil

    var body: some View {
        HStack(spacing: 8) {
            ForEach(SHRootTab.allCases) { tab in
                tabButton(tab)
            }
        }
        .padding(10)
        .background(glassBackground)
        .animation(.spring(response: 0.38, dampingFraction: 0.78), value: selected)
    }

    private func tabButton(_ tab: SHRootTab) -> some View {
        let isSelected = (tab == selected)
        let isPressed = (tab == pressedTab)

        return Button {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                selected = tab
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    // “Liquid pill” that slides between tabs
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(.white.opacity(0.35), lineWidth: 1)
                            )
                            .matchedGeometryEffect(id: "tabPill", in: ns)
                            .frame(height: 44)
                            .shadow(radius: 10)
                    }

                    Image(systemName: tab.systemImage)
                        .font(.system(size: 18, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                        .scaleEffect(isSelected ? 1.12 : 1.0) // bump
                        .offset(y: isSelected ? -2 : 0)      // bump
                }
                .frame(height: 44)

                Text(tab.rawValue)
                    .font(.caption2)
                    .opacity(isSelected ? 1.0 : 0.85)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .foregroundStyle(isSelected ? .primary : .secondary)
            .scaleEffect(isPressed ? 0.96 : 1.0) // gel press
            .animation(.spring(response: 0.22, dampingFraction: 0.6), value: isPressed)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressedTab = tab }
                .onEnded { _ in pressedTab = nil }
        )
    }

    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(.white.opacity(0.35), lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.38), .white.opacity(0.10), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .allowsHitTesting(false)
            )
            .shadow(radius: 18)
    }
}

// MARK: - Placeholder Screens (remove if your project already has them)

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Home").font(.title.bold())
                Text("Placeholder").foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Home")
        }
    }
}

struct ReviewsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Reviews").font(.title.bold())
                Text("Placeholder").foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Reviews")
        }
    }
}

struct ExploreView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Explore").font(.title.bold())
                Text("Placeholder").foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Explore")
        }
    }
}

// MARK: - Preview

#Preview {
    SHRootView()
}
