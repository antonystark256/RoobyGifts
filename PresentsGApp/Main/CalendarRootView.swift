import SwiftUI
import RealmSwift

// MARK: - CALENDAR ROOT VIEW
struct CalendarRootView: View {
    @ObservedResults(CalendarEventObject.self, sortDescriptor: SortDescriptor(keyPath: "eventDate", ascending: true)) var events
    @State private var showAddSheet = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.appBackground.ignoresSafeArea()
            
            if events.isEmpty {
                VStack(spacing: 24) {
                    Kangaroo.withTablet.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                    
                    Text("Calendar is empty")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text("Add upcoming birthdays to never forget a gift!")
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button {
                        showAddSheet = true
                    } label: {
                        Text("Add Event")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.appPurple)
                            .cornerRadius(12)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(events) { event in
                        ZStack {
                            NavigationLink(destination: EventDetailView(event: event)) {
                                EmptyView()
                            }
                            .opacity(0)
                            
                            EventRow(event: event)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                $events.remove(event)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden) // Remove gray system background
                .padding(.bottom, 80) // TabBar padding
            }
            
            // FAB
            if !events.isEmpty {
                Button {
                    showAddSheet = true
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
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showAddSheet) {
            EventFormView()
        }
    }
}

// MARK: - EVENT ROW
struct EventRow: View {
    @ObservedRealmObject var event: CalendarEventObject
    
    var body: some View {
        HStack(spacing: 16) {
            // 1. Stylish Date Box
            VStack(spacing: 0) {
                // Month Header
                Text(event.eventDate.formatted(.dateTime.month()))
                    .font(.system(size: 10, weight: .bold))
                    .textCase(.uppercase)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 20)
                    .background(Color.appPurple)
                
                // Day Number
                Text(event.eventDate.formatted(.dateTime.day()))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 50, height: 36)
                    .background(Color.white)
            }
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            
            // 2. Info
            VStack(alignment: .leading, spacing: 6) {
                Text(event.personName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 6) {
                    if event.linkedWishlist != nil {
                        HStack(spacing: 4) {
                            Image(systemName: "link")
                                .font(.caption2)
                            Text("Wishlist")
                                .font(.caption)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.appPurple.opacity(0.2))
                        .cornerRadius(4)
                        .foregroundColor(.appPurple)
                    } else {
                        Text("No wishlist")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            // 3. Status Icons
            VStack {
                if event.status == .bought {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                } else if event.status == .selected {
                    Image(systemName: "cart.circle.fill")
                        .font(.title2)
                        .foregroundColor(.appYellow)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
        }
        .padding(16)
        .background(Color.appCard)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
