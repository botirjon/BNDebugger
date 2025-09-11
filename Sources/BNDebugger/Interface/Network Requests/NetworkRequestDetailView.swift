//
//  NetworkRequestDetailView.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//

import SwiftUI

struct NetworkRequestDetailView: View {
    let request: NetworkRequest
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                requestSection
                
                if !request.headers.isEmpty {
                    headersSection
                }
                
                if let bodyContent = requestBodyContent, !bodyContent.isEmpty {
                    requestBodySection(content: bodyContent)
                }
                
                if let response = request.response {
                    responseSection(response: response)
                    
                    if !response.headers.isEmpty {
                        responseHeadersSection(response: response)
                    }
                    
                    if let responseBodyContent = responseBodyContent(response: response), !responseBodyContent.isEmpty {
                        responseBodySection(content: responseBodyContent)
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle("Request Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var requestSection: some View {
        DetailSection(title: "Request") {
            DetailItem(label: "URL", value: request.url)
            DetailItem(label: "Method", value: request.method)
            DetailItem(label: "Timestamp", value: DateFormatter.localizedString(from: request.timestamp, dateStyle: .short, timeStyle: .medium))
        }
    }
    
    private var headersSection: some View {
        DetailSection(title: "Headers") {
            ForEach(Array(request.headers.keys.sorted()), id: \.self) { key in
                DetailItem(label: key, value: request.headers[key] ?? "")
            }
        }
    }
    
    private func requestBodySection(content: [String]) -> some View {
        DetailSection(title: "Request Body") {
            ForEach(content, id: \.self) { line in
                if #available(iOS 15.0, *) {
                    Text(line)
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .textSelection(.enabled)
                } else {
                    Text(line)
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                }
            }
        }
    }
    
    private func responseSection(response: NetworkResponse) -> some View {
        DetailSection(title: "Response") {
            DetailItem(label: "Status Code", value: "\(response.statusCode)")
            DetailItem(label: "Response Time", value: String(format: "%.3fs", response.responseTime))
        }
    }
    
    private func responseHeadersSection(response: NetworkResponse) -> some View {
        DetailSection(title: "Response Headers") {
            ForEach(Array(response.headers.keys.sorted()), id: \.self) { key in
                DetailItem(label: key, value: response.headers[key] ?? "")
            }
        }
    }
    
    private func responseBodySection(content: [String]) -> some View {
        DetailSection(title: "Response Body") {
            ForEach(content, id: \.self) { line in
                if #available(iOS 15.0, *) {
                    Text(line)
                        .font(.system(size: 14, design: .monospaced))
                        .textSelection(.enabled)
                } else {
                    Text(line)
                        .font(.system(size: 14, design: .monospaced))
                }
            }
        }
    }
    
    private var requestBodyContent: [String]? {
        return formatBodyContent(data: request.body, headers: request.headers)
    }
    
    private func responseBodyContent(response: NetworkResponse) -> [String]? {
        return formatBodyContent(data: response.body, headers: response.headers)
    }
    
    private func formatBodyContent(data: Data?, headers: [String: String]) -> [String]? {
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
        
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return [prettyString]
        } else {
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

struct DetailSection<Content: View>: View {
    let title: String
    let content: () -> Content
    
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
            
            content()
            
            Divider()
        }
    }
}

struct DetailItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            if #available(iOS 15.0, *) {
                Text(value)
                    .font(.system(size: 14))
                    .textSelection(.enabled)
            } else {
                Text(value)
                    .font(.system(size: 14))
            }
        }
    }
}

#Preview {
    let sampleRequest = NetworkRequest(
        url: "https://api.example.com/users",
        method: "GET",
        headers: ["Content-Type": "application/json"],
        body: nil,
        timestamp: Date()
    )
    
    NavigationView {
        NetworkRequestDetailView(request: sampleRequest)
    }
}
