//
//  ViewController.swift
//  ExampleApp
//
//  Created by MAC-Nasridinov-B on 07/09/25.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(primaryAction: .init(title: "Trigger", handler: { _ in
            self.testMockRequests()
        }))
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        testMockRequests()
    }

    func testMockRequests() {
        let urls = [
            "https://jsonplaceholder.typicode.com/posts/1",
            "https://jsonplaceholder.typicode.com/users/1",
            "https://jsonplaceholder.typicode.com/todos/1",
            "https://httpbin.org/status/404",   // should fail (404)
            "https://httpbin.org/delay/2",
            "https://jsonplaceholder.typicode.com/posts/1",
            "https://jsonplaceholder.typicode.com/users/1",
            "https://jsonplaceholder.typicode.com/todos/1",
            "https://httpbin.org/status/404",   // should fail (404)
            "https://httpbin.org/delay/2"// delayed response (2s)
        ]
        
        for (index, urlString) in urls.enumerated() {
            guard let url = URL(string: urlString) else { continue }
            
            // Fire requests with a small delay so they happen sequentially
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(index/2)) {
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("❌ Request to \(url) failed: \(error.localizedDescription)")
                    } else if let response = response as? HTTPURLResponse {
                        print("✅ Request to \(url) completed with status: \(response.statusCode)")
                    }
                }
                task.resume()
            }
        }
    }

}

