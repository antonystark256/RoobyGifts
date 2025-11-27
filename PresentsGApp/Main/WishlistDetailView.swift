import SwiftUI
import RealmSwift

// MARK: - WISHLIST DETAIL VIEW
struct WishlistDetailView: View {
    @ObservedRealmObject var wishlist: WishlistObject
    @Environment(\.realm) var realm
    @Environment(\.dismiss) var dismiss
    
    @State private var showAddGiftSheet = false
    @State private var giftToEdit: GiftObject?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - CUSTOM HEADER
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(wishlist.subtitle.isEmpty ? "No description" : wishlist.subtitle)
                            .font(.body)
                            .foregroundColor(.appTextSecondary)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Stats Bar
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "gift.fill")
                                .foregroundColor(.appPurple)
                            Text("\(wishlist.gifts.count) items")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.appCard)
                        .cornerRadius(10)
                        
                        Spacer()
                        
                        Text("Total: $\(calculateTotal(), specifier: "%.0f")")
                            .font(.headline)
                            .foregroundColor(.appTextPrimary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                .background(Color.appBackground)
                
                // MARK: - LIST
                if wishlist.gifts.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Kangaroo.standing.image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180)
                            .opacity(0.8)
                        Text("This wishlist is empty")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                        Text("Add your first gift idea!")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(wishlist.gifts) { gift in
                            GiftRow(gift: gift, onToggle: { toggleGift(gift) })
                                .onTapGesture {
                                    giftToEdit = gift
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteGift(gift)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        giftToEdit = gift
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.orange)
                                }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .padding(.bottom, 80) // Space for TabBar
                }
            }
            
            // FAB
            Button {
                showAddGiftSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundColor(.black)
                    .frame(width: 60, height: 60)
                    .background(Color.appPurple)
                    .clipShape(Circle())
                    .shadow(color: .appPurple.opacity(0.5), radius: 10, x: 0, y: 5)
            }
            .padding()
            .padding(.bottom, 30)
        }
        .navigationTitle(wishlist.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .sheet(isPresented: $showAddGiftSheet) {
            GiftFormView(wishlist: wishlist)
        }
        .sheet(item: $giftToEdit) { gift in
            GiftFormView(giftToEdit: gift)
        }
    }
    
    private func calculateTotal() -> Double {
        wishlist.gifts.reduce(0) { $0 + $1.price }
    }
    
    // Безопасное удаление
    private func deleteGift(_ gift: GiftObject) {
        if let index = wishlist.gifts.firstIndex(of: gift) {
            $wishlist.gifts.remove(at: index)
        }
    }
    
    // Безопасное переключение статуса
    private func toggleGift(_ gift: GiftObject) {
        try? realm.write {
            if let liveGift = gift.thaw() {
                liveGift.isPurchased.toggle()
            }
        }
    }
}

// MARK: - GIFT ROW COMPONENT
struct GiftRow: View {
    @ObservedRealmObject var gift: GiftObject
    var onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // 1. Checkbox Area
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .stroke(gift.isPurchased ? Color.green : Color.gray, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if gift.isPurchased {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .buttonStyle(.plain)
            
            // 2. Image
            if let path = gift.imagePath, let uiImage = ImageHelper.shared.loadImage(named: path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .grayscale(gift.isPurchased ? 1.0 : 0.0) // Optional effect
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appBackground)
                    Image(systemName: "gift.fill")
                        .font(.title2)
                        .foregroundColor(.appPurple.opacity(0.4))
                }
                .frame(width: 60, height: 60)
            }
            
            // 3. Info
            VStack(alignment: .leading, spacing: 4) {
                Text(gift.title)
                    .font(.headline)
                    .foregroundColor(gift.isPurchased ? .gray : .white)
                    .strikethrough(gift.isPurchased)
                
                if !gift.details.isEmpty {
                    Text(gift.details)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // 4. Price & Link
            VStack(alignment: .trailing, spacing: 6) {
                if gift.price > 0 {
                    Text("$\(gift.price, specifier: "%.0f")")
                        .font(.subheadline)
                        .bold()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(gift.isPurchased ? Color.gray.opacity(0.2) : Color.appPurple.opacity(0.2))
                        .foregroundColor(gift.isPurchased ? .gray : .appPurple)
                        .cornerRadius(8)
                }
                
                if let link = gift.webLink, !link.isEmpty {
                    Image(systemName: "link")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(16)
        .background(Color.appCard)
        .cornerRadius(16)
        // Dim opacity if bought
        .opacity(gift.isPurchased ? 0.6 : 1.0)
        // Shadow for depth
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}
