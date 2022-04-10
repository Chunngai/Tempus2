//
//  TypeViewController.swift
//  Tempus2
//
//  Created by Sola on 2022/4/10.
//  Copyright © 2022 Sola. All rights reserved.
//

import UIKit

class TypeViewController: UITableViewController {

    // MARK: - Controllers
    
    private var delegate: TypeCell!
    
    // MARK: - Views
    
    private var eventCell: UITableViewCell = {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "Event"
        cell.selectionStyle = .none
        return cell
    }()
    private var taskCell: UITableViewCell = {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "Task"
        cell.selectionStyle = .none
        return cell
    }()
    private var dueCell: UITableViewCell = {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "Due"
        cell.selectionStyle = .none
        return cell
    }()
    private lazy var cells: [UITableViewCell] = [
        eventCell,
        taskCell,
        dueCell
    ]
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
    }
    
    private func updateViews() {
        navigationItem.title = "Types"
    }
    
    internal func updateValues(type: Task.Type_, delegate: TypeCell) {
        cells[type.rawValue].accessoryType = .checkmark
        self.delegate = delegate
    }
}

extension TypeViewController {
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
}
 
extension TypeViewController {
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Adds check mark.
        for cell in cells {
            cell.accessoryType = .none
        }
        cells[indexPath.row].accessoryType = .checkmark
        
        // Updates type by the delegate.
        delegate.type = Task.Type_(rawValue: indexPath.row)
    }
}
