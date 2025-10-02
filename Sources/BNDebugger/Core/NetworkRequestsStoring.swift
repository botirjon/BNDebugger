//
//  NetworkRequestsStoring.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 12/09/25.
//

protocol NetworkRequestsStoring: AnyObject {
    func getAllRequests() -> [NetworkRequest]
    func clearRequests()
}
