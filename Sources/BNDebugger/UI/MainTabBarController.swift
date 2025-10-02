//
//  MainTabBarController.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 18/09/25.
//

import UIKit
import SwiftUI

class MainTabBarController: UITabBarController {
    
    let networkRequestsViewModel: NetworkRequestsViewModel
    let performanceViewModel: PerformanceViewModel
    let resourcesViewModel: ResourcesViewModel
    
    init(networkInterceptor: NetworkIntercepting, networkRequestsStore: NetworkRequestsStoring, performanceMonitor: PerformanceMonitoring) {
        networkRequestsViewModel = .init(networkInterceptor: networkInterceptor, networkRequestsStore: networkRequestsStore)
        performanceViewModel = .init(performanceMonitor: performanceMonitor)
        resourcesViewModel = .init()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var networkRequestsController = NetworkRequestsViewController(viewModel: networkRequestsViewModel)
    private lazy var performanceController = PerformanceViewController(viewModel: performanceViewModel)
    private lazy var resourcesController = ResourcesViewController(viewModel: resourcesViewModel)
    private lazy var actionsController = ActionsViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [
            networkRequestsController.wrapInNavigationController(),
            performanceController.wrapInNavigationController(),
            resourcesController.wrapInNavigationController(),
            actionsController.wrapInNavigationController()
        ]
        networkRequestsController.tabBarItem = UITabBarItem(title: "Network", image: .init(systemName: "network"), tag: 0)
        performanceController.tabBarItem = UITabBarItem(title: "Performance", image: .init(systemName: "speedometer"), tag: 1)
        resourcesController.tabBarItem = UITabBarItem(title: "Resources", image: .init(systemName: "folder.fill"), tag: 2)
        actionsController.tabBarItem = UITabBarItem(title: "Actions", image: .init(systemName: "gearshape"), tag: 3)
    }
}

extension UIViewController {
    func wrapInNavigationController() -> UINavigationController {
        UINavigationController(rootViewController: self)
    }
}
