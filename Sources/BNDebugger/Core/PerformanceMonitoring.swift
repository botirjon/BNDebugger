//
//  PerformanceMonitoring.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 13/09/25.
//

import Foundation

protocol PerformanceMonitoring {
    var cpuUsage: Double { get }
    var memoryUsage: Double { get }
    var memoryUsageMB: Double { get }
    var launchTime: TimeInterval { get }
    var cpuHistory: [PerformanceDataPoint] { get }
    var memoryHistory: [PerformanceDataPoint] { get }
    var isMonitoring: Bool { get }
    
    func startMonitoring()
    func stopMonitoring()
    func clearHistory()
}
