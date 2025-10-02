//
//  NetworkIntercepting.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 12/09/25.
//


protocol NetworkIntercepting: AnyObject {
    func startIntercepting()
    func stopIntercepting()
}
