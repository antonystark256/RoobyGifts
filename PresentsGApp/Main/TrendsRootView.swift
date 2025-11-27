import SwiftUI

// MARK: - TRENDS DATA MODEL
struct TrendItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let price: String
    let imageName: String // System symbol
    let searchQuery: String
}

struct TrendCategory: Identifiable {
    let id = UUID()
    let title: String
    let items: [TrendItem]
}

// MARK: - MOCK DATA SERVICE
class TrendsDataService {
    static func getCategories() -> [TrendCategory] {
        return [
            TrendCategory(title: "Under $20", items: [
                TrendItem(title: "Funny Socks", price: "$12", imageName: "tshirt", searchQuery: "funny socks gift"),
                TrendItem(title: "Desk Plant", price: "$15", imageName: "leaf", searchQuery: "desk plant pot"),
                TrendItem(title: "Notebook", price: "$18", imageName: "book", searchQuery: "premium notebook"),
                TrendItem(title: "Phone Stand", price: "$10", imageName: "iphone", searchQuery: "phone desk stand"),
                TrendItem(title: "Mug Warmer", price: "$19", imageName: "cup.and.saucer", searchQuery: "usb mug warmer")
            ]),
            TrendCategory(title: "Gadgets", items: [
                TrendItem(title: "Wireless Earbuds", price: "$49", imageName: "airpods", searchQuery: "budget wireless earbuds"),
                TrendItem(title: "Smart Tag", price: "$29", imageName: "tag", searchQuery: "smart tracker tag"),
                TrendItem(title: "Portable Charger", price: "$35", imageName: "battery.100", searchQuery: "power bank 10000mah"),
                TrendItem(title: "Mini Speaker", price: "$40", imageName: "hifispeaker", searchQuery: "bluetooth mini speaker")
            ]),
            TrendCategory(title: "For Him", items: [
                TrendItem(title: "Grooming Kit", price: "$45", imageName: "scissors", searchQuery: "men grooming kit"),
                TrendItem(title: "Leather Wallet", price: "$50", imageName: "creditcard", searchQuery: "leather wallet men"),
                TrendItem(title: "BBQ Set", price: "$60", imageName: "flame", searchQuery: "bbq tool set"),
                TrendItem(title: "Craft Beer Glass", price: "$25", imageName: "mug", searchQuery: "craft beer glasses")
            ]),
            TrendCategory(title: "For Her", items: [
                TrendItem(title: "Scented Candle", price: "$22", imageName: "flame.fill", searchQuery: "luxury scented candle"),
                TrendItem(title: "Silk Scarf", price: "$35", imageName: "wind", searchQuery: "silk scarf women"),
                TrendItem(title: "Bath Bombs", price: "$18", imageName: "drop", searchQuery: "bath bomb set"),
                TrendItem(title: "Jewelry Box", price: "$40", imageName: "square.grid.2x2", searchQuery: "travel jewelry box")
            ]),
            TrendCategory(title: "Home & Cozy", items: [
                TrendItem(title: "Weighted Blanket", price: "$70", imageName: "bed.double", searchQuery: "weighted blanket"),
                TrendItem(title: "Diffuser", price: "$30", imageName: "humidity", searchQuery: "essential oil diffuser"),
                TrendItem(title: "Board Game", price: "$40", imageName: "gamecontroller", searchQuery: "popular board games 2024")
            ])
        ]
    }
}

// MARK: - MAIN TRENDS VIEW
struct TrendsRootView: View {
    let categories = TrendsDataService.getCategories()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Banner / Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Gift Trends")
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundColor(.appTextPrimary)
                                Text("Popular ideas this month")
                                    .font(.subheadline)
                                    .foregroundColor(.appTextSecondary)
                            }
                            Spacer()
                            Kangaroo.winner.image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 80)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Categories
                        ForEach(categories) { category in
                            TrendCategorySection(category: category)
                        }
                    }
                    .padding(.bottom, 120) // TabBar padding
                }
            }
            .navigationTitle("Trends")
            .navigationBarHidden(true)
        }
    }
}

// MARK: - CATEGORY SECTION
struct TrendCategorySection: View {
    let category: TrendCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(category.title)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.appTextPrimary)
                
                Spacer()
                
                NavigationLink(destination: CategoryListView(category: category)) {
                    Text("See all")
                        .font(.subheadline)
                        .foregroundColor(.appPurple)
                }
            }
            .padding(.horizontal)
            
            // Horizontal List
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(category.items) { item in
                        TrendCard(item: item)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - TREND CARD (Small - Horizontal)
struct TrendCard: View {
    let item: TrendItem
    
    var body: some View {
        Button {
            openSearch(query: item.searchQuery)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Image Area
                ZStack(alignment: .bottomTrailing) {
                    // Background for Icon
                    Rectangle()
                        .fill(Color.appBackground) // Slightly darker than card
                        .frame(height: 120)
                    
                    // Icon
                    Image(systemName: item.imageName)
                        .font(.system(size: 40))
                        .foregroundColor(.appPurple)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Search Bubble
                    Image(systemName: "magnifyingglass")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Circle().fill(Color.appPurple))
                        .padding(8)
                }
                .frame(width: 150, height: 120)
                
                // Info Area
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(item.price)
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                }
                .padding(12)
                .frame(width: 150, alignment: .leading)
                .background(Color.appCard)
            }
            .cornerRadius(16)
            // Border stroke to make it pop on dark bg
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // FIX: Using URLComponents for safe searching
    private func openSearch(query: String) {
        var components = URLComponents(string: "https://www.google.com/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query)
        ]
        
        if let url = components?.url {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - SEE ALL VIEW (Grid)
struct CategoryListView: View {
    let category: TrendCategory
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(category.items) { item in
                        TrendBigCard(item: item)
                    }
                }
                .padding()
                .padding(.bottom, 100)
            }
        }
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - TREND BIG CARD (Grid Item)
struct TrendBigCard: View {
    let item: TrendItem
    
    var body: some View {
        Button {
            openSearch(query: item.searchQuery)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Image Area
                ZStack {
                    Color.appBackground
                    Image(systemName: item.imageName)
                        .font(.system(size: 50))
                        .foregroundColor(.appPurple)
                }
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                
                // Text Area
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    HStack {
                        Text(item.price)
                            .font(.subheadline)
                            .foregroundColor(.appYellow) // Gold/Teal accent for price
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(12)
                .background(Color.appCard)
            }
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // FIX: Using URLComponents for safe searching
    private func openSearch(query: String) {
        var components = URLComponents(string: "https://www.google.com/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query)
        ]
        
        if let url = components?.url {
            UIApplication.shared.open(url)
        }
    }
}
