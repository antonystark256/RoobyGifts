import SwiftUI
import RealmSwift
import PhotosUI

// MARK: - CERTIFICATES LIST
struct CertificateListView: View {
    @ObservedResults(CertificateObject.self, sortDescriptor: SortDescriptor(keyPath: "expirationDate", ascending: true)) var certificates
    @State private var showAddSheet = false
    @Environment(\.realm) var realm
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.appBackground.ignoresSafeArea()
            
            if certificates.isEmpty {
                VStack(spacing: 24) {
                    Kangaroo.waving.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                    
                    Text("No Certificates")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text("Add your gift cards here so you don't forget to use them!")
                        .font(.body)
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button {
                        showAddSheet = true
                    } label: {
                        Text("Add Certificate")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 30)
                            .background(Color.appYellow)
                            .cornerRadius(25)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(certificates) { cert in
                        CertificateCard(cert: cert)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    $certificates.remove(cert)
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
            if !certificates.isEmpty {
                Button { showAddSheet = true } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(.black)
                        .frame(width: 56, height: 56)
                        .background(Color.appYellow)
                        .clipShape(Circle())
                        .shadow(color: .appYellow.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding()
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Certificates")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showAddSheet) {
            AddCertificateView()
        }
    }
}

// MARK: - ADD CERTIFICATE VIEW
struct AddCertificateView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.realm) var realm
    
    // Form Fields
    @State private var title = ""
    @State private var amount = ""
    @State private var date = Date().addingTimeInterval(86400 * 30) // +30 days
    @State private var notes = ""
    
    // Image Handling
    @State private var selectedImage: UIImage? = nil
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var showCamera = false
    
    var body: some View {
        ZStack {
            Color.appCard.ignoresSafeArea()
            
            NavigationStack {
                Form {
                    // MARK: IMAGE SECTION
                    Section {
                        VStack {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(12)
                                    .clipped()
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.appBackground)
                                        .frame(height: 150)
                                    
                                    VStack(spacing: 8) {
                                        Image(systemName: "camera.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.appTextSecondary)
                                        Text("Add Photo of Card")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            // Image Selection Menu
                            Menu {
                                Button {
                                    showCamera = true
                                } label: {
                                    Label("Take Photo", systemImage: "camera")
                                }
                                
                                // Custom PhotosPicker button isn't needed inside Menu in iOS 16+,
                                // we can just put the picker link here, but PhotosPicker is a View.
                                // We'll place the picker below as a button.
                            } label: {
                                Text(selectedImage == nil ? "Select Image" : "Change Image")
                                    .font(.headline)
                                    .foregroundColor(.appYellow)
                                    .padding(.vertical, 8)
                            }
                            
                            // Gallery Picker (Hidden logic or secondary button)
                            PhotosPicker(selection: $photoItem, matching: .images) {
                                Label("Choose from Gallery", systemImage: "photo.on.rectangle")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .onChange(of: photoItem) { newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        selectedImage = uiImage
                                    }
                                }
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                    }
                    
                    // MARK: FIELDS
                    Section("Details") {
                        TextField("Store / Brand", text: $title)
                            .foregroundColor(.white)
                        
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .foregroundColor(.white)
                        
                        DatePicker("Expires On", selection: $date, displayedComponents: .date)
                            .colorScheme(.dark)
                        
                        TextField("Notes / Code", text: $notes)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.appBackground)
                }
                .scrollContentBackground(.hidden)
                .background(Color.appCard)
                .navigationTitle("New Certificate")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .foregroundColor(.appTextSecondary)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            saveCertificate()
                        }
                        .disabled(title.isEmpty)
                        .foregroundColor(.appYellow)
                    }
                }
                .fullScreenCover(isPresented: $showCamera) {
                    CameraPicker(image: $selectedImage)
                        .ignoresSafeArea()
                }
            }
        }
    }
    
    private func saveCertificate() {
        let cert = CertificateObject(title: title, amount: Double(amount) ?? 0, expirationDate: date)
        cert.notes = notes
        
        // Save Image
        if let img = selectedImage {
            cert.imagePath = ImageHelper.shared.saveImage(img)
        }
        
        try? realm.write {
            realm.add(cert)
        }
        dismiss()
    }
}

// MARK: - CARD UI
struct CertificateCard: View {
    let cert: CertificateObject
    
    var isExpiringSoon: Bool {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: cert.expirationDate).day ?? 0
        return days < 30 && days >= 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Header
            if let path = cert.imagePath, let uiImage = ImageHelper.shared.loadImage(named: path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 140)
                    .frame(maxWidth: .infinity)
                    .clipped()
            } else {
                ZStack {
                    Color.appPurple.opacity(0.2)
                    Image(systemName: "ticket.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.appPurple.opacity(0.5))
                }
                .frame(height: 100)
            }
            
            // Info Body
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(cert.title)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                    Spacer()
                    Text("$\(cert.amount, specifier: "%.0f")")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.appYellow)
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                HStack {
                    Image(systemName: "clock")
                    Text("Expires: \(cert.expirationDate.formatted(date: .numeric, time: .omitted))")
                    Spacer()
                    if isExpiringSoon {
                        Text("EXPIRING")
                            .font(.caption)
                            .bold()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                }
                .font(.caption)
                .foregroundColor(isExpiringSoon ? .red : .gray)
                
                if !cert.notes.isEmpty {
                    Text(cert.notes)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding(16)
        }
        .background(Color.appCard)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
    }
}

// MARK: - CAMERA PICKER HELPER
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
