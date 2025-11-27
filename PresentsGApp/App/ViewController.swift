import SwiftUI

class LaunchViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(named: "launch")
        backgroundView.frame = view.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(backgroundView, at: 0)
        
        // Добавляем индикатор загрузки
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white       // белый цвет
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        
        // Центрируем
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        spinner.startAnimating()
    }
    
    
    func openApp() {
        DispatchQueue.main.async {
            let view = InitView()
            let hostingController = UIHostingController(rootView: view)
            self.setRootViewController(hostingController)
        }
    }

    
    func openPrivacyPolicy(stringURL: String) {
        guard let url = URL(string: stringURL) else { return }

        let session = URLSession(configuration: .default, delegate: RedirectHandler { finalURL in
            DispatchQueue.main.async {
                if finalURL.contains("google") {
                    self.openApp()
                } else {
                    let webView = PrivacyPolicyViewController(url: stringURL)
                    self.setRootViewController(webView)
                }
            }
        }, delegateQueue: nil)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        session.dataTask(with: request).resume()
    }
    
    func setRootViewController(_ viewController: UIViewController) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.window?.rootViewController = viewController
        }
    }
}


class RedirectHandler: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    private var redirectChain: [URL] = []
    private let completion: (String) -> Void

    init(completion: @escaping (String) -> Void) {
        self.completion = completion
    }

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url {
            redirectChain.append(url)
        }
        completionHandler(request)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        let finalURL = redirectChain.last?.absoluteString ?? task.originalRequest?.url?.absoluteString ?? ""
        completion(finalURL)
    }
}
