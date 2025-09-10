//
//  ActionsViewController.swift
//  Debugger
//
//  Created by MAC-Nasridinov-B on 10/09/25.
//

import UIKit

// MARK: - Actions View Controller
class ActionsViewController: UIViewController {
    
    private struct DebugActionsSection {
        let title: String
        let actions: [DebugAction]
    }
    
    private let tableView = UITableView()
    
    private var sections = [DebugActionsSection]()
        
    private let defaultSection = DebugActionsSection(title: "Actions", actions: [
        DefaultDebugAction(title: "App Info", actionType: .appInfo),
        DefaultDebugAction(title: "Show UserDefaults", actionType: .showUserDefaults),
        DefaultDebugAction(title: "Simulate Memory Warning", actionType: .simulateMemoryWarning)
    ])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSections()
    }
    
    private func setupSections() {
        sections = [
            DebugActionsSection(title: "Custom Actions", actions: DebugManager.shared.customActions),
            defaultSection
        ]
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ActionCell")
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ActionsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].actions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath)
        let action = sections[indexPath.section].actions[indexPath.row]
        cell.textLabel?.text = action.title
        cell.detailTextLabel?.text = action.description
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let action = sections[indexPath.section].actions[indexPath.row]
        
        if let action = action as? DefaultDebugAction {
            handleDefaultAction(action)
        } else if let action = action as? CustomDebugAction {
            handleCustomAction(action)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ActionsSectionHeaderView()
        header.text = sections[section].title
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: - Handle actions
    
    private func handleDefaultAction(_ action: DefaultDebugAction) {
        switch action.actionType {
        case .appInfo:
            break
        case .showUserDefaults:
            break
        case .simulateMemoryWarning:
            break
        }
    }
    
    private func handleCustomAction(_ action: CustomDebugAction) {
        action.execute()
    }
}

private class ActionsSectionHeaderView: UIView {
    private let label = UILabel()
    
    var text: String? {
        set { label.text = newValue }
        get { label.text }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.font = .boldSystemFont(ofSize: 24)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
        
        backgroundColor = .white
    }
}
