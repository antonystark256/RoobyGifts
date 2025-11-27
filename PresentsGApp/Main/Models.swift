import Foundation
import RealmSwift

// MARK: - WISHLIST & GIFTS

class GiftObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var title: String
    @Persisted var details: String
    @Persisted var price: Double
    @Persisted var imagePath: String? // Local file name or URL string
    @Persisted var webLink: String?
    @Persisted var isPurchased: Bool = false
    @Persisted var dateAdded: Date = Date()
    
    @Persisted(originProperty: "gifts") var parentWishlist: LinkingObjects<WishlistObject>
    
    convenience init(title: String, details: String = "", price: Double = 0.0) {
        self.init()
        self.title = title
        self.details = details
        self.price = price
    }
}

class WishlistObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var title: String
    @Persisted var subtitle: String
    @Persisted var coverImage: String? // Optional custom cover
    @Persisted var createdAt: Date = Date()
    @Persisted var gifts: List<GiftObject>
    
    convenience init(title: String, subtitle: String = "") {
        self.init()
        self.title = title
        self.subtitle = subtitle
    }
}

// MARK: - AI GIFT HISTORY

class AIGiftResultObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var querySummary: String // e.g., "Male, 25, Tech"
    @Persisted var createdAt: Date = Date()
    @Persisted var suggestedGifts: List<String> // Simple list of names/ideas
}

// MARK: - CALENDAR

class CalendarEventObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var personName: String
    @Persisted var eventDate: Date
    @Persisted var statusRaw: String = "none" // none, selected, bought
    @Persisted var linkedWishlist: WishlistObject?
    
    var status: EventStatus {
        get { EventStatus(rawValue: statusRaw) ?? .none }
        set { statusRaw = newValue.rawValue }
    }
    
    convenience init(name: String, date: Date) {
        self.init()
        self.personName = name
        self.eventDate = date
    }
}

enum EventStatus: String, PersistableEnum {
    case none = "Not Selected"
    case selected = "Selected"
    case bought = "Bought"
}

// MARK: - FUN: SECRET SANTA

class SantaParticipantObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String
    @Persisted var contactInfo: String?
    @Persisted var avatarPath: String?
    @Persisted var targetParticipantId: String? // The ID of the person they are gifting to
    @Persisted var isRevealed: Bool = false
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

class SantaGameObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var title: String
    @Persisted var budget: Double
    @Persisted var eventDate: Date
    @Persisted var rules: String
    @Persisted var isPairsGenerated: Bool = false
    @Persisted var createdAt: Date = Date()
    
    @Persisted var participants: List<SantaParticipantObject>
    
    convenience init(title: String, budget: Double, date: Date) {
        self.init()
        self.title = title
        self.budget = budget
        self.eventDate = date
    }
}

// MARK: - FUN: CERTIFICATES

class CertificateObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var title: String
    @Persisted var amount: Double
    @Persisted var expirationDate: Date
    @Persisted var imagePath: String?
    @Persisted var notes: String
    @Persisted var isUsed: Bool = false
    
    var isExpired: Bool {
        return Date() > expirationDate && !isUsed
    }
    
    convenience init(title: String, amount: Double, expirationDate: Date) {
        self.init()
        self.title = title
        self.amount = amount
        self.expirationDate = expirationDate
    }
}

// MARK: - FUN: ACHIEVEMENTS

class AchievementObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var key: String // Unique key to identify achievement in code
    @Persisted var title: String
    @Persisted var desc: String
    @Persisted var iconName: String
    @Persisted var currentProgress: Int = 0
    @Persisted var targetProgress: Int
    @Persisted var isUnlocked: Bool = false
    @Persisted var unlockedAt: Date?
    
    convenience init(key: String, title: String, desc: String, target: Int, icon: String) {
        self.init()
        self.key = key
        self.title = title
        self.desc = desc
        self.targetProgress = target
        self.iconName = icon
    }
}
