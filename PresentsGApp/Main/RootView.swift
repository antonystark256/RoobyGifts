import SwiftUI

// MARK: - APP TAB ENUM
enum AppTab: Int, CaseIterable {
    case wishlists = 0
    case ai
    case trends
    case calendar
    case fun
    
    var icon: String {
        switch self {
        case .wishlists: return "heart.text.square.fill"
        case .ai: return "sparkles"
        case .trends: return "flame.fill"
        case .calendar: return "calendar"
        case .fun: return "gamecontroller.fill"
        }
    }
}

// MARK: - ROOT CONTENT VIEW
struct RootView: View {
    @State private var selectedTab: AppTab = .wishlists
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Background
                Color.appBackground.ignoresSafeArea()
                
                // Content Layer
                Group {
                    switch selectedTab {
                    case .wishlists:
                        WishlistRootView()
                    case .ai:
                        AIGiftRootView()
                    case .trends:
                        TrendsRootView()
                    case .calendar:
                        CalendarRootView()
                    case .fun:
                        FunRootView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Floating Tab Bar Layer
                VStack {
                    Spacer()
                    FloatingTabBar(selectedTab: $selectedTab)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20) // Lift up from bottom edge
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .preferredColorScheme(.dark) // Force Dark Mode
    }
}

// MARK: - FLOATING TAB BAR
struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab
    @Namespace private var animationNamespace
    
    var body: some View {
        HStack {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                } label: {
                    ZStack {
                        if selectedTab == tab {
                            Circle()
                                .fill(Color.appPurple)
                                .matchedGeometryEffect(id: "ActiveTab", in: animationNamespace)
                                .frame(width: 48, height: 48)
                                .shadow(color: .appPurple.opacity(0.5), radius: 8, x: 0, y: 4)
                        }
                        
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(selectedTab == tab ? .black : .gray)
                            .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                }
            }
        }
        .padding(6)
        .background(
            Capsule()
                .fill(Color.appCard)
                .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
        )
    }
}
