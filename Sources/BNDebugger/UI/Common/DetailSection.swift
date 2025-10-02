//
//  DetailSection.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//
import SwiftUI

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
    
    let valueFont: Font?
    let valueColor: Color?
    
    init(label: String, value: String, valueFont: Font? = nil, valueColor: Color? = nil) {
        self.label = label
        self.value = value
        self.valueFont = valueFont
        self.valueColor = valueColor
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            if #available(iOS 15.0, *) {
                Text(value)
                    .font(valueFont ?? .system(size: 14, design: .monospaced))
                    .textSelection(.enabled)
                    .foregroundStyle(valueColor ?? .primary)
            } else {
                Text(value)
                    .font(valueFont ?? .system(size: 14, design: .monospaced))
                    .foregroundColor(valueColor ?? .primary)
            }
        }
    }
}
