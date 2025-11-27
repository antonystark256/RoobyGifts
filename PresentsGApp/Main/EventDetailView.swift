import SwiftUI
import RealmSwift

// MARK: - EVENT DETAIL VIEW
struct EventDetailView: View {
    @ObservedRealmObject var event: CalendarEventObject
    @State private var showEditSheet = false
    @State private var showAIGenerator = false
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    
                    // MARK: - 1. MAIN HEADER CARD
                    VStack(spacing: 20) {
                        // Mascot
                        Kangaroo.standing.image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 140)
                            .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                        
                        VStack(spacing: 8) {
                            Text(event.personName)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(event.eventDate.formatted(date: .complete, time: .omitted))
                                .font(.headline)
                                .foregroundColor(.appTextSecondary)
                            
                            // Days Left Badge
                            Text(daysUntilText())
                                .font(.callout.bold())
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.appYellow) // Gold/Teal accent
                                .cornerRadius(20)
                                .padding(.top, 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .padding(.horizontal, 20)
                    .background(Color.appCard)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                    
                    // MARK: - 2. STATUS SECTION
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Gift Status")
                            .font(.headline)
                            .foregroundColor(.appTextSecondary)
                            .padding(.horizontal, 4)
                        
                        HStack {
                            StatusBadge(status: .none, current: event.status)
                            Spacer()
                            // Line connectors
                            Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 2)
                            Spacer()
                            StatusBadge(status: .selected, current: event.status)
                            Spacer()
                            Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 2)
                            Spacer()
                            StatusBadge(status: .bought, current: event.status)
                        }
                        .padding(20)
                        .background(Color.appCard)
                        .cornerRadius(16)
                    }
                    
                    // MARK: - 3. ACTIONS
                    VStack(spacing: 16) {
                        // Linked Wishlist Button
                        if let wishlist = event.linkedWishlist {
                            NavigationLink(destination: WishlistDetailView(wishlist: wishlist)) {
                                HStack {
                                    Image(systemName: "list.bullet.rectangle.portrait.fill")
                                        .font(.title3)
                                    Text("Open Linked Wishlist")
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.appCard)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.appPurple.opacity(0.5), lineWidth: 1)
                                )
                            }
                        } else {
                            Text("No wishlist linked")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        
                        // AI Button
                        Button {
                            showAIGenerator = true
                        } label: {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Find Gift with AI")
                            }
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [.appPurple, .appPurple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .cornerRadius(16)
                            .shadow(color: .appPurple.opacity(0.4), radius: 8, y: 4)
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            Button("Edit") { showEditSheet = true }
                .foregroundColor(.appPurple)
        }
        .sheet(isPresented: $showEditSheet) {
            EventFormView(eventToEdit: event)
        }
        .sheet(isPresented: $showAIGenerator) {
            AIGiftRootView() // Reuse the AI view logic
        }
    }
    
    private func daysUntilText() -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let eventDay = calendar.startOfDay(for: event.eventDate)
        let components = calendar.dateComponents([.day], from: today, to: eventDay)
        
        if let days = components.day {
            if days == 0 { return "Today!" }
            if days < 0 { return "Event Passed" }
            return "\(days) days left"
        }
        return ""
    }
}

// MARK: - STATUS BADGE COMPONENT
struct StatusBadge: View {
    let status: EventStatus
    let current: EventStatus
    
    var isActive: Bool { status == current }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isActive ? Color.green : Color.appBackground)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(isActive ? Color.green : Color.gray.opacity(0.5), lineWidth: 2)
                    )
                
                if isActive {
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundColor(.black)
                }
            }
            
            Text(status.rawValue)
                .font(.caption)
                .foregroundColor(isActive ? .white : .gray)
                .fixedSize() // Prevents text truncation
        }
    }
}
