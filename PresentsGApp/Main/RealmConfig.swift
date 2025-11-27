import Foundation
import RealmSwift

// MARK: - REALM CONFIGURATOR
class RealmConfig {
    static let shared = RealmConfig()
    
    private init() {}
    
    func configure() {
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // Handle future migrations
                }
            }
        )
        Realm.Configuration.defaultConfiguration = config
        
        initializeAchievements()
    }
    
    private func initializeAchievements() {
        do {
            let realm = try Realm()
            
            // Define initial achievements
            let initialAchievements = [
                AchievementObject(key: "first_wishlist", title: "Dreamer", desc: "Create your first wishlist", target: 1, icon: "star.fill"),
                AchievementObject(key: "five_gifts", title: "Collector", desc: "Save 5 gift ideas", target: 5, icon: "bag.fill"),
                AchievementObject(key: "first_ai", title: "Future Ready", desc: "Use AI Gift Finder once", target: 1, icon: "sparkles"),
                AchievementObject(key: "santa_host", title: "Ho-Ho-Ho", desc: "Create a Secret Santa game", target: 1, icon: "gift.fill")
            ]
            
            // Add only if they don't exist
            try realm.write {
                for achievement in initialAchievements {
                    if realm.objects(AchievementObject.self).filter("key == %@", achievement.key).isEmpty {
                        realm.add(achievement)
                    }
                }
            }
        } catch {
            print("Error initializing Realm: \(error.localizedDescription)")
        }
    }
}
