import SwiftUI
import RealmSwift

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.realm) var realm
    
    @AppStorage("isNotificationsEnabled") private var isNotificationsEnabled = true
    @AppStorage("selectedCurrency") private var currency = "USD"
    
    @State private var showResetAlert = false
    @State private var showHistoryAlert = false
    
    let currencies = ["USD ($)", "EUR (€)", "GBP (£)"]
    
    var body: some View {
        ZStack {
            Color.appCard.ignoresSafeArea()
            
            NavigationStack {
                Form {
                    // MARK: - PREFERENCES
                    Section("Preferences") {
//                        Toggle(isOn: $isNotificationsEnabled) {
//                            Label {
//                                Text("Notifications")
//                                    .foregroundColor(.white)
//                            } icon: {
//                                Image(systemName: "bell.fill")
//                                    .foregroundColor(.appPurple)
//                            }
//                        }
                        
                        Picker(selection: $currency) {
                            ForEach(currencies, id: \.self) { curr in
                                Text(curr).tag(curr)
                            }
                        } label: {
                            Label {
                                Text("Currency")
                                    .foregroundColor(.white)
                            } icon: {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.appYellow)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .listRowBackground(Color.appBackground)
                    
                    // MARK: - DATA MANAGEMENT
                    Section("Data & Storage") {
                        Button {
                            showHistoryAlert = true
                        } label: {
                            Label {
                                Text("Clear AI Search History")
                                    .foregroundColor(.white)
                            } icon: {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .alert("Clear History?", isPresented: $showHistoryAlert) {
                            Button("Cancel", role: .cancel) { }
                            Button("Clear", role: .destructive) { clearHistory() }
                        } message: {
                            Text("This will remove all your saved AI gift ideas.")
                        }
                        
                        Button {
                            showResetAlert = true
                        } label: {
                            Label {
                                Text("Reset Achievements")
                                    .foregroundColor(.white)
                            } icon: {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                    .foregroundColor(.orange)
                            }
                        }
                        .alert("Reset Achievements?", isPresented: $showResetAlert) {
                            Button("Cancel", role: .cancel) { }
                            Button("Reset", role: .destructive) { resetAchievements() }
                        } message: {
                            Text("This will lock all achievements and set progress to zero.")
                        }
                    }
                    .listRowBackground(Color.appBackground)
                    
                    // MARK: - ABOUT
                    Section("About") {
                        HStack {
                            Label("Version", systemImage: "info.circle.fill")
                                .foregroundColor(.gray)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.white)
                        }
                        
                        Link(destination: URL(string: "https://sites.google.com/view/roobygifts/privacy-policy")!) {
                            Label("Privacy Policy", systemImage: "hand.raised.fill")
                                .foregroundColor(.white)
                        }
                        
                        Link(destination: URL(string: "https://apps.apple.com/us/app/id6755823020")!) {
                            Label("Rate App", systemImage: "star.fill")
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(Color.appBackground)
                    
                    // Footer Mascot
                    Section {
                        VStack(spacing: 12) {
                            Kangaroo.speaking.image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                            Text("Made with ❤️ by Rooby")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.appCard)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { dismiss() }
                            .foregroundColor(.appPurple)
                    }
                }
            }
        }
    }
    
    // MARK: - ACTIONS
    
    private func clearHistory() {
        try? realm.write {
            let history = realm.objects(AIGiftResultObject.self)
            realm.delete(history)
        }
    }
    
    private func resetAchievements() {
        try? realm.write {
            let achievements = realm.objects(AchievementObject.self)
            for achievement in achievements {
                if let live = achievement.thaw() {
                    live.currentProgress = 0
                    live.isUnlocked = false
                    live.unlockedAt = nil
                }
            }
        }
    }
}
