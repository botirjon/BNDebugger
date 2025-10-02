//
//  PerformanceViewModel.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 13/09/25.
//

import Foundation
import Combine

class PerformanceViewModel: ObservableObject {
    @Published var cpuUsage: Double = 0.0
    @Published var memoryUsage: Double = 0.0
    @Published var memoryUsageMB: Double = 0.0
    @Published var launchTime: TimeInterval = 0.0
    @Published var cpuHistory: [PerformanceDataPoint] = []
    @Published var memoryHistory: [PerformanceDataPoint] = []
    @Published var isMonitoring: Bool = false
    
    private let performanceMonitor: PerformanceMonitoring
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    
    init(performanceMonitor: PerformanceMonitoring) {
        self.performanceMonitor = performanceMonitor
        setupBindings()
    }
    
    private func setupBindings() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updatePublishedValues()
        }
    }
    
    private func updatePublishedValues() {
        cpuUsage = performanceMonitor.cpuUsage
        memoryUsage = performanceMonitor.memoryUsage
        memoryUsageMB = performanceMonitor.memoryUsageMB
        launchTime = performanceMonitor.launchTime
        cpuHistory = performanceMonitor.cpuHistory
        memoryHistory = performanceMonitor.memoryHistory
    }
    
    func startMonitoring() {
        performanceMonitor.startMonitoring()
        isMonitoring = true
    }
    
    func stopMonitoring() {
        performanceMonitor.stopMonitoring()
        isMonitoring = false
    }
    
    func clearHistory() {
        performanceMonitor.clearHistory()
    }
    
    func toggleMonitoring() {
        if isMonitoring {
            stopMonitoring()
        } else {
            startMonitoring()
        }
    }
    
    deinit {
        timer?.invalidate()
        cancellables.removeAll()
    }
}