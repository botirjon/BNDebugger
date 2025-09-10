//
//  NetworkRequestDetailsViewController.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 10/09/25.
//

import UIKit

class NetworkRequestDetailViewController: UIViewController {
    private let request: NetworkRequest
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    init(request: NetworkRequest) {
        self.request = request
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateDetails()
    }
    
    private func setupUI() {
        title = "Request Details"
        view.backgroundColor = .systemBackground
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        
        scrollView.addSubview(stackView)
        view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    private func populateDetails() {
        addSection("Request", content: [
            "URL: \(request.url)",
            "Method: \(request.method)",
            "Timestamp: \(DateFormatter.localizedString(from: request.timestamp, dateStyle: .short, timeStyle: .medium))"
        ])
        
        if !request.headers.isEmpty {
            let headerContent = request.headers.map { "\($0.key): \($0.value)" }
            addSection("Headers", content: headerContent)
        }
        
        // Request Body
        let requestBodyContent = formatBodyContent(
            data: request.body,
            headers: request.headers,
            title: "Request Body"
        )
        if !requestBodyContent.isEmpty {
            addSection("Request Body", content: requestBodyContent)
        }
        
        if let response = request.response {
            addSection("Response", content: [
                "Status Code: \(response.statusCode)",
                "Response Time: \(String(format: "%.3f", response.responseTime))s"
            ])
            
            if !response.headers.isEmpty {
                let responseHeaderContent = response.headers.map { "\($0.key): \($0.value)" }
                addSection("Response Headers", content: responseHeaderContent)
            }
            
            // Response Body
            let responseBodyContent = formatBodyContent(
                data: response.body,
                headers: response.headers,
                title: "Response Body"
            )
            if !responseBodyContent.isEmpty {
                addSection("Response Body", content: responseBodyContent)
            }
        }
    }
    
    private func addSection(_ title: String, content: [String]) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        stackView.addArrangedSubview(titleLabel)
        
        for line in content {
            let contentLabel = UILabel()
            contentLabel.text = line
            contentLabel.font = UIFont.systemFont(ofSize: 14)
            contentLabel.numberOfLines = 0
            contentLabel.textColor = .label
            stackView.addArrangedSubview(contentLabel)
        }
        
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stackView.addArrangedSubview(separator)
    }
    
    private func formatBodyContent(data: Data?, headers: [String: String], title: String) -> [String] {
        guard let data = data, !data.isEmpty else {
            return ["-"]
        }
        
        let contentType = getContentType(from: headers)
        
        if contentType.lowercased().contains("application/json") {
            return formatJSONContent(data: data)
        } else {
            return formatNonJSONContent(data: data, contentType: contentType)
        }
    }
    
    private func getContentType(from headers: [String: String]) -> String {
        for (key, value) in headers {
            if key.lowercased() == "content-type" {
                return value
            }
        }
        return "unknown"
    }
    
    private func formatJSONContent(data: Data) -> [String] {
        guard let jsonString = String(data: data, encoding: .utf8) else {
            return ["Invalid JSON encoding"]
        }
        
        // Try to pretty print JSON
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return [prettyString]
        } else {
            // Return raw JSON if pretty printing fails
            return [jsonString]
        }
    }
    
    private func formatNonJSONContent(data: Data, contentType: String) -> [String] {
        let sizeString = formatDataSize(bytes: data.count)
        return ["\(contentType) (\(sizeString))"]
    }
    
    private func formatDataSize(bytes: Int) -> String {
        if bytes < 1024 {
            return "\(bytes) bytes"
        } else {
            let kb = Double(bytes) / 1024.0
            return String(format: "%.1f KB", kb)
        }
    }
}
