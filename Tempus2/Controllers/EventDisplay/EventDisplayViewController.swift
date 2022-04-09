//
//  EventDisplayTableViewController.swift
//  Tempus2
//
//  Created by Sola on 2021/9/1.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class EventDisplayViewController: UITableViewController {
    
    private var titleCell: EventDisplayCell!
    private var descriptionCell: EventDisplayCell!
        
    // MARK: - Models
    
    private var task: Task! {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - Controllers
    
    private var delegate: HomeViewController!
    
    // MARK: - Views
    
    private let eventCompletionTogglingBottomView: EventCompletionTogglingView = {
        let view = EventCompletionTogglingView()
        return view
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(
            EventDisplayCell.classForCoder(),
            forCellReuseIdentifier: EventDisplayViewController.eventDisplayCellReusableIdentifier
        )
        
        updateViews()
        updateLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.hideBarSeparator()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.showBarSeparator()
    }
    
    func updateViews() {
//        let editButton = UIBarButtonItem(
//            barButtonSystemItem: .edit,
//            target: self,
//            action: #selector(editButtonTapped)
//        )
        let editButton = UIBarButtonItem(
            image: UIImage(imageLiteralResourceName: "edit"),
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
        let deleteButton = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(deleteButtonTapped)
        )
        navigationItem.rightBarButtonItems = [deleteButton, editButton]
        
        tableView.separatorStyle = .none
        
        tableView.addSubview(eventCompletionTogglingBottomView)
        eventCompletionTogglingBottomView.updateValues(delegate: self)
    }
    
    func updateLayouts() {
        eventCompletionTogglingBottomView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(tableView.safeAreaLayoutGuide)
            make.height.equalTo(50)
        }
    }
    
    func updateValues(task: Task, delegate: HomeViewController) {
        self.task = task
        self.delegate = delegate
        
        eventCompletionTogglingBottomView.isCompleted = task.isCompleted
    }
}

extension EventDisplayViewController {
    
    // MARK: - UITableView Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            titleCell = EventDisplayCell()
            titleCell.updateValues(
                iconName: "title",
                attributedText: task.attributedRepresentation
            )
            return titleCell
        case 1:
            descriptionCell = EventDisplayCell()
            descriptionCell.updateValues(
                iconName: task.description.isEmpty
                    ? nil
                    : "description",
                attributedText: task.descriptionAttributedRepresentation
            )
            return descriptionCell
        default:
            return EventDisplayCell()
        }
    }
}

extension EventDisplayViewController {
    
    // MARK: - Utils
    
    private func displayDeletionWarning(completion: @escaping (_ shouldDelete: Bool) -> Void) {
        let deletionAlert = UIAlertController(
            title: nil,
            message: "Do you really want to delete the event: \(task.titleRepresentation)?",
            preferredStyle: .actionSheet
        )
        
        let shouldDeleteButton = UIAlertAction(
            title: "Delete",
            style: .destructive,
            handler: { (action) -> Void in
                completion(true)
        })
        
        let cancelButton = UIAlertAction(
            title: "Cancel",
            style: .cancel
        ) { (action) -> Void in
            completion(false)
        }
        
        deletionAlert.addAction(shouldDeleteButton)
        deletionAlert.addAction(cancelButton)
        
        self.present(deletionAlert, animated: true, completion: nil)
    }
}

extension EventDisplayViewController {
    
    // MARK: - Actions
    
    @objc private func editButtonTapped() {
        delegate.edit(task)
    }
    
    @objc private func deleteButtonTapped() {
        displayDeletionWarning { (shouldDelete) in
            if shouldDelete {
                self.delegate.remove(self.task)
                self.navigationController?.popViewController(animated: true)
            } else {
                return
            }
        }
    }
}

extension EventDisplayViewController: EventCompletionTogglingViewDelegate {
    
    // MARK: - EventCompletionTogglingView Delegate
    
    internal func toggleCompletion() {
        self.task.isCompleted.toggle()
        self.delegate.toggleCompletion(of: task)
        navigationController?.popViewController(animated: true)
    }
}

extension EventDisplayViewController: HomeViewControllerEditDelegate {
    
    // MARK: - HomeViewControllerEditDelegate
    
    internal func updateTaskWith(_ task: Task) {
        self.task = task
    }
}

extension EventDisplayViewController {
    static let eventDisplayCellReusableIdentifier = "EventDisplayCell"
}

protocol EventDisplayViewControllerDelegate {
    func edit(_ task: Task)
    func remove(_ task: Task)
    
    func toggleCompletion(of task: Task)
}
