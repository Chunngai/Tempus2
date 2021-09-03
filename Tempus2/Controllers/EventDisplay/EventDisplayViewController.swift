//
//  EventDisplayTableViewController.swift
//  Tempus2
//
//  Created by Sola on 2021/9/1.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class EventDisplayViewController: UITableViewController {
    
    var titleCell: EventDisplayCell!
    var DateIntervalCell: EventDisplayCell!
    var descriptionCell: EventDisplayCell!
        
    // MARK: - Models
    
    var task: Task! {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - Controllers
    
    var delegate: HomeViewController!
    
    // MARK: - Views
    
    var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: nil,
            action: nil
        )
        return button
    }()
    
    var deleteButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: nil,
            action: nil
        )
        return button
    }()
    
    let eventCompletionTogglingBottomView: EventCompletionTogglingView = {
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
    
    // https://stackoverflow.com/questions/26390072/how-to-remove-border-of-the-navigationbar-in-swift
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = nil
    }
    
    func updateViews() {
        editButton.target = self
        editButton.action = #selector(editButtonTapped)
        deleteButton.target = self
        deleteButton.action = #selector(deleteButtonTapped)
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
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        switch row {
        case 0:
            let title = task.title
            let time = task.dateInterval.start.dateRepr
                + " · "
                + task.dateInterval.start.timeRepr + "-" +  task.dateInterval.end.timeRepr
            let attributedText = NSMutableAttributedString(string: title  + "\n" + time)
            
            // TODO: wrap the code here.
            attributedText.set(attributes: [.font : Theme.title2Font], for: title)
            if task.isCompleted {
                attributedText.set(attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .strikethroughColor: UIColor.black,
                    .font : Theme.title2Font
                ], for: title)
            }
            
            attributedText.set(attributes: [.font : Theme.bodyFont], for: time)
            
            attributedText.set(attributes: [.paragraphStyle : {
                let paraStyle = NSMutableParagraphStyle()
                paraStyle.lineSpacing = 10
                return paraStyle
            }()])
            
            titleCell = tableView.dequeueReusableCell(
                withIdentifier: EventDisplayViewController.eventDisplayCellReusableIdentifier,
                for: indexPath
                ) as? EventDisplayCell
            titleCell.updateValues(
                icon: "title",
                attributedText: attributedText,
                delegate: self,
                row: row
            )
            return titleCell
        case 1:
            if task.description.isEmpty {
                break
            }
            
            let attributedText = NSMutableAttributedString(string: task.description)
            attributedText.set(attributes: [.font : Theme.bodyFont])
            
            descriptionCell = tableView.dequeueReusableCell(
                withIdentifier: EventDisplayViewController.eventDisplayCellReusableIdentifier,
                for: indexPath
                ) as? EventDisplayCell
            descriptionCell.updateValues(
                icon: "description",
                attributedText: attributedText,
                delegate: self,
                row: row
            )
            return descriptionCell
        default:
            break
        }
        return UITableViewCell()
    }
}

extension EventDisplayViewController {
    // MARK: - Actions
    
    @objc func editButtonTapped() {
        delegate.edit(task)
    }
    
    @objc func deleteButtonTapped() {
        delegate.delete(task)
        navigationController?.popViewController(animated: true)
    }
}

extension EventDisplayViewController: EventCompletionTogglingViewDelegate {
    func toggleCompletion() {
        self.task.isCompleted.toggle()
        eventCompletionTogglingBottomView.isCompleted = task.isCompleted
        
        self.delegate.toggleCompletion(of: task)
    }
}

extension EventDisplayViewController {    
    static let eventDisplayCellReusableIdentifier = "EventDisplayCell"
}

protocol EventDisplayViewControllerDelegate {
    func edit(_ task: Task)
    func delete(_ task: Task)
    
    func toggleCompletion(of task: Task)
}
