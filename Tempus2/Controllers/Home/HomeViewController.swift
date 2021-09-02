//
//  ScheduleViewController.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var offset: CGFloat!
    
    // MARK: - Models
    
    var tasks: [Task]! {
        didSet {
            tasks.sort { $0.dateInterval.start < $1.dateInterval.start }
            Task.save(tasks)
            
            if tableView.frame != .zero {
                drawTasks()
            }
        }
    }
    
    // MARK: - Views
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        return tableView
    }()
    
    let newEventButtonShadowView: UIView = {
        let shadowView = UIView()
        shadowView.layer.shadowColor = UIColor.gray.cgColor
        shadowView.layer.shadowOpacity = 0.3
        shadowView.layer.shadowRadius = 2
        shadowView.layer.shadowOffset = CGSize(width: 3, height: 3)
        return shadowView
    }()
    
    // https://stackoverflow.com/questions/26050655/how-to-create-a-circular-button-in-swift
    let newEventButton: UIButton = {
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = Theme.title1Font
        button.layer.cornerRadius = 0.5 * CGFloat(HomeViewController.newEventButtonDiameter)
        button.clipsToBounds = true
        button.backgroundColor = .white
        return button
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Loads tasks.
        tasks = Task.loadTasks()
        
        // Table view configs.
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.register(
            TimeSliceCell.classForCoder(),
            forCellReuseIdentifier: HomeViewController.cellReuseIdentifier
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
        offset = (tableView.visibleCells.first as? TimeSliceCell)?.horizontalSeparator.frame.minY
        
        drawTasks()
    }
    
    func updateViews() {
        navigationItem.title = Date().localDateRepr
        
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
    
    @objc func newEventButtonTapped() {
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
    
    func drawTasks() {
        for subView in tableView.subviews {
            if let homeEventCell = subView as? HomeEventCell {
                homeEventCell.removeFromSuperview()
            }
        }
        
        for task in tasks {
            draw(task)
        }
    }
    
    func draw(_ task: Task) {
        let startH = task.dateInterval.start.getComponent(.hour)
        let endH = task.dateInterval.end.getComponent(.hour)
        let hs = endH - startH
        
        let startM = task.dateInterval.start.getComponent(.minute)
        let endM = task.dateInterval.end.getComponent(.minute)
        let ms = endM - startM
        
        let taskCellTop = HomeViewController.cellHeight * (CGFloat(startH) + CGFloat(startM) / 60)
            + offset
        var taskCellHeight = HomeViewController.cellHeight * (CGFloat(hs) + CGFloat(ms) / 60)
        // Min height limitation.
        if taskCellHeight < HomeViewController.cellHeight / 2 {
            taskCellHeight = HomeViewController.cellHeight / 2
        }
        
        // TODO: wrap the code above.
        
        let taskCell = HomeEventCell()
        taskCell.updateValues(task: task, delegate: self)
        tableView.addSubview(taskCell)
        taskCell.snp.makeConstraints { (make) in
            make.leading.equalTo(HomeViewController.taskCellLeading)
            make.width.equalTo(HomeViewController.taskCellWidth * 0.98)
            make.top.equalTo(taskCellTop)
            make.height.equalTo(taskCellHeight)
        }
    }
}

extension HomeViewController {
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 24
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeViewController.cellReuseIdentifier)
            as! TimeSliceCell
        
        let h = indexPath.row
        cell.updateValues(time: String(format: "%02d:00", h))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HomeViewController.cellHeight
    }
    
    
}

extension HomeViewController: TaskViewControllerDelegate {
    func add(_ task: Task) {
        tasks.append(task)
    }
    
    func replace(_ oldTask: Task, with newTask: Task) {
        guard let index = tasks.firstIndex(of: oldTask) else {
            return
        }
        tasks.replaceSubrange(index...index, with: [newTask])
        
        if let displayController = navigationController?.topViewController as? EventDisplayViewController {
            displayController.task = newTask
        }
    }
}

extension HomeViewController: TaskCellDelegate {
    func showEvent(of task: Task) {
        // https://stackoverflow.com/questions/28471164/how-to-set-back-button-text-in-swift
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        let eventDisplayViewController = EventDisplayViewController()
        eventDisplayViewController.updateValues(task: task, delegate: self)
        navigationController?.pushViewController(
            eventDisplayViewController,
            animated: true
        )
    }
}

extension HomeViewController: EventDisplayViewControllerDelegate {
    func editTask(_ task: Task) {
        let taskViewController = EventEditViewController()
        taskViewController.updateValues(task: task, delegate: self)
        navigationController?.present(
            EventEditNavController(rootViewController: taskViewController),
            animated: true,
            completion: nil
        )
    }
    
    func deleteTask(_ task: Task) {
        guard let index = tasks.firstIndex(of: task) else {
            return
        }
        tasks.remove(at: index)
    }
    
    func toggleCompletion(of task: Task) {
        guard let index = tasks.firstIndex(of: task) else {
            return
        }
        tasks[index].isCompleted.toggle()
    }
}

extension HomeViewController {
    static let cellHeight: CGFloat = 60
    static let cellReuseIdentifier: String = "TimeSliceCell"
    static let indexPathOfFirstCell = IndexPath(row: 0, section: 0)
    
    static var taskCellLeading: CGFloat {
        CGFloat(
            TimeSliceCell.timeSliceLabelLeadingOffset
                + TimeSliceCell.timeSliceLabelWidth
                + TimeSliceCell.verticalSeparatorLeadingOffset
        )
    }
    static var taskCellWidth: CGFloat {
        CGFloat(UIScreen.main.bounds.width - HomeViewController.taskCellLeading)
    }
 
    static let newEventButtonDiameter = 65
}
