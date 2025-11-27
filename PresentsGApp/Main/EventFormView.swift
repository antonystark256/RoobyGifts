import SwiftUI
import RealmSwift

// MARK: - EVENT FORM VIEW
struct EventFormView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.realm) var realm
    @ObservedResults(WishlistObject.self) var wishlists
    
    var eventToEdit: CalendarEventObject?
    
    @State private var personName: String = ""
    @State private var date: Date = Date()
    @State private var selectedWishlistID: String = "" // Storing ID string
    @State private var status: EventStatus = .none
    
    init(eventToEdit: CalendarEventObject? = nil) {
        self.eventToEdit = eventToEdit
        if let event = eventToEdit {
            _personName = State(initialValue: event.personName)
            _date = State(initialValue: event.eventDate)
            _status = State(initialValue: event.status)
            if let linkedList = event.linkedWishlist {
                _selectedWishlistID = State(initialValue: linkedList._id.stringValue)
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.appCard.ignoresSafeArea()
            
            NavigationStack {
                Form {
                    Section("Event Details") {
                        TextField("Person Name (e.g. Mom)", text: $personName)
                            .foregroundColor(.white)
                        
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .colorScheme(.dark) // Force dark picker
                    }
                    .listRowBackground(Color.appBackground)
                    
                    Section("Gift Status") {
                        Picker("Status", selection: $status) {
                            Text("Not Selected").tag(EventStatus.none)
                            Text("Selected").tag(EventStatus.selected)
                            Text("Bought").tag(EventStatus.bought)
                        }
                        .pickerStyle(.segmented)
                        .colorScheme(.dark)
                    }
                    .listRowBackground(Color.clear) // Clear bg for segmented control
                    
                    Section("Link Wishlist (Optional)") {
                        Picker("Select Wishlist", selection: $selectedWishlistID) {
                            Text("None").tag("")
                            ForEach(wishlists) { list in
                                Text(list.title).tag(list._id.stringValue)
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                    .listRowBackground(Color.appBackground)
                }
                .scrollContentBackground(.hidden)
                .background(Color.appCard)
                .navigationTitle(eventToEdit == nil ? "New Event" : "Edit Event")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .foregroundColor(.appTextSecondary)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { saveEvent() }
                            .disabled(personName.isEmpty)
                            .foregroundColor(.appPurple)
                    }
                }
            }
        }
    }
    
    private func saveEvent() {
        // 1. Prepare ID
        let wishlistId = try? ObjectId(string: selectedWishlistID)
        
        try? realm.write {
            // 2. Fetch the wishlist object INSIDE the write transaction
            var linkedList: WishlistObject? = nil
            if let id = wishlistId {
                linkedList = realm.object(ofType: WishlistObject.self, forPrimaryKey: id)
            }
            
            if let event = eventToEdit, let liveEvent = event.thaw() {
                // UPDATE (using thawed object)
                liveEvent.personName = personName
                liveEvent.eventDate = date
                liveEvent.status = status
                liveEvent.linkedWishlist = linkedList
            } else {
                // CREATE
                let newEvent = CalendarEventObject(name: personName, date: date)
                newEvent.status = status
                newEvent.linkedWishlist = linkedList
                
                realm.add(newEvent)
            }
        }
        dismiss()
    }
}
