import SwiftUI

// MARK: - IMAGE MANAGER
class ImageHelper {
    static let shared = ImageHelper()
    
    private init() {}
    
    func saveImage(_ image: UIImage) -> String? {
        let fileName = UUID().uuidString + ".jpg"
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            try data.write(to: url)
            return fileName
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    func loadImage(named fileName: String) -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
