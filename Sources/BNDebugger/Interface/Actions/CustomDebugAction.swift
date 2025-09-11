//
//  CustomDebugAction.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 10/09/25.
//

public struct CustomDebugAction: DebugAction {
    public let title: String
    public let description: String?
    public let action: () -> Void?
    
    public init(title: String, description: String?, action: @escaping () -> Void?) {
        self.title = title
        self.description = description
        self.action = action
    }
    
    func execute() {
        action()
    }
}
