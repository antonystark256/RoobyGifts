import SwiftUI
import RealmSwift

// MARK: - WISHLIST LIST (MAIN TAB)
struct WishlistRootView: View {
    @ObservedResults(WishlistObject.self) var wishlists
    @Environment(\.realm) var realm // <--- Добавили Environment Realm для записи
    
    @State private var showCreateSheet = false
    @State private var newTitle = ""
    @State private var newSubtitle = ""
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.appBackground.ignoresSafeArea()
            
            if wishlists.isEmpty {
                // Empty State
                VStack(spacing: 24) {
                    Spacer()
                    
                    Kangaroo.waving.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220)
                    
                    VStack(spacing: 12) {
                        Text("No wishlists yet!")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.appTextPrimary)
                        
                        Text("Create your first wishlist to start collecting gift ideas.")
                            .font(.body)
                            .foregroundColor(.appTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    
                    Button {
                        showCreateSheet = true
                    } label: {
                        Text("Create Wishlist")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 30)
                            .background(Color.appPurple)
                            .cornerRadius(25)
                            .shadow(color: .appPurple.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    
                    Spacer()
                    Color.clear.frame(height: 80) // Spacer for tabbar
                }
            } else {
                // List State
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(wishlists) { wishlist in
                            NavigationLink(value: wishlist) {
                                WishlistCard(wishlist: wishlist)
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 100) // Padding for Floating TabBar
                }
            }
            
            // FAB
            if !wishlists.isEmpty {
                Button {
                    showCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(.black)
                        .frame(width: 56, height: 56)
                        .background(Color.appPurple)
                        .clipShape(Circle())
                        .shadow(color: .appPurple.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding()
                .padding(.bottom, 100) // Lift above tabbar
            }
        }
        .navigationTitle("My Wishlists")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(for: WishlistObject.self) { wishlist in
            WishlistDetailView(wishlist: wishlist)
        }
        .sheet(isPresented: $showCreateSheet) {
            ZStack {
                Color.appCard.ignoresSafeArea()
                NavigationStack {
                    Form {
                        Section {
                            TextField("Title", text: $newTitle)
                            TextField("Description", text: $newSubtitle)
                        }
                        .listRowBackground(Color.appBackground)
                        .listRowSeparatorTint(Color.white.opacity(0.2))
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.appCard)
                    .navigationTitle("New Wishlist")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showCreateSheet = false }
                                .foregroundColor(.appTextSecondary)
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Create") { createWishlist() }
                                .disabled(newTitle.isEmpty)
                                .foregroundColor(.appPurple)
                        }
                    }
                }
            }
            .presentationDetents([.height(300)])
        }
    }
    
    private func createWishlist() {
        let newList = WishlistObject(title: newTitle, subtitle: newSubtitle)
        
        // FIX: Используем environment realm для записи
        try? realm.write {
            // 1. Добавляем новый список
            realm.add(newList)
            
            // 2. Обновляем ачивку в той же транзакции
            if let achievement = realm.objects(AchievementObject.self).filter("key == 'first_wishlist'").first {
                achievement.currentProgress = 1
                achievement.isUnlocked = true
                achievement.unlockedAt = Date()
            }
        }
        
        newTitle = ""
        newSubtitle = ""
        showCreateSheet = false
    }
}

// MARK: - WISHLIST CARD (Dark Mode)
struct WishlistCard: View {
    @ObservedRealmObject var wishlist: WishlistObject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Preview Images
            HStack(spacing: 4) {
                if let firstGift = wishlist.gifts.first,
                   let path = firstGift.imagePath,
                   let img = ImageHelper.shared.loadImage(named: path) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .clipped()
                } else {
                    Color.appBackground // Darker background for placeholder
                        .frame(height: 100)
                        .overlay(
                            Image(systemName: "gift")
                                .font(.largeTitle)
                                .foregroundColor(.appPurple.opacity(0.5))
                        )
                }
            }
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(wishlist.title)
                    .font(.headline)
                    .foregroundColor(.appTextPrimary) // White text
                    .lineLimit(1)
                
                Text("\(wishlist.gifts.count) gifts")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary) // Grey text
            }
        }
        .padding(12)
        .background(Color.appCard) // Dark Grey Card
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
    }
}
