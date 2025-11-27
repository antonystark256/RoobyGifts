import SwiftUI
import RealmSwift

// MARK: - LIST GAMES
struct SecretSantaListView: View {
    @ObservedResults(SantaGameObject.self, sortDescriptor: SortDescriptor(keyPath: "eventDate", ascending: false)) var games
    @State private var showCreateSheet = false
    @Environment(\.realm) var realm
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.appBackground.ignoresSafeArea()
            
            if games.isEmpty {
                // Empty State
                VStack(spacing: 24) {
                    Kangaroo.holdingGift.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                    
                    Text("No Games Yet")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text("Create a group to start the magic!")
                        .font(.body)
                        .foregroundColor(.appTextSecondary)
                    
                    Button {
                        showCreateSheet = true
                    } label: {
                        Text("Start New Game")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 30)
                            .background(Color.appPurple)
                            .cornerRadius(25)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // List State
                List {
                    ForEach(games) { game in
                        ZStack {
                            NavigationLink(destination: SecretSantaDetailView(game: game)) {
                                EmptyView()
                            }
                            .opacity(0)
                            
                            GameRow(game: game)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                $games.remove(game)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.bottom, 80)
            }
            
            // FAB
            if !games.isEmpty {
                Button { showCreateSheet = true } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(.black)
                        .frame(width: 56, height: 56)
                        .background(Color.appPurple)
                        .clipShape(Circle())
                        .shadow(color: .appPurple.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding()
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Secret Santa")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showCreateSheet) {
            CreateSantaGameView()
        }
    }
}

// MARK: - GAME ROW COMPONENT
struct GameRow: View {
    @ObservedRealmObject var game: SantaGameObject
    
    var body: some View {
        HStack {
            // Icon / Date
            VStack {
                Text(game.eventDate.formatted(.dateTime.day()))
                    .font(.title3)
                    .bold()
                    .foregroundColor(.black)
                Text(game.eventDate.formatted(.dateTime.month()))
                    .font(.caption)
                    .bold()
                    .textCase(.uppercase)
                    .foregroundColor(.black.opacity(0.7))
            }
            .frame(width: 50, height: 50)
            .background(Color.appYellow) // Accent color
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(game.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(game.participants.count) participants")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
            
            Spacer()
            
            // Status Badge
            if game.isPairsGenerated {
                Text("READY")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.8))
                    .cornerRadius(8)
            } else {
                Text("DRAFT")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.appCard)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
    }
}

// MARK: - CREATE GAME VIEW
struct CreateSantaGameView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.realm) var realm
    
    @State private var title = ""
    @State private var budget = ""
    @State private var date = Date()
    @State private var rules = ""
    
    @State private var participants: [String] = []
    @State private var newName = ""
    
    var body: some View {
        ZStack {
            Color.appCard.ignoresSafeArea()
            
            NavigationStack {
                Form {
                    Section("Game Info") {
                        TextField("Game Title", text: $title)
                            .foregroundColor(.white)
                        TextField("Budget (e.g. 50)", text: $budget)
                            .keyboardType(.decimalPad)
                            .foregroundColor(.white)
                        DatePicker("Exchange Date", selection: $date, displayedComponents: .date)
                            .colorScheme(.dark)
                        TextField("Rules / Notes", text: $rules)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.appBackground)
                    
                    Section("Participants (Min 3)") {
                        HStack {
                            TextField("Name", text: $newName)
                                .foregroundColor(.white)
                            Button {
                                if !newName.isEmpty {
                                    withAnimation {
                                        participants.append(newName)
                                        newName = ""
                                    }
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.appPurple)
                            }
                            .disabled(newName.isEmpty)
                        }
                        
                        ForEach(participants, id: \.self) { name in
                            Text(name).foregroundColor(.appTextSecondary)
                        }
                        .onDelete { indexSet in
                            participants.remove(atOffsets: indexSet)
                        }
                    }
                    .listRowBackground(Color.appBackground)
                }
                .scrollContentBackground(.hidden)
                .background(Color.appCard)
                .navigationTitle("New Game")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() }.foregroundColor(.gray) }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Create") { createGame() }
                            .disabled(participants.count < 3 || title.isEmpty)
                            .foregroundColor(.appPurple)
                    }
                }
            }
        }
    }
    
    private func createGame() {
        let game = SantaGameObject(title: title, budget: Double(budget) ?? 0, date: date)
        game.rules = rules
        
        // Add participants
        for name in participants {
            let p = SantaParticipantObject(name: name)
            game.participants.append(p)
        }
        
        try? realm.write {
            realm.add(game)
        }
        
        checkAchievement()
        dismiss()
    }
    
    private func checkAchievement() {
        if let achievement = realm.objects(AchievementObject.self).filter("key == 'santa_host'").first {
            try? realm.write {
                if let live = achievement.thaw() {
                    live.currentProgress = 1
                    live.isUnlocked = true
                    live.unlockedAt = Date()
                }
            }
        }
    }
}

// MARK: - DETAIL VIEW
struct SecretSantaDetailView: View {
    @ObservedRealmObject var game: SantaGameObject
    @Environment(\.realm) var realm
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack {
                if !game.isPairsGenerated {
                    // DRAFT STATE
                    VStack(spacing: 30) {
                        Spacer()
                        Kangaroo.holdingGift.image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180)
                            .shadow(color: .appPurple.opacity(0.5), radius: 20)
                        
                        VStack(spacing: 12) {
                            Text(game.title)
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                            
                            Text("\(game.participants.count) Participants • $\(game.budget, specifier: "%.0f") Limit")
                                .foregroundColor(.gray)
                        }
                        
                        Button {
                            generatePairs()
                        } label: {
                            Text("Shuffle & Assign Pairs")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.appPurple)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 40)
                        
                        Spacer()
                    }
                } else {
                    // READY STATE
                    List {
                        Section {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Budget: $\(game.budget, specifier: "%.0f")")
                                    .font(.headline).foregroundColor(.white)
                                Text("Date: \(game.eventDate.formatted(date: .long, time: .omitted))")
                                    .font(.subheadline).foregroundColor(.gray)
                                if !game.rules.isEmpty {
                                    Divider().background(Color.white.opacity(0.2))
                                    Text("Rules: \(game.rules)")
                                        .font(.caption).foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 8)
                            .listRowBackground(Color.appCard)
                        }
                        
                        Section("Participants") {
                            ForEach(game.participants) { person in
                                NavigationLink(destination: RevealPairView(participant: person, allParticipants: game.participants)) {
                                    HStack {
                                        Circle()
                                            .fill(person.isRevealed ? Color.gray.opacity(0.3) : Color.appPurple)
                                            .frame(width: 10, height: 10)
                                        
                                        Text(person.name)
                                            .foregroundColor(person.isRevealed ? .gray : .white)
                                            .strikethrough(person.isRevealed)
                                        
                                        Spacer()
                                        
                                        if person.isRevealed {
                                            Text("Seen")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                                .padding(4)
                                                .background(Color.white.opacity(0.1))
                                                .cornerRadius(4)
                                        }
                                    }
                                }
                                .listRowBackground(Color.appCard)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle(game.isPairsGenerated ? "Game Room" : "Lobby")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func generatePairs() {
        // FIX: Use write transaction safely with thawed object
        try? realm.write {
            guard let liveGame = game.thaw() else { return }
            
            let people = Array(liveGame.participants)
            guard people.count >= 2 else { return }
            
            // Circular shift algorithm (Guarantees no self-match)
            let shuffledPeople = people.shuffled()
            let count = shuffledPeople.count
            
            for i in 0..<count {
                let giver = shuffledPeople[i]
                // The receiver is the next person in the array (wrapping around)
                let receiver = shuffledPeople[(i + 1) % count]
                
                giver.targetParticipantId = receiver._id.stringValue
            }
            
            liveGame.isPairsGenerated = true
        }
    }
}

// MARK: - REVEAL PAIR VIEW
struct RevealPairView: View {
    @ObservedRealmObject var participant: SantaParticipantObject
    var allParticipants: RealmSwift.List<SantaParticipantObject>
    @Environment(\.realm) var realm
    @State private var isRevealed = false
    
    var targetPersonName: String {
        if let targetId = participant.targetParticipantId,
           let target = allParticipants.first(where: { $0._id.stringValue == targetId }) {
            return target.name
        }
        return "Unknown"
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Header
                VStack(spacing: 8) {
                    Text("Hello,")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Text(participant.name)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                }
                
                if isRevealed {
                    // REVEALED STATE
                    VStack(spacing: 20) {
                        Text("You are Secret Santa for:")
                            .font(.headline)
                            .foregroundColor(.appTextSecondary)
                        
                        ZStack {
                            Circle()
                                .fill(Color.appCard)
                                .frame(width: 220, height: 220)
                                .shadow(color: .white.opacity(0.05), radius: 20)
                            
                            VStack {
                                Kangaroo.winner.image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100)
                                
                                Text(targetPersonName)
                                    .font(.system(size: 32, weight: .heavy))
                                    .foregroundColor(.appPurple)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        .transition(.scale.combined(with: .opacity))
                        
                        // AI Hint
                        NavigationLink(destination: AIGiftRootView()) {
                             HStack {
                                 Image(systemName: "sparkles")
                                 Text("Get Gift Ideas from AI")
                             }
                             .font(.headline)
                             .foregroundColor(.black)
                             .padding()
                             .background(Color.appYellow)
                             .cornerRadius(16)
                        }
                        .padding(.top, 20)
                    }
                } else {
                    // HIDDEN STATE
                    Button {
                        reveal()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(
                                    LinearGradient(colors: [.appPurple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .frame(width: 280, height: 350)
                                .shadow(color: .appPurple.opacity(0.5), radius: 20)
                            
                            VStack(spacing: 20) {
                                Image(systemName: "gift.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.white)
                                
                                Text("TAP TO REVEAL")
                                    .font(.headline)
                                    .tracking(4)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    
                    Text("Make sure no one is looking!")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.8))
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if participant.isRevealed {
                isRevealed = true
            }
        }
    }
    
    private func reveal() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            isRevealed = true
        }
        
        // Mark as seen in DB
        if !participant.isRevealed {
            try? realm.write {
                if let liveP = participant.thaw() {
                    liveP.isRevealed = true
                }
            }
        }
    }
}
