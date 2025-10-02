//
//  PerformanceView.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//

import SwiftUI

struct PerformanceView: View {
    @ObservedObject private var viewModel: PerformanceViewModel
    
    init(viewModel: PerformanceViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Launch Time Card
                LaunchTimeCard(launchTime: viewModel.launchTime)
                
                // Real-time Metrics
                RealTimeMetricsCard(
                    cpuUsage: viewModel.cpuUsage,
                    memoryUsage: viewModel.memoryUsage,
                    memoryUsageMB: viewModel.memoryUsageMB
                )
                
                // CPU Usage Graph
                PerformanceGraphView(
                    dataPoints: viewModel.cpuHistory,
                    title: "CPU Usage",
                    color: .blue,
                    unit: "%",
                    maxValue: 100
                )
                
                // Memory Usage Graph
                PerformanceGraphView(
                    dataPoints: viewModel.memoryHistory,
                    title: "Memory Usage",
                    color: .green,
                    unit: "%",
                    maxValue: 100
                )
                
                // Controls
                ControlsCard(
                    isMonitoring: viewModel.isMonitoring,
                    onStartStop: viewModel.toggleMonitoring,
                    onClearHistory: viewModel.clearHistory
                )
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .onAppear {
            if !viewModel.isMonitoring {
                viewModel.startMonitoring()
            }
        }
        .onDisappear {
            if viewModel.isMonitoring {
                viewModel.stopMonitoring()
            }
        }
    }
}

struct LaunchTimeCard: View {
    let launchTime: TimeInterval
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bolt.circle.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("App Launch Time")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            HStack {
                Text(launchTime > 0 ? String(format: "%.3f seconds", launchTime) : "Calculating...")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Spacer()
                
                if launchTime > 0 {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(performanceDescription(for: launchTime))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(performanceColor(for: launchTime))
                        
                        Text("Last Launch")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func performanceDescription(for time: TimeInterval) -> String {
        switch time {
        case ..<1.0:
            return "Excellent"
        case 1.0..<2.0:
            return "Good"
        case 2.0..<3.0:
            return "Average"
        default:
            return "Slow"
        }
    }
    
    private func performanceColor(for time: TimeInterval) -> Color {
        switch time {
        case ..<1.0:
            return .green
        case 1.0..<2.0:
            return .blue
        case 2.0..<3.0:
            return .orange
        default:
            return .red
        }
    }
}

struct RealTimeMetricsCard: View {
    let cpuUsage: Double
    let memoryUsage: Double
    let memoryUsageMB: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "speedometer")
                    .foregroundColor(.purple)
                    .font(.title2)
                
                Text("Real-time Metrics")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                // CPU Usage
                VStack(alignment: .leading, spacing: 4) {
                    Text("CPU")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(cpuUsage, specifier: "%.1f")%")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                Divider()
                    .frame(height: 40)
                
                // Memory Usage
                VStack(alignment: .leading, spacing: 4) {
                    Text("Memory")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Text("\(memoryUsage, specifier: "%.1f")%")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                        
                        Text("(\(memoryUsageMB, specifier: "%.0f") MB)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct ControlsCard: View {
    let isMonitoring: Bool
    let onStartStop: () -> Void
    let onClearHistory: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "gear")
                    .foregroundColor(.gray)
                    .font(.title2)
                
                Text("Controls")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                Button(action: onStartStop) {
                    HStack {
                        Image(systemName: isMonitoring ? "pause.circle.fill" : "play.circle.fill")
                        Text(isMonitoring ? "Pause" : "Start")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(isMonitoring ? Color.orange : Color.blue)
                    .cornerRadius(8)
                }
                
                Button(action: onClearHistory) {
                    HStack {
                        Image(systemName: "trash.circle.fill")
                        Text("Clear History")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.red)
                    .cornerRadius(8)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

private class MockPerformanceMonitor: PerformanceMonitoring {
    var cpuUsage: Double = 23
    
    var memoryUsage: Double = 12
    
    var memoryUsageMB: Double = 123
    
    var launchTime: TimeInterval = 0.666
    
    var cpuHistory: [PerformanceDataPoint] = []
    
    var memoryHistory: [PerformanceDataPoint] = []
    
    var isMonitoring: Bool = false
    
    init() {
        let now = Date()
        cpuHistory = (0..<60).map({ i in
                .init(value: .random(in: 0...100), timestamp: now.addingTimeInterval(-Double(60-i)))
        })
        memoryHistory = (0..<60).map({ i in
                .init(value: .random(in: 0...100), timestamp: now.addingTimeInterval(-Double(60-i)))
        })
    }
    
    func startMonitoring() {
        isMonitoring = true
    }
    
    func stopMonitoring() {
        isMonitoring = false
    }
    
    func clearHistory() {
        memoryHistory = []
        cpuHistory = []
    }
}

#Preview {
    let performanceMonitor = MockPerformanceMonitor()
    let viewModel = PerformanceViewModel(performanceMonitor: performanceMonitor)
    PerformanceView(viewModel: viewModel)
}
