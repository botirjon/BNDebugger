//
//  PerformanceGraphView.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//

import SwiftUI

struct PerformanceGraphView: View {
    let dataPoints: [PerformanceDataPoint]
    let title: String
    let color: Color
    let unit: String
    let maxValue: Double
    
    private let graphHeight: CGFloat = 120
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let latestPoint = dataPoints.last {
                    Text("\(latestPoint.value, specifier: "%.1f")\(unit)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(color)
                }
            }
            
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: graphHeight)
                
                // Grid lines
                GridLinesView()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                    .frame(height: graphHeight)
                
                // Graph line
                if dataPoints.count > 1 {
                    GraphLineView(
                        dataPoints: dataPoints,
                        maxValue: maxValue,
                        height: graphHeight,
                        color: color
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
            // Time labels
            HStack {
                Text("60s ago")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Now")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct GridLinesView: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Horizontal lines
        let horizontalLines = 4
        for i in 0...horizontalLines {
            let y = rect.height * CGFloat(i) / CGFloat(horizontalLines)
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        
        return path
    }
}

struct GraphLineView: View {
    let dataPoints: [PerformanceDataPoint]
    let maxValue: Double
    let height: CGFloat
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard dataPoints.count > 1 else { return }
                
                let width = geometry.size.width
                let stepX = width / CGFloat(max(dataPoints.count - 1, 1))
                
                for (index, point) in dataPoints.enumerated() {
                    let x = CGFloat(index) * stepX
                    let normalizedValue = point.value / maxValue
                    let y = height - (height * CGFloat(normalizedValue))
                    
                    let cgPoint = CGPoint(x: x, y: max(0, min(height, y)))
                    
                    if index == 0 {
                        path.move(to: cgPoint)
                    } else {
                        path.addLine(to: cgPoint)
                    }
                }
            }
            .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            
            // Fill area under the curve
            Path { path in
                guard dataPoints.count > 1 else { return }
                
                let width = geometry.size.width
                let stepX = width / CGFloat(max(dataPoints.count - 1, 1))
                
                // Start from bottom left
                path.move(to: CGPoint(x: 0, y: height))
                
                // Draw the curve
                for (index, point) in dataPoints.enumerated() {
                    let x = CGFloat(index) * stepX
                    let normalizedValue = point.value / maxValue
                    let y = height - (height * CGFloat(normalizedValue))
                    
                    let cgPoint = CGPoint(x: x, y: max(0, min(height, y)))
                    
                    if index == 0 {
                        path.addLine(to: cgPoint)
                    } else {
                        path.addLine(to: cgPoint)
                    }
                }
                
                // Close the path at bottom right
                if let lastPoint = dataPoints.last {
                    let lastX = width
                    path.addLine(to: CGPoint(x: lastX, y: height))
                }
                
                path.closeSubpath()
            }
            .fill(LinearGradient(
                colors: [color.opacity(0.3), color.opacity(0.1), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            ))
        }
        .frame(height: height)
    }
}

#Preview {
    let sampleData = (0...30).map { i in
        PerformanceDataPoint(
            value: Double.random(in: 0...100),
            timestamp: Date().addingTimeInterval(-Double(30-i))
        )
    }
    
    return VStack(spacing: 16) {
        PerformanceGraphView(
            dataPoints: sampleData,
            title: "CPU Usage",
            color: .blue,
            unit: "%",
            maxValue: 100
        )
        
        PerformanceGraphView(
            dataPoints: sampleData,
            title: "Memory Usage",
            color: .green,
            unit: "%",
            maxValue: 100
        )
    }
    .padding()
}
