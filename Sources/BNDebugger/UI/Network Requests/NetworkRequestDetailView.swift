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
        .navigationBarItems(trailing: Button("", systemImage: "square.and.arrow.up", action: {
            debugPrint("Share request")
        }))
    }
    
    private var monospacedBoldValueFont: Font {
        .system(size: 14, weight: .bold, design: .monospaced)
    }
    
    private var monospacedRegularValueFont: Font {
        .system(size: 14, weight: .regular, design: .monospaced)
    }
    
    private var requestSection: some View {
        DetailSection(title: "Request") {
            DetailItem(label: "URL", value: request.url, valueColor: .accentColor)
            DetailItem(label: "Method", value: request.method,  valueColor: .accentColor)
            DetailItem(label: "Timestamp", value: DateFormatter.localizedString(from: request.timestamp, dateStyle: .short, timeStyle: .medium))
        }
    }
    
    private var headersSection: some View {
        DetailSection(title: "Headers") {
            ForEach(Array(request.headers.keys.sorted()), id: \.self) { key in
                DetailItem(label: key, value: request.headers[key] ?? "", valueFont: monospacedRegularValueFont)
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



#Preview {
    let json = "{\"api_key\": \"key\"}"
    
    let sampleRequest = NetworkRequest(
        url: "https://api.example.com/users",
        method: "GET",
        headers: ["Content-Type": "application/json"],
        body: json.data(using: .utf8, allowLossyConversion: false),
        timestamp: Date(),
        response: NetworkResponse(
            statusCode: 400,
            headers: ["Content-Type": "application/json"],
            body: json.data(using: .utf8, allowLossyConversion: false),
            responseTime: 2
        )
    )
    
    NavigationView {
        NetworkRequestDetailView(request: sampleRequest)
    }
}
