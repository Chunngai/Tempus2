//
//  HomeViewController.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    private var horizontalSeparatorYOffset: CGFloat! {
        (tableView.visibleCells.first as? TimeSliceCell)?
            .horizontalSeparatorYOffset
    }
    
    // MARK: - Models
    
    private var tasks: [Task]! {
        didSet {
            tasks.sort {
                $0.dateInterval.start < $1.dateInterval.start
            }
            Task.save(tasks)
            
            if tableView.frame != .zero {
                drawTasks()
            }
        }
    }
    
    // MARK: - Views
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let newEventButtonShadowView: UIView = {
        let shadowView = UIView()
        shadowView.layer.shadowColor = UIColor.gray.cgColor
        shadowView.layer.shadowOpacity = 0.3
        shadowView.layer.shadowRadius = 2
        shadowView.layer.shadowOffset = CGSize(width: 3, height: 3)
        return shadowView
    }()
    
    private let newEventButton: UIButton = {
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.setTitleColor(Theme.textColor, for: .normal)
        button.titleLabel?.font = Theme.title1Font
        button.backgroundColor = .white
        // https://stackoverflow.com/questions/26050655/how-to-create-a-circular-button-in-swift
        button.layer.cornerRadius = 0.5 * CGFloat(HomeViewController.newEventButtonDiameter)
        button.clipsToBounds = true
        return button
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Loads tasks.
        tasks = Task.load()
        
        // Table view configs.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            TimeSliceCell.classForCoder(),
            forCellReuseIdentifier: HomeViewController.timeSliceCellReuseIdentifier
        )
        
        newEventButton.addTarget(
            self,
            action: #selector(newEventButtonTapped),
            for: .touchUpInside
        )
        
        updateViews()
        updateLayouts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        drawTasks()
    }
    
    func updateViews() {
        navigationItem.title = Date().dateRepr
        
        view.addSubview(tableView)
        
        view.addSubview(newEventButtonShadowView)
        newEventButtonShadowView.addSubview(newEventButton)
    }
    
    func updateLayouts() {
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.width.equalToSuperview()
        }
        
        newEventButtonShadowView.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        
        newEventButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalTo(HomeViewController.newEventButtonDiameter)
            make.height.equalTo(HomeViewController.newEventButtonDiameter)
        }
    }
}

extension HomeViewController {
    
    // MARK: - Actions
    
    @objc private func newEventButtonTapped() {
        let taskViewController = EventEditViewController()
        taskViewController.updateValues(delegate: self)
        navigationController?.present(
            EventEditNavController(rootViewController: taskViewController),
            animated: true,
            completion: nil
        )
    }
}

extension HomeViewController {
    
    // MARK: - Utils
    
    private func drawTasks() {
        // Clears current event cells.
        for subView in tableView.subviews {
            if let homeEventCell = subView as? HomeEventCell {
                homeEventCell.removeFromSuperview()
            }
        }
        
        for task in tasks {
            draw(task)
        }
    }
    
    private func draw(_ task: Task) {
        let startH = task.dateInterval.start.getComponent(.hour)
        let endH = task.dateInterval.end.getComponent(.hour)
        let hs = endH - startH
        
        let startM = task.dateInterval.start.getComponent(.minute)
        let endM = task.dateInterval.end.getComponent(.minute)
        let ms = endM - startM
        
        let top = HomeViewController.timeSliceCellHeight
            * (CGFloat(startH) + CGFloat(startM) / CGFloat(TimeInterval.secsOfOneMinute))
            + horizontalSeparatorYOffset
        var height = HomeViewController.timeSliceCellHeight
            * (CGFloat(hs) + CGFloat(ms) / CGFloat(TimeInterval.secsOfOneMinute))
        // Min height limitation.
        if height < HomeViewController.timeSliceCellHeight / 2 {
            height = HomeViewController.timeSliceCellHeight / 2
        }
                
        let eventCell = HomeEventCell()
        tableView.addSubview(eventCell)
        eventCell.updateValues(task: task, delegate: self)
        eventCell.snp.makeConstraints { (make) in
            make.leading.equalTo(HomeViewController.homeEventCellLeading)
            make.width.equalTo(HomeViewController.homeEventCellWidth * 0.98)
            make.top.equalTo(top)
            make.height.equalTo(height)
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    
    // MARK: - UITableView Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        24
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeViewController.timeSliceCellReuseIdentifier)
            as! TimeSliceCell
        
        let hour = indexPath.row
        cell.updateValues(hour: hour)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HomeViewController.timeSliceCellHeight
    }
}

extension HomeViewController: UITableViewDelegate {
    
    // MARK: - UITableView Delegate
}

extension HomeViewController: EventEditViewControllerDelegate {
    
    // MARK: - EventEditViewController Delegate
    
    internal func add(_ task: Task) {
        tasks.append(task)
    }
    
    internal func replace(_ oldTask: Task, with newTask: Task) {
        tasks.replace(oldTask, with: newTask)
        // Updates the displaying event.
        if let eventDisplayController = navigationController?.topViewController
            as? EventDisplayViewController {
            eventDisplayController.updateTaskWith(newTask)
        }
    }
    
    internal func findTaskConflicted(with newTask: Task) -> Task? {
        for task in tasks {
            if task.dateInterval.intersects(newTask.dateInterval) {
                return task
            }
        }
        return nil
    }
}

extension HomeViewController: HomeEventCellDelegate {
    
    // MARK: - HomeEventCell Delegate
    
    internal func display(_ task: Task) {
        navigationItem.hideBackBarButtonItem()
        
        let eventDisplayViewController = EventDisplayViewController()
        eventDisplayViewController.updateValues(task: task, delegate: self)
        navigationController?.pushViewController(
            eventDisplayViewController,
            animated: true
        )
    }
}

extension HomeViewController: EventDisplayViewControllerDelegate {
    
    // MARK: - EventDisplayViewController Delegate
    
    internal func edit(_ task: Task) {
        let eventEditViewController = EventEditViewController()
        eventEditViewController.updateValues(task: task, delegate: self)
        navigationController?.present(
            EventEditNavController(rootViewController: eventEditViewController),
            animated: true,
            completion: nil
        )
    }
    
    internal func remove(_ task: Task) {
        tasks.remove(task)
    }
    
    internal func toggleCompletion(of task: Task) {
        guard let index = tasks.firstIndex(of: task) else {
            return
        }
        tasks[index].isCompleted.toggle()
    }
}

extension HomeViewController {
    static let timeSliceCellHeight: CGFloat = 60
    static let timeSliceCellReuseIdentifier: String = "TimeSliceCell"
    
    static var homeEventCellLeading: CGFloat {
        CGFloat(
            TimeSliceCell.timeSliceLabelLeadingOffset
                + TimeSliceCell.timeSliceLabelWidth
                + TimeSliceCell.verticalSeparatorLeadingOffset
        )
    }
    static var homeEventCellWidth: CGFloat {
        CGFloat(UIScreen.main.bounds.width - HomeViewController.homeEventCellLeading)
    }
 
    static let newEventButtonDiameter = 65
}

protocol HomeViewControllerYOffsetDelegate {
    var horizontalSeparatorYOffset: CGFloat { get }
}

protocol HomeViewControllerEditDelegate {
    func updateTaskWith(_ task: Task)
}
