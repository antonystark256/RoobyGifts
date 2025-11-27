import SwiftUI
import RealmSwift

// MARK: - ACHIEVEMENTS VIEW
struct AchievementsView: View {
    @ObservedResults(AchievementObject.self) var achievements
    
    // 8 Mock Achievements (Visual only, locked forever)
    let mockAchievements: [MockAchievement] = [
        MockAchievement(title: "Big Spender", desc: "Spend over $500 in gifts", icon: "banknote"),
        MockAchievement(title: "Early Bird", desc: "Create a wishlist in October", icon: "alarm"),
        MockAchievement(title: "Santa's Helper", desc: "Complete 3 Secret Santa games", icon: "person.3.fill"),
        MockAchievement(title: "Gift Wrapper", desc: "Mark 10 gifts as bought", icon: "shippingbox.fill"),
        MockAchievement(title: "Generous Soul", desc: "Add 20 items to wishlists", icon: "heart.circle.fill"),
        MockAchievement(title: "Trendsetter", desc: "Open Trends tab 50 times", icon: "flame.fill"),
        MockAchievement(title: "Planner", desc: "Add 10 events to calendar", icon: "calendar.badge.plus"),
        MockAchievement(title: "Legend", desc: "Unlock all other achievements", icon: "crown.fill")
    ]
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                // Header
                VStack(spacing: 8) {
                    Kangaroo.winner.image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .shadow(color: .appGold.opacity(0.3), radius: 15)
                    
                    Text("Hall of Fame")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text("Unlock badges by using the app!")
                        .font(.body)
                        .foregroundColor(.appTextSecondary)
                }
                .padding(.vertical, 20)
                
                // Grid
                LazyVGrid(columns: columns, spacing: 16) {
                    // 1. Real Realm Achievements
                    ForEach(achievements) { item in
                        AchievementCard(
                            title: item.title,
                            desc: item.desc,
                            icon: item.iconName,
                            current: item.currentProgress,
                            target: item.targetProgress,
                            isUnlocked: item.isUnlocked
                        )
                    }
                    
                    // 2. Mock Achievements
                    ForEach(mockAchievements) { item in
                        AchievementCard(
                            title: item.title,
                            desc: item.desc,
                            icon: item.icon,
                            current: 0,
                            target: 1, // Dummy target
                            isUnlocked: false
                        )
                    }
                }
                .padding(16)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - MOCK DATA MODEL
struct MockAchievement: Identifiable {
    let id = UUID()
    let title: String
    let desc: String
    let icon: String
}

// MARK: - ACHIEVEMENT CARD
struct AchievementCard: View {
    let title: String
    let desc: String
    let icon: String
    let current: Int
    let target: Int
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.appGold : Color.black.opacity(0.3))
                    .frame(width: 70, height: 70)
                    .shadow(color: isUnlocked ? .appGold.opacity(0.5) : .clear, radius: 10)
                
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(isUnlocked ? .black : .gray)
                
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                        .offset(x: 20, y: 20)
                }
            }
            .grayscale(isUnlocked ? 0 : 0.5)
            
            // Text Info
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isUnlocked ? .white : .gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                
                Text(desc)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(2)
                    .frame(height: 32) // Fixed height for alignment
            }
            
            // Progress or Badge
            if isUnlocked {
                Text("UNLOCKED")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.appGold)
                    .cornerRadius(8)
            } else {
                // Progress Bar
                VStack(spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.black.opacity(0.4))
                                .frame(height: 6)
                            
                            Capsule()
                                .fill(Color.appPurple)
                                .frame(width: geo.size.width * (Double(current) / Double(target)), height: 6)
                        }
                    }
                    .frame(height: 6)
                    
                    Text("\(current) / \(target)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 8)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.appCard)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isUnlocked ? Color.appGold.opacity(0.5) : Color.white.opacity(0.05), lineWidth: 1)
        )
        // Dim the locked cards slightly
        .opacity(isUnlocked ? 1.0 : 0.7)
    }
}
