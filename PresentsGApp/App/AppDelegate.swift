import SwiftUI
import FlagsmithClient
import AppTrackingTransparency
import AdSupport
import UserNotifications

// MARK: - Property Model
struct Property: Codable {
    let privacyPolicy, about: String
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Properties
    var window: UIWindow?
    weak var initialVC: LaunchViewController?
    
    static var orientationLock = UIInterfaceOrientationMask.all
    
    
    // MARK: - Application Lifecycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Flagsmith.shared.apiKey = "dzXuFJgEnL6crQsSVnnY7H" // antonystark256
        
        let viewController = LaunchViewController()
        initialVC = viewController
        window?.rootViewController = initialVC
        window?.makeKeyAndVisible()
        
        //MARK: - START
        start(viewController: viewController)
        
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }

}

// MARK: - App Startup
extension AppDelegate {
    func start(viewController: LaunchViewController) {
        Flagsmith.shared.getValueForFeature(withID: "policy", forIdentity: nil) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let value):
                    
                    guard let stringJSON = value?.stringValue else {
                        viewController.openApp()
                        return
                    }
                    
                    self.parseJSONString(stringJSON) { parsedResult in
                        guard !parsedResult.isEmpty else {
                            viewController.openApp()
                            return
                        }
                        
                        
                        let stringURL = parsedResult
                        guard let url = URL(string: stringURL) else {
                            viewController.openApp()
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(url) {
                            viewController.openPrivacyPolicy(stringURL: stringURL)
                        } else {
                            viewController.openApp()
                        }
                    }
                    
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    viewController.openApp()
                }
            }
        }
    }
    
    func parseJSONString(_ jsonString: String, completion: @escaping (String) -> Void) {
        
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let property = try JSONDecoder().decode(Property.self, from: jsonData)
                completion(property.about)
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        } else {
            print("Failed to convert string to Data")
        }
    }
}
