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
    
    private var delegate: TypeViewControllerDelegate!
    
    // MARK: - Views
    
    private var cells: [UITableViewCell] = Task.typeStrings.map { typeString in
        {
            let cell = UITableViewCell(
                style: .default,
                reuseIdentifier: nil
            )
            cell.textLabel?.text = typeString
            cell.selectionStyle = .none
            return cell
        }()
    }
    
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
        
        if let taskType = Task.Type_(rawValue: indexPath.row) {
            delegate.updateType(as: taskType)
        }
    }
}

protocol TypeViewControllerDelegate {
    
    func updateType(as taskType: Task.Type_)
    
}
