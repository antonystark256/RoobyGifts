import SwiftUI

// MARK: - COLORS
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // DARK THEME PALETTE
    static let appBackground = Color(hex: "121212")       // Almost black
    static let appCard = Color(hex: "1E1E1E")             // Dark Grey for cards
    static let appTextPrimary = Color(hex: "FFFFFF")      // White
    static let appTextSecondary = Color(hex: "B0B0B0")    // Light Grey
    
    // ACCENTS
    static let appPurple = Color(hex: "BB86FC")           // Light Purple (pops on dark)
    static let appDarkPurple = Color(hex: "3700B3")       // Deeper purple
    static let appYellow = Color(hex: "03DAC6")           // Using Teal/Cyan for secondary accent in dark mode (better contrast) OR keep Gold
    static let appGold = Color(hex: "FFD700")             // Gold for stars/trophies
}

// MARK: - MASCOT MANAGER
enum Kangaroo: String {
    case waving = "1"
    case standing = "2"
    case speaking = "3"
    case holdingGift = "4"
    case idea = "5"
    case winner = "6"
    case withTablet = "7"
    case warning = "8"
    case boxing = "9"
    case shock = "10"
    case head = "11"
    case proud = "12"
    
    var image: Image {
        Image(self.rawValue)
    }
}

// MARK: - VIEW MODIFIERS
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.black) // Black text on bright button
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.appPurple)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
