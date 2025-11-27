import SwiftUI

// MARK: - FUN ROOT VIEW
struct FunRootView: View {
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Fun & Gifts")
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundColor(.white)
                                Text("Tools & Achievements")
                                    .font(.subheadline)
                                    .foregroundColor(.appTextSecondary)
                            }
                            Spacer()
                            
                            // Settings Button
                            Button {
                                showSettings.toggle()
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                    .foregroundColor(.appTextSecondary)
                                    .padding(10)
                                    .background(Color.appCard)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Menu Grid
                        LazyVGrid(columns: [GridItem(.flexible())], spacing: 20) {
                            
                            // 1. Secret Santa (Large Card)
                            NavigationLink(destination: SecretSantaListView()) {
                                FunMenuCard(
                                    title: "Secret Santa",
                                    subtitle: "Organize your gift exchange",
                                    icon: "gift.fill",
                                    color: .appPurple,
                                    mascot: Kangaroo.holdingGift.image
                                )
                            }
                            
                            // 2. Certificates
                            NavigationLink(destination: CertificateListView()) {
                                FunMenuCard(
                                    title: "Certificates",
                                    subtitle: "Don't let them expire!",
                                    icon: "ticket.fill",
                                    color: .appYellow,
                                    mascot: Kangaroo.withTablet.image
                                )
                            }
                            
                            // 3. Achievements
                            NavigationLink(destination: AchievementsView()) {
                                FunMenuCard(
                                    title: "Achievements",
                                    subtitle: "Track your progress",
                                    icon: "trophy.fill",
                                    color: .appGold,
                                    mascot: Kangaroo.winner.image
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 120) // Space for TabBar
                }
                
                // Floating Mascot Hint
//                Kangaroo.head.image
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 60)
//                    .padding(.bottom, 100)
//                    .padding(.trailing, 20)
//                    .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 5)
            }
            .navigationBarHidden(true)
            // MARK: - PRESENT SETTINGS
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}

// MARK: - STYLISH MENU CARD (Same as before)
struct FunMenuCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let mascot: Image?
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 12) {
                // Icon Container
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Spacer()
            
            // Mascot or Arrow
            if let mascot = mascot {
                mascot
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .offset(x: 10, y: 10)
            } else {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundColor(.appCard.opacity(0.5))
                    .padding()
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
        }
        .padding(20)
        .frame(height: 150)
        .background(Color.appCard)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        .clipped()
    }
}
