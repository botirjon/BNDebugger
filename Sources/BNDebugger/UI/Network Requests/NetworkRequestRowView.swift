//
//  NetworkRequestRowView.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//

import SwiftUI

struct NetworkRequestRowView: View {
    let request: NetworkRequest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(request.method)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.blue)
                
                Spacer()
                
                statusView
            }
            
            if #available(iOS 17.0, *) {
                Text(request.url)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundStyle(.link)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            } else {
                Text(request.url)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(Color.blue)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            HStack {
                if let mimeTypeTag = getMimeTypeTag() {
                    Text(mimeTypeTag.displayText)
                        .font(.system(size: 10, weight: .medium))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(mimeTypeTag.color.opacity(0.2))
                        .foregroundColor(mimeTypeTag.color)
                        .cornerRadius(8)
                }
                
                if let duration = getRequestDuration() {
                    Text(duration)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.pink)
                }
                
                Spacer()
                
                Text(formatTimestamp(request.timestamp))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .overlay(
            Rectangle()
                .frame(width: 3)
                .foregroundColor(colorForStatusCode(request.response?.statusCode ?? 0)),
            alignment: .leading
        )
    }
    
    @ViewBuilder
    private var statusView: some View {
        switch request.status {
        case .pending:
            Text("⏳ Pending")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.orange)
        case .completed:
            if let statusCode = request.response?.statusCode {
                Text("\(statusCode)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(colorForStatusCode(statusCode))
            } else {
                Text("Completed")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
            }
        case .failed:
            Text("❌ Failed")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.red)
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss - dd/MM"
        return formatter.string(from: date)
    }
    
    private func colorForStatusCode(_ statusCode: Int) -> Color {
        switch statusCode {
        case 200..<300:
            return .green
        case 400..<600:
            return .red
        default:
            return .secondary
        }
    }
    
    private func getMimeTypeTag() -> MimeTypeTag? {
        let contentType = getContentType()
        
        switch contentType.lowercased() {
        case let type where type.contains("application/json"):
            return MimeTypeTag(displayText: "JSON", color: .green)
        case let type where type.contains("application/xml") || type.contains("text/xml"):
            return MimeTypeTag(displayText: "XML", color: .orange)
        case let type where type.contains("text/html"):
            return MimeTypeTag(displayText: "HTML", color: .blue)
        case let type where type.contains("text/plain"):
            return MimeTypeTag(displayText: "TEXT", color: .gray)
        case let type where type.contains("image/"):
            return MimeTypeTag(displayText: "IMAGE", color: .purple)
        case let type where type.contains("video/"):
            return MimeTypeTag(displayText: "VIDEO", color: .red)
        case let type where type.contains("audio/"):
            return MimeTypeTag(displayText: "AUDIO", color: Color(red: 0.0, green: 0.8, blue: 0.8))
        case let type where type.contains("application/pdf"):
            return MimeTypeTag(displayText: "PDF", color: .red)
        case let type where type.contains("application/octet-stream"):
            return MimeTypeTag(displayText: "BINARY", color: .gray)
        case let type where type.contains("multipart/form-data"):
            return MimeTypeTag(displayText: "FORM", color: Color(red: 0.6, green: 0.4, blue: 0.2))
        case let type where type.contains("application/x-www-form-urlencoded"):
            return MimeTypeTag(displayText: "FORM", color: Color(red: 0.6, green: 0.4, blue: 0.2))
        default:
            return nil
        }
    }
    
    private func getContentType() -> String {
        // Check request Content-Type first
        for (key, value) in request.headers {
            if key.lowercased() == "content-type" {
                return value
            }
        }
        
        // Check response Content-Type
        if let responseHeaders = request.response?.headers {
            for (key, value) in responseHeaders {
                if key.lowercased() == "content-type" {
                    return value
                }
            }
        }
        
        return ""
    }
    
    private func getRequestDuration() -> String? {
        guard let responseTime = request.response?.responseTime else {
            return nil
        }
        
        if responseTime < 1.0 {
            return String(format: "%.0fms", responseTime * 1000)
        } else {
            return String(format: "%.2fs", responseTime)
        }
    }
}

struct MimeTypeTag {
    let displayText: String
    let color: Color
}

#Preview {
    let sampleRequest = NetworkRequest(
        url: "https://api.example.com/users",
        method: "GET",
        headers: ["Content-Type": "application/json"],
        body: nil,
        timestamp: Date(),
        response: NetworkResponse(statusCode: 200, headers: ["content-type": "application/json"], body: nil, responseTime: 200)
    )
    
    return List {
        NetworkRequestRowView(request: sampleRequest)
    }
}
