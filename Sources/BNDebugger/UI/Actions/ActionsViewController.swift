//
//  ActionsViewController.swift
//  BNDebugger
//
//  Created by MAC-Nasridinov-B on 18/09/25.
//

import UIKit
import SwiftUI

class ActionsViewController: UIViewController {
    
    private lazy var child = UIHostingController(rootView: ActionsView())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(child)
        view.addSubview(child.view)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.topAnchor.constraint(equalTo: view.topAnchor),
            child.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Settings"
    }
}
