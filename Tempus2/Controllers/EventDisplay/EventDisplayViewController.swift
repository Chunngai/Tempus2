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
        
    private var isTimetableMode: Bool!
    
    // MARK: - Models
    
    private var task: Task! {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - Controllers
    
    private var delegate: HomeTimetableDelegate!
    
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
        
        let deleteButton = UIBarButtonItem(
            image: UIImage(imageLiteralResourceName: "delete"),
            style: .plain,
            target: self,
            action: #selector(deleteButtonTapped)
        )
        let editButton = UIBarButtonItem(
            image: UIImage(imageLiteralResourceName: "edit"),
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
        navigationItem.rightBarButtonItems = [deleteButton, editButton]
        
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
        tableView.separatorStyle = .none
    }
    
    func updateLayouts() {
    }
    
    func updateValues(task: Task, delegate: HomeTimetableDelegate, isTimetableMode: Bool = false) {
        self.task = task
        self.delegate = delegate
        
        self.isTimetableMode = isTimetableMode
        if !self.isTimetableMode {
            let toNextDayButton = UIBarButtonItem(
                image: UIImage(imageLiteralResourceName: "to_next_day"),
                style: .plain,
                target: self,
                action: #selector(toNextDayButtonTapped)
            )
            navigationItem.rightBarButtonItems?.append(toNextDayButton)
            
            tableView.addSubview(eventCompletionTogglingBottomView)
            eventCompletionTogglingBottomView.updateValues(delegate: self)
            eventCompletionTogglingBottomView.snp.makeConstraints { (make) in
                let bottomSafeAreaInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
                make.leading.trailing.equalTo(tableView.safeAreaLayoutGuide)
                make.bottom.equalTo(tableView.safeAreaLayoutGuide).offset(bottomSafeAreaInset)
                make.height.equalTo(80)
            }
        }
        
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
                attributedText: task.isTimetableTask ?
                    task.attributedRepresentationForTimetableTask :
                    task.attributedRepresentation
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
    
    private func displayToNextDayConflictedWarning(conflictedTask: Task) {
      let alert = UIAlertController(
            title: "Date Interval Conflict",
            message: "Date interval after changing conflicts with task:  \(conflictedTask.title)"
                + " (\(conflictedTask.timeReprsentation))",
            preferredStyle: .alert
        )
        
        let okButton = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        )
        
        alert.addAction(okButton)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension EventDisplayViewController {
    
    // MARK: - Actions
    
    @objc private func toNextDayButtonTapped() {
        if let task = task {
            var newTask = task
            newTask.dateInterval = DateInterval(
                start: newTask.dateInterval.start + TimeInterval.Day,
                end: newTask.dateInterval.end + TimeInterval.Day
            )
            if let conflictedTask = delegate.taskConflicted(with: newTask) {
                displayToNextDayConflictedWarning(conflictedTask: conflictedTask)
                return
            }
            delegate.remove(task)
            (delegate as! HomeViewController).toNextDay()
            navigationController?.popViewController(animated: true)
            delegate.add(newTask)
        }
    }
    
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
        (self.delegate as! HomeViewController).toggleCompletion(of: task)
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
    func toggleCompletion(of task: Task)
}
