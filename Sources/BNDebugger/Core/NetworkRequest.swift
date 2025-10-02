//
//  NetworkRequest.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 12/09/25.
//

import Foundation

struct NetworkRequest {
    let id = UUID()
    let url: String
    let method: String
    let headers: [String: String]
    let body: Data?
    let timestamp: Date
    var response: NetworkResponse?
    var status: RequestStatus = .pending
    
    enum RequestStatus {
        case pending
        case completed
        case failed
    }
}

struct NetworkResponse {
    let statusCode: Int
    let headers: [String: String]
    let body: Data?
    let responseTime: TimeInterval
}

struct NetworkRequestUpdate {
    let id: UUID
    let response: NetworkResponse?
    let status: NetworkRequest.RequestStatus
}
