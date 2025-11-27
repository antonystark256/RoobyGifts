import SwiftUI
import RealmSwift
import PhotosUI

// MARK: - GIFT FORM VIEW
struct GiftFormView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.realm) var realm
    
    var wishlist: WishlistObject? // Parent wishlist (Frozen from UI)
    var giftToEdit: GiftObject?   // Gift to edit (Frozen from UI)
    
    @State private var title: String = ""
    @State private var details: String = ""
    @State private var priceString: String = ""
    @State private var webLink: String = ""
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    
    init(wishlist: WishlistObject? = nil, giftToEdit: GiftObject? = nil) {
        self.wishlist = wishlist
        self.giftToEdit = giftToEdit
        
        if let gift = giftToEdit {
            _title = State(initialValue: gift.title)
            _details = State(initialValue: gift.details)
            _priceString = State(initialValue: String(format: "%.2f", gift.price))
            _webLink = State(initialValue: gift.webLink ?? "")
            if let path = gift.imagePath {
                _selectedImage = State(initialValue: ImageHelper.shared.loadImage(named: path))
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.appCard.ignoresSafeArea() // Background for the sheet
            
            NavigationStack {
                Form {
                    Section("Info") {
                        TextField("Gift Name", text: $title)
                            .foregroundColor(.white)
                        TextField("Description / Notes", text: $details, axis: .vertical)
                            .foregroundColor(.white)
                            .lineLimit(3...6)
                    }
                    .listRowBackground(Color.appBackground)
                    
                    Section("Price & Link") {
                        TextField("Price", text: $priceString)
                            .keyboardType(.decimalPad)
                            .foregroundColor(.white)
                        TextField("URL (https://...)", text: $webLink)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .foregroundColor(.blue)
                    }
                    .listRowBackground(Color.appBackground)
                    
                    Section("Photo") {
                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(12)
                                .listRowBackground(Color.clear)
                        }
                        
                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            Label(selectedImage == nil ? "Add Photo" : "Change Photo", systemImage: "photo")
                                .foregroundColor(.appPurple)
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    selectedImage = uiImage
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.appBackground)
                }
                .scrollContentBackground(.hidden) // Remove default gray system background
                .background(Color.appCard)
                .navigationTitle(giftToEdit == nil ? "New Gift" : "Edit Gift")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .foregroundColor(.appTextSecondary)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { saveGift() }
                            .disabled(title.isEmpty)
                            .foregroundColor(.appPurple)
                    }
                }
            }
        }
    }
    
    private func saveGift() {
        // Prepare data
        var imagePath: String? = giftToEdit?.imagePath
        
        // Save new image if exists
        if let selectedImage, selectedImage != ImageHelper.shared.loadImage(named: imagePath ?? "") {
            imagePath = ImageHelper.shared.saveImage(selectedImage)
        }
        
        let price = Double(priceString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        // WRITE TRANSACTION
        try? realm.write {
            if let gift = giftToEdit, let liveGift = gift.thaw() {
                // UPDATE EXISTING (Using thaw() to get writable object)
                liveGift.title = title
                liveGift.details = details
                liveGift.price = price
                liveGift.webLink = webLink.isEmpty ? nil : webLink
                liveGift.imagePath = imagePath
                
            } else if let wishlist = wishlist, let liveWishlist = wishlist.thaw() {
                // CREATE NEW (Using thaw() on parent wishlist)
                let newGift = GiftObject(title: title, details: details, price: price)
                newGift.webLink = webLink.isEmpty ? nil : webLink
                newGift.imagePath = imagePath
                
                liveWishlist.gifts.append(newGift)
            }
        }
        
        // Check achievements AFTER writing gift (separate transaction logic inside)
        if giftToEdit == nil {
            checkAchievement()
        }
        
        dismiss()
    }
    
    private func checkAchievement() {
        // Safe check for achievements
        if let achievement = realm.objects(AchievementObject.self).filter("key == 'five_gifts'").first {
            let totalGifts = realm.objects(GiftObject.self).count
            
            try? realm.write {
                // Thaw achievement just in case, though usually results from realm.objects are live if not frozen explicitly
                if let liveAchievement = achievement.thaw() {
                    liveAchievement.currentProgress = totalGifts
                    if liveAchievement.currentProgress >= liveAchievement.targetProgress {
                        liveAchievement.isUnlocked = true
                        liveAchievement.unlockedAt = Date()
                    }
                }
            }
        }
    }
}
