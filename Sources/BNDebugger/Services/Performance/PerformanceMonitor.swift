//
//  PerformanceMonitor.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 11/09/25.
//

import Foundation
import UIKit

enum PerformaceMetric {
    case cpuUsage(Double)
    case memoryUsage(Double)
    case memoryUsageMB(Double)
    case launchTime(TimeInterval)
}

class PerformanceMonitor: PerformanceMonitoring {
    var cpuUsage: Double = 0.0
    var memoryUsage: Double = 0.0
    var memoryUsageMB: Double = 0.0
    var launchTime: TimeInterval = 0.0
    var cpuHistory: [PerformanceDataPoint] = []
    var memoryHistory: [PerformanceDataPoint] = []
    var isMonitoring: Bool = false
    
    private var timer: Timer?
    private var launchStartTime: Date?
    private let maxHistoryPoints = 60 // Keep 1 minute of data at 1-second intervals
    
    init() {
        setupLaunchTimeTracking()
    }
    
    // MARK: - Public Methods
    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateMetrics()
        }
        
        // Get initial reading
        updateMetrics()
    }
    
    func stopMonitoring() {
        guard isMonitoring else { return }
        isMonitoring = false
        timer?.invalidate()
        timer = nil
    }
    
    func clearHistory() {
        cpuHistory.removeAll()
        memoryHistory.removeAll()
    }
    
    // MARK: - Private Methods
    private func setupLaunchTimeTracking() {
        launchStartTime = Date()
        
        // Listen for app did finish launching
        NotificationCenter.default.addObserver(
            forName: UIApplication.didFinishLaunchingNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.calculateLaunchTime()
        }
        
        // Also listen for when the app becomes active (covers launch completion)
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.calculateLaunchTime()
        }
    }
    
    private func calculateLaunchTime() {
        guard let startTime = launchStartTime, launchTime == 0.0 else { return }
        launchTime = Date().timeIntervalSince(startTime)
    }
    
    private func updateMetrics() {
        let currentTime = Date()
        
        // Update CPU usage
        let cpuValue = getCPUUsage()
        cpuUsage = cpuValue
        
        // Update memory usage
        let (memoryPercent, memoryMB) = getMemoryUsage()
        memoryUsage = memoryPercent
        memoryUsageMB = memoryMB
        
        // Add to history
        addToHistory(cpu: cpuValue, memory: memoryPercent, timestamp: currentTime)
    }
    
    private func addToHistory(cpu: Double, memory: Double, timestamp: Date) {
        let cpuPoint = PerformanceDataPoint(value: cpu, timestamp: timestamp)
        let memoryPoint = PerformanceDataPoint(value: memory, timestamp: timestamp)
        
        cpuHistory.append(cpuPoint)
        memoryHistory.append(memoryPoint)
        
        // Keep only the last maxHistoryPoints
        if cpuHistory.count > maxHistoryPoints {
            cpuHistory.removeFirst()
        }
        if memoryHistory.count > maxHistoryPoints {
            memoryHistory.removeFirst()
        }
    }
    
    private func getCPUUsage() -> Double {
        var kr: kern_return_t
        var task_info_count: mach_msg_type_number_t
        
        task_info_count = mach_msg_type_number_t(TASK_INFO_MAX)
        var tinfo = [integer_t](repeating: 0, count: Int(task_info_count))
        
        kr = task_info(mach_task_self_, task_flavor_t(TASK_BASIC_INFO), &tinfo, &task_info_count)
        if kr != KERN_SUCCESS {
            return 0.0
        }
        
        var thread_list: thread_act_array_t? = nil
        var thread_count: mach_msg_type_number_t = 0
        defer {
            if let thread_list = thread_list, thread_count > 0 {
                vm_deallocate(mach_task_self_, vm_address_t(bitPattern: thread_list), vm_size_t(Int(thread_count) * MemoryLayout<thread_t>.size))
            }
        }
        
        kr = task_threads(mach_task_self_, &thread_list, &thread_count)
        if kr != KERN_SUCCESS {
            return 0.0
        }
        
        var total_cpu: Double = 0
        
        if let list = thread_list {
            for j in 0..<Int(thread_count) {
                var thread_info_count = mach_msg_type_number_t(THREAD_INFO_MAX)
                var thinfo = [integer_t](repeating: 0, count: Int(thread_info_count))
                kr = thread_info(list[j], thread_flavor_t(THREAD_BASIC_INFO),
                               &thinfo, &thread_info_count)
                if kr != KERN_SUCCESS {
                    continue
                }
                
                let thread_basic_info = convertThreadInfoToThreadBasicInfo(thinfo)
                
                if thread_basic_info.flags & TH_FLAGS_IDLE == 0 {
                    total_cpu += (Double(thread_basic_info.cpu_usage) / Double(TH_USAGE_SCALE)) * 100.0
                }
            }
        }
        
        return total_cpu
    }
    
    private func convertThreadInfoToThreadBasicInfo(_ threadInfo: [integer_t]) -> thread_basic_info {
        var result = thread_basic_info()
        
        result.user_time = time_value_t(seconds: threadInfo[0], microseconds: threadInfo[1])
        result.system_time = time_value_t(seconds: threadInfo[2], microseconds: threadInfo[3])
        result.cpu_usage = threadInfo[4]
        result.policy = threadInfo[5]
        result.run_state = threadInfo[6]
        result.flags = threadInfo[7]
        result.suspend_count = threadInfo[8]
        result.sleep_time = threadInfo[9]
        
        return result
    }
    
    private func getMemoryUsage() -> (percentage: Double, megabytes: Double) {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let usedMemoryMB = Double(info.resident_size) / 1024.0 / 1024.0
            
            // Get total physical memory
            let totalMemoryMB = Double(ProcessInfo.processInfo.physicalMemory) / 1024.0 / 1024.0
            let percentage = (usedMemoryMB / totalMemoryMB) * 100.0
            
            return (percentage: percentage, megabytes: usedMemoryMB)
        } else {
            return (percentage: 0.0, megabytes: 0.0)
        }
    }
    
    deinit {
        stopMonitoring()
        NotificationCenter.default.removeObserver(self)
    }
}
