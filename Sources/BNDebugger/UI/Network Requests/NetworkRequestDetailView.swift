//
//  NetworkRequestDetailView.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//

import SwiftUI

struct NetworkRequestDetailView: View {
    let request: NetworkRequest

    @State private var shareItem: ShareableFile?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                requestSection

                if !request.headers.isEmpty {
                    headersSection
                }

                if request.body != nil {
                    requestBodySection
                }

                if let response = request.response {
                    responseSection(response: response)

                    if !response.headers.isEmpty {
                        responseHeadersSection(response: response)
                    }

                    if response.body != nil {
                        responseBodySection(response: response)
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle("Request Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button("", systemImage: "square.and.arrow.up", action: {
            shareFullDetails()
        }))
        .sheet(item: $shareItem) { item in
            ShareSheet(activityItems: [item.url])
        }
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
    
    private var requestBodySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Request Body")
                    .font(.headline)
                Spacer()
                Button(action: {
                    shareRequestBody()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16))
                }
            }

            if let body = request.body {
                bodyContentView(data: body, headers: request.headers)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
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
    
    private func responseBodySection(response: NetworkResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Response Body")
                    .font(.headline)
                Spacer()
                Button(action: {
                    shareResponseBody(response: response)
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16))
                }
            }

            if let body = response.body {
                bodyContentView(data: body, headers: response.headers)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
    }
    
    // MARK: - Body Content View
    private func bodyContentView(data: Data, headers: [String: String]) -> some View {
        Group {
            let contentType = getContentType(from: headers)
            let maxDisplaySize = 100 * 1024 // 100KB

            if data.count > maxDisplaySize {
                // Show size info for large bodies
                VStack(alignment: .leading, spacing: 4) {
                    Text("Size: \(formatDataSize(bytes: data.count))")
                        .font(.system(size: 14, design: .monospaced))
                    Text("Content-Type: \(contentType)")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.secondary)
                    Text("Tap share button to export content")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .italic()
                }
            } else {
                // Display content for smaller bodies
                if contentType.lowercased().contains("application/json") {
                    ForEach(formatJSONContent(data: data), id: \.self) { line in
                        if #available(iOS 15.0, *) {
                            Text(line)
                                .font(.system(size: 14, weight: .regular, design: .monospaced))
                                .textSelection(.enabled)
                        } else {
                            Text(line)
                                .font(.system(size: 14, weight: .regular, design: .monospaced))
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Content-Type: \(contentType)")
                            .font(.system(size: 14, design: .monospaced))
                        Text("Size: \(formatDataSize(bytes: data.count))")
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.secondary)
                        if let stringContent = String(data: data, encoding: .utf8) {
                            if #available(iOS 15.0, *) {
                                Text(stringContent)
                                    .font(.system(size: 14, design: .monospaced))
                                    .textSelection(.enabled)
                            } else {
                                Text(stringContent)
                                    .font(.system(size: 14, design: .monospaced))
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Sharing Methods
    private func shareRequestBody() {
        guard let body = request.body else { return }
        let content = formatBodyAsText(data: body, headers: request.headers)
        shareContent(content, filename: "request_body.txt")
    }

    private func shareResponseBody(response: NetworkResponse) {
        guard let body = response.body else { return }
        let content = formatBodyAsText(data: body, headers: response.headers)
        shareContent(content, filename: "response_body.txt")
    }

    private func shareFullDetails() {
        let content = generateFullDetailsText()
        shareContent(content, filename: "network_request_details.txt")
    }

    private func shareContent(_ content: String, filename: String) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        do {
            // Remove existing file if it exists
            if FileManager.default.fileExists(atPath: tempURL.path) {
                try FileManager.default.removeItem(at: tempURL)
            }

            // Write the content
            try content.write(to: tempURL, atomically: true, encoding: .utf8)

            // Verify the file was written
            if FileManager.default.fileExists(atPath: tempURL.path) {
                print("✅ File written successfully: \(tempURL.path)")
                print("📄 File size: \(content.count) bytes")

                shareItem = ShareableFile(url: tempURL)
            } else {
                print("❌ File was not created at: \(tempURL.path)")
            }
        } catch {
            print("❌ Error writing file: \(error)")
            print("   Path: \(tempURL.path)")
        }
    }

    // MARK: - Text Generation
    private func formatBodyAsText(data: Data, headers: [String: String]) -> String {
        let contentType = getContentType(from: headers)

        if contentType.lowercased().contains("application/json") {
            if let jsonString = String(data: data, encoding: .utf8),
               let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                return prettyString
            } else if let jsonString = String(data: data, encoding: .utf8) {
                return jsonString
            }
        }

        // For non-JSON, try to convert to string
        if let stringContent = String(data: data, encoding: .utf8) {
            return stringContent
        } else {
            return "Binary data (\(formatDataSize(bytes: data.count)))"
        }
    }

    private func generateFullDetailsText() -> String {
        var text = "Network Request Details\n"
        text += "======================\n\n"

        text += "URL: \(request.url)\n"
        text += "Method: \(request.method)\n"
        text += "Timestamp: \(DateFormatter.localizedString(from: request.timestamp, dateStyle: .short, timeStyle: .medium))\n"
        text += "Status: \(request.status)\n\n"

        if !request.headers.isEmpty {
            text += "Request Headers:\n"
            text += "----------------\n"
            for (key, value) in request.headers.sorted(by: { $0.key < $1.key }) {
                text += "\(key): \(value)\n"
            }
            text += "\n"
        }

        if let body = request.body {
            text += "Request Body (\(formatDataSize(bytes: body.count))):\n"
            text += "-------------\n"
            text += formatBodyAsText(data: body, headers: request.headers)
            text += "\n\n"
        }

        if let response = request.response {
            text += "Response:\n"
            text += "---------\n"
            text += "Status Code: \(response.statusCode)\n"
            text += "Response Time: \(String(format: "%.3fs", response.responseTime))\n\n"

            if !response.headers.isEmpty {
                text += "Response Headers:\n"
                text += "-----------------\n"
                for (key, value) in response.headers.sorted(by: { $0.key < $1.key }) {
                    text += "\(key): \(value)\n"
                }
                text += "\n"
            }

            if let body = response.body {
                text += "Response Body (\(formatDataSize(bytes: body.count))):\n"
                text += "--------------\n"
                text += formatBodyAsText(data: body, headers: response.headers)
                text += "\n"
            }
        }

        return text
    }

    // MARK: - Helper Methods
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
            return ["❌ Failed to decode data as UTF-8 string. Size: \(formatDataSize(bytes: data.count))"]
        }

        guard !jsonString.isEmpty else {
            return ["⚠️ Empty JSON body"]
        }

        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])

            if let prettyString = String(data: prettyData, encoding: .utf8) {
                return [prettyString]
            } else {
                return [jsonString]
            }
        } catch {
            return ["⚠️ Invalid JSON (showing raw content): \(error.localizedDescription)", "", jsonString]
        }
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

// MARK: - Shareable File
struct ShareableFile: Identifiable {
    let id = UUID()
    let url: URL
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Configure popover for iPad on update
        if let popover = uiViewController.popoverPresentationController {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootView = window.rootViewController?.view {
                popover.sourceView = rootView
                popover.sourceRect = CGRect(x: rootView.bounds.midX, y: rootView.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
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
