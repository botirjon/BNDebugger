//
//  PerformanceDataPoint.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//

import Foundation

struct PerformanceDataPoint: Identifiable {
    let id = UUID()
    let value: Double
    let timestamp: Date
    
    init(value: Double, timestamp: Date = Date()) {
        self.value = value
        self.timestamp = timestamp
    }
}
