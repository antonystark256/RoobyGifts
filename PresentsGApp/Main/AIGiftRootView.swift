import SwiftUI
import RealmSwift

// MARK: - AI GIFT ROOT VIEW
struct AIGiftRootView: View {
    @Environment(\.realm) var realm
    
    // Inputs
    @State private var gender: String = "Any"
    @State private var age: String = ""
    @State private var budget: String = "Medium ($20-$100)"
    @State private var event: String = "Birthday"
    @State private var interests: String = ""
    @State private var character: String = ""
    
    // State
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var suggestions: [AIGiftSuggestion] = []
    @State private var showHistory = false
    @State private var itemToAdd: AIGiftSuggestion?
    
    // Data Sources
    let genders = ["Any", "Male", "Female"]
    let budgets = ["Low (<$20)", "Medium ($20-$100)", "High ($100+)", "Luxury"]
    let events = ["Birthday", "Christmas", "Anniversary", "Valentine's", "Wedding", "Just Because"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                if isLoading {
                    LoadingView()
                } else if !suggestions.isEmpty {
                    ResultsView(
                        suggestions: suggestions,
                        onReset: reset,
                        onAddToWishlist: { item in itemToAdd = item }
                    )
                } else {
                    InputFormView(
                        gender: $gender,
                        age: $age,
                        budget: $budget,
                        event: $event,
                        interests: $interests,
                        character: $character,
                        genders: genders,
                        budgets: budgets,
                        events: events,
                        onGenerate: generate
                    )
                }
                
                // Error Overlay
                if let error = errorMessage {
                    ErrorView(message: error, onRetry: {
                        errorMessage = nil
                        generate()
                    }, onCancel: {
                        errorMessage = nil
                    })
                }
            }
            .navigationTitle("Gift Genius")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                if suggestions.isEmpty && !isLoading {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("History") { showHistory = true }
                            .foregroundColor(.appPurple)
                    }
                }
            }
            .sheet(isPresented: $showHistory) {
                HistoryView()
            }
            .sheet(item: $itemToAdd) { item in
                AddToWishlistSheet(item: item)
            }
        }
    }
    
    private func generate() {
        guard !age.isEmpty, !interests.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let results = try await GeminiService.shared.generateGiftIdeas(
                    age: age,
                    gender: gender,
                    budget: budget,
                    event: event,
                    interests: interests,
                    character: character
                )
                
                await MainActor.run {
                    self.suggestions = results
                    self.isLoading = false
                    saveToHistory(results: results)
                    checkAchievement()
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "AI Brain Freeze! Please check your connection and API Key."
                    print("Error: \(error)")
                }
            }
        }
    }
    
    private func reset() {
        withAnimation {
            suggestions = []
        }
    }
    
    private func saveToHistory(results: [AIGiftSuggestion]) {
        let historyItem = AIGiftResultObject()
        historyItem.querySummary = "\(event) for \(gender), \(age)y"
        
        // FIX: Explicitly use RealmSwift.List to avoid conflict with SwiftUI.List
        let list = RealmSwift.List<String>()
        list.append(objectsIn: results.map { $0.item })
        historyItem.suggestedGifts = list
        
        try? realm.write {
            realm.add(historyItem)
        }
    }
    
    private func checkAchievement() {
        if let achievement = realm.objects(AchievementObject.self).filter("key == 'first_ai'").first {
            try? realm.write {
                if let liveAchieve = achievement.thaw() {
                    liveAchieve.currentProgress = 1
                    liveAchieve.isUnlocked = true
                    liveAchieve.unlockedAt = Date()
                }
            }
        }
    }
}

// MARK: - INPUT FORM VIEW (REDESIGNED)
struct InputFormView: View {
    @Binding var gender: String
    @Binding var age: String
    @Binding var budget: String
    @Binding var event: String
    @Binding var interests: String
    @Binding var character: String
    
    let genders: [String]
    let budgets: [String]
    let events: [String]
    let onGenerate: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // 1. Header Card
                HStack(spacing: 16) {
                    Kangaroo.idea.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80)
                    
                    Text("Tell me about the person, and I'll find the perfect gift!")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.appCard)
                .cornerRadius(16)
                
                // 2. Persona Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Who is it for?")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        // Age Input
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Age")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            TextField("e.g. 25", text: $age)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.appBackground)
                                .cornerRadius(12)
                                .foregroundColor(.white)
                        }
                        .frame(width: 100)
                        
                        // Gender Picker
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Gender")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Menu {
                                ForEach(genders, id: \.self) { g in
                                    Button(g) { gender = g }
                                }
                            } label: {
                                HStack {
                                    Text(gender)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.appPurple)
                                }
                                .padding()
                                .background(Color.appBackground)
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    // Interests
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Interests & Hobbies")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("e.g. Gaming, Cooking, Sci-Fi", text: $interests)
                            .padding()
                            .background(Color.appBackground)
                            .cornerRadius(12)
                            .foregroundColor(.white)
                    }
                    
                    // Character
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Personality")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("e.g. Introvert, Creative, Funny", text: $character)
                            .padding()
                            .background(Color.appBackground)
                            .cornerRadius(12)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.appCard)
                .cornerRadius(20)
                
                // 3. Context Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Context")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    // Event Picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Event")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Menu {
                            ForEach(events, id: \.self) { e in
                                Button(e) { event = e }
                            }
                        } label: {
                            HStack {
                                Text(event)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "calendar")
                                    .foregroundColor(.appPurple)
                            }
                            .padding()
                            .background(Color.appBackground)
                            .cornerRadius(12)
                        }
                    }
                    
                    // Budget Picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Budget")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Menu {
                            ForEach(budgets, id: \.self) { b in
                                Button(b) { budget = b }
                            }
                        } label: {
                            HStack {
                                Text(budget)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "dollarsign.circle")
                                    .foregroundColor(.appPurple)
                            }
                            .padding()
                            .background(Color.appBackground)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
                .background(Color.appCard)
                .cornerRadius(20)
                
                // 4. Action Button
                Button(action: onGenerate) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Find Perfect Gifts")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(colors: [.appPurple, .appPurple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(16)
                    .shadow(color: .appPurple.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .disabled(age.isEmpty || interests.isEmpty)
                .opacity(age.isEmpty || interests.isEmpty ? 0.5 : 1.0)
                .padding(.bottom, 100)
            }
            .padding()
        }
    }
}

// MARK: - RESULTS VIEW (REDESIGNED)
struct ResultsView: View {
    let suggestions: [AIGiftSuggestion]
    let onReset: () -> Void
    let onAddToWishlist: (AIGiftSuggestion) -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text("Here are 5 ideas!")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                Spacer()
                Button {
                    onReset()
                } label: {
                    Text("New Search")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.appCard)
                        .cornerRadius(8)
                        .foregroundColor(.appPurple)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(suggestions) { item in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top) {
                                Text(item.item)
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.white)
                                Spacer()
                                Text(item.price_range)
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.black)
                                    .padding(6)
                                    .background(Color.appYellow)
                                    .cornerRadius(8)
                            }
                            
                            Text(item.description)
                                .font(.body)
                                .foregroundColor(.appTextSecondary)
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                            
                            HStack {
                                Button {
                                    if let url = URL(string: "https://www.google.com/search?q=\(item.item.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    Label("Find Online", systemImage: "safari")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                
                                Spacer()
                                
                                Button {
                                    onAddToWishlist(item)
                                } label: {
                                    Label("Add to Wishlist", systemImage: "heart.fill")
                                        .font(.caption)
                                        .foregroundColor(.appPurple)
                                }
                            }
                        }
                        .padding()
                        .background(Color.appCard)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.2), radius: 5, y: 2)
                    }
                }
                .padding()
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - LOADING & ERROR
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            Kangaroo.withTablet.image
                .resizable()
                .scaledToFit()
                .frame(width: 150)
            
            ProgressView()
                .tint(.appPurple)
                .scaleEffect(1.5)
            
            Text("Kangaroo AI is thinking...")
                .font(.headline)
                .foregroundColor(.appPurple)
        }
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            VStack(spacing: 16) {
                Kangaroo.warning.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                Text("Oops!")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                Text(message)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.appTextSecondary)
                    .padding(.horizontal)
                
                HStack(spacing: 16) {
                    Button("Cancel", action: onCancel)
                        .foregroundColor(.gray)
                    Button("Try Again", action: onRetry)
                        .bold()
                        .foregroundColor(.appPurple)
                }
                .padding(.top, 8)
            }
            .padding()
            .background(Color.appCard)
            .cornerRadius(20)
            .padding(40)
        }
    }
}

// MARK: - HISTORY SHEET
struct HistoryView: View {
    @ObservedResults(AIGiftResultObject.self, sortDescriptor: SortDescriptor(keyPath: "createdAt", ascending: false)) var history
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appCard.ignoresSafeArea()
                List {
                    ForEach(history) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.querySummary)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(item.suggestedGifts.joined(separator: ", "))
                                .font(.caption)
                                .foregroundColor(.appPurple)
                                .lineLimit(2)
                        }
                        .listRowBackground(Color.appBackground)
                    }
                    .onDelete(perform: $history.remove)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Search History")
            .toolbar {
                Button("Done") { dismiss() }
                    .foregroundColor(.appPurple)
            }
        }
    }
}

// MARK: - ADD TO WISHLIST SHEET
struct AddToWishlistSheet: View {
    let item: AIGiftSuggestion
    @ObservedResults(WishlistObject.self) var wishlists
    @Environment(\.dismiss) var dismiss
    @Environment(\.realm) var realm
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appCard.ignoresSafeArea()
                
                if wishlists.isEmpty {
                    VStack {
                        Text("No wishlists found.")
                            .foregroundColor(.white)
                        Text("Create one in the Wishlists tab first!")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                } else {
                    List {
                        ForEach(wishlists) { list in
                            Button {
                                addGift(to: list)
                            } label: {
                                HStack {
                                    Text(list.title)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.appPurple)
                                }
                            }
                            .listRowBackground(Color.appBackground)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Save to...")
            .toolbar {
                Button("Cancel") { dismiss() }
                    .foregroundColor(.appTextSecondary)
            }
        }
    }
    
    private func addGift(to list: WishlistObject) {
        try? realm.write {
            if let liveList = list.thaw() {
                let gift = GiftObject(title: item.item, details: item.description, price: 0.0)
                liveList.gifts.append(gift)
            }
        }
        dismiss()
    }
}
