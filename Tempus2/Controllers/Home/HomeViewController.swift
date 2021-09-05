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
        (tableView1.visibleCells.first as? TimeSliceCell)?
            .horizontalSeparatorYOffset
    }
    
    private var width: CGFloat!
    private var height: CGFloat!
    private var currentDate: Date = Date() {
        didSet {
            // For loop view.
            drawTasks()
            loopScrollView.contentOffset = CGPoint(x: width, y: 0)
        }
    }
    
    // MARK: - Models
    
    private var tasks: [Task]! {
        didSet {
            tasks.sort {
                $0.dateInterval.start < $1.dateInterval.start
            }
            Task.save(tasks)
            prepareForNotifications()
            
            if tableView1.frame != .zero {
                // For event adding, deleting and editing.
                drawTasks()
            }
        }
    }
    
    private var tasksOfToday: [Task] {
        return tasks.tasksOf(Date())
    }
    
    private var tasksOfLastDate: [Task] {
        return tasks.tasksOf(currentDate.yesterday)
    }
    
    private var tasksOfCurrentDate: [Task] {
        return tasks.tasksOf(currentDate)
    }
    
    private var tasksOfNextDate: [Task] {
        return tasks.tasksOf(currentDate.tomorrow)
    }
    
    // MARK: - Views
    
    private var tableView0: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.tag = 1
        return tableView
    }()
    
    private var tableView1: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.tag = 2
        return tableView
    }()
    
    private var tableView2: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.tag = 3
        return tableView
    }()
    
    private var loopScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        // https://stackoverflow.com/questions/11001938/uiscrollview-scrolling-in-only-one-direction-at-a-time/11002001
        scrollView.isDirectionalLockEnabled = true
        return scrollView
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Today",
            style: .plain,
            target: self,
            action: #selector(todayButtonTapped)
        )
        
        loopScrollView.delegate = self
        
        tableView0.dataSource = self
        tableView0.delegate = self
        tableView0.register(
            TimeSliceCell.classForCoder(),
            forCellReuseIdentifier: HomeViewController.timeSliceCellReuseIdentifier
        )
        tableView1.dataSource = self
        tableView1.delegate = self
        tableView1.register(
            TimeSliceCell.classForCoder(),
            forCellReuseIdentifier: HomeViewController.timeSliceCellReuseIdentifier
        )
        tableView2.dataSource = self
        tableView2.delegate = self
        tableView2.register(
            TimeSliceCell.classForCoder(),
            forCellReuseIdentifier: HomeViewController.timeSliceCellReuseIdentifier
        )
        
        newEventButton.addTarget(
            self,
            action: #selector(newEventButtonTapped),
            for: .touchUpInside
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        drawTasks()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        width = view.frame.size.width
        height = view.safeAreaLayoutGuide.layoutFrame.height
        
        self.updateViews()
        self.updateLayouts()
        
        loopScrollView.contentSize = CGSize(width: width * 3.0, height: height)
        loopScrollView.contentOffset = CGPoint(x: width, y: 0)
    }
    
    func updateViews() {
        view.addSubview(loopScrollView)
        loopScrollView.addSubview(tableView0)
        loopScrollView.addSubview(tableView1)
        loopScrollView.addSubview(tableView2)
        
        view.addSubview(newEventButtonShadowView)
        newEventButtonShadowView.addSubview(newEventButton)
    }
    
    func updateLayouts() {
        tableView0.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        tableView1.snp.makeConstraints { (make) in
            make.leading.equalTo(width)
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        tableView2.snp.makeConstraints { (make) in
            make.leading.equalTo(width * 2)
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        loopScrollView.snp.makeConstraints { (make) in
            make.leading.equalTo(0)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.width.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
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

extension HomeViewController: UIScrollViewDelegate {
        
    private func changeLoopViewVisibleContent(horizontalContentOffset: CGFloat) {
        let ratio = horizontalContentOffset / width
        if ratio <= HomeViewController.leftRatioThreshold {
            currentDate = currentDate.yesterday
        }
        if ratio >= HomeViewController.rightRatioThreshold {
            currentDate = currentDate.tomorrow
        }
    }
    
    private func alignTableViewVerticalContentOffset() {
        tableView0.contentOffset = tableView1.contentOffset
        tableView2.contentOffset = tableView1.contentOffset
    }
    
    // MARK: - UIScrollView Delegate
    
    internal func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // When the Today button is tapped.
        currentDate = Date()
    }
    
    internal func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Note that the scroll view delegate will affect both the loop view and
        // the table views. And they should be processed separately.
                
        if scrollView.tag != 0 {
            alignTableViewVerticalContentOffset()
        } else {
            changeLoopViewVisibleContent(horizontalContentOffset: scrollView.contentOffset.x)
        }
    }
    
    internal func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
                
        if !decelerate {
            scrollViewDidEndDecelerating(scrollView)
        }
    }
}

extension HomeViewController {
    
    // MARK: - Actions
    
    @objc private func todayButtonTapped() {
        if Calendar.current.isDateInToday(currentDate) {
            return
        }
        
        if currentDate < Date() {
            // The following two lines of code
            // make the transition more natural.
            clearEventCells(in: tableView2)
            draw(tasksOfToday, in: tableView2)
            
            // https://stackoverflow.com/questions/2234875/programmatically-scroll-a-uiscrollview
            loopScrollView.setContentOffset(
                CGPoint(x: 2 * width, y: 0),
                animated: true
            )
        } else {
            clearEventCells(in: tableView0)
            draw(tasksOfToday, in: tableView0)
            
            loopScrollView.setContentOffset(
                CGPoint(x: 0, y: 0),
                animated: true
            )
        }
    }
    
    @objc private func newEventButtonTapped() {
        let defaultStartDate = currentDate
        let defaultEndDate = Date(
            timeInterval: 40 * TimeInterval.secsOfOneMinute,
            since: defaultStartDate
        )
        
        let taskViewController = EventEditViewController()
        taskViewController.updateValues(delegate: self, defaultStartDate: defaultStartDate, defaultEndDate: defaultEndDate)
        navigationController?.present(
            EventEditNavController(rootViewController: taskViewController),
            animated: true,
            completion: nil
        )
    }
}

extension HomeViewController {
    
    // MARK: - Utils
    
    // https://stackoverflow.com/questions/52009454/how-do-i-send-local-notifications-at-a-specific-time-in-swift
    private func prepareForNotifications() {
        // Removes old notifications.
        // https://stackoverflow.com/questions/40562912/how-to-cancel-usernotifications
        UNUserNotificationCenter
            .current()
            .removeAllPendingNotificationRequests()
        
        let center = UNUserNotificationCenter.current()

        for task in tasksOfToday {
            let content = UNMutableNotificationContent()
            content.title = task.titleReprText
            content.body = task.timeAndDurationReprText
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "eventNotification"

            let triggerDate = Date(
                timeInterval: -10 * TimeInterval.secsOfOneMinute,
                since: task.dateInterval.start
            )
            // Sets up trigger time.
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current
            var triggerDateComponents = DateComponents()
            triggerDateComponents.year = triggerDate.getComponent(.year)
            triggerDateComponents.month = triggerDate.getComponent(.month)
            triggerDateComponents.day = triggerDate.getComponent(.day)
            triggerDateComponents.hour = triggerDate.getComponent(.hour)
            triggerDateComponents.minute = triggerDate.getComponent(.minute)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)

            // Creates request.
            let uniqueID = UUID().uuidString
            let request = UNNotificationRequest(
                identifier: uniqueID,
                content: content,
                trigger: trigger
            )
            
            center.add(request)
        }
        
        // https://stackoverflow.com/questions/40270598/ios-10-how-to-view-a-list-of-pending-notifications-using-unusernotificationcente
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print(
                    "request title: \(request.content.title)"
                        + ", "
                        + "request body: \(request.content.body)"
                )
            }
        })
        
    }
    
    private func clearEventCells(in tableView: UITableView) {
        // Clears current event cells.
        for subView in tableView.subviews {
            if let homeEventCell = subView as? HomeEventCell {
                homeEventCell.removeFromSuperview()
            }
        }
    }
    
    private func drawTasks() {
        navigationItem.title = currentDate.dateRepr()
        
        draw(tasksOfLastDate, in: tableView0)
        draw(tasksOfCurrentDate, in: tableView1)
        draw(tasksOfNextDate, in: tableView2)
    }
    
    private func draw(_ tasksToDraw: [Task], in tableViewOfTasksToDraw: UITableView) {
        clearEventCells(in: tableViewOfTasksToDraw)
        for task in tasksToDraw {
            draw(task, in: tableViewOfTasksToDraw)
        }
    }
    
    private func draw(_ task: Task, in tableViewOfTasksToDraw: UITableView) {
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
        var inOneLine: Bool = false
        if height <= HomeViewController.timeSliceCellHeight / 2 {
            height = HomeViewController.timeSliceCellHeight / 2
            inOneLine = true
        }
                
        let eventCell = HomeEventCell()
        tableViewOfTasksToDraw.addSubview(eventCell)
        eventCell.updateValues(task: task, delegate: self, inOneLine: inOneLine)
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
        
//        if tableView.tag == 1 {
//            cell.backgroundColor = .red
//        } else if tableView.tag == 2 {
//            cell.backgroundColor = .yellow
//        } else {
//            cell.backgroundColor = .green
//        }
        
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
    
    internal func taskConflicted(with newTask: Task) -> Task? {
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
    
    static let leftRatioThreshold: CGFloat = 0.7
    static let rightRatioThreshold: CGFloat = 1.3
}

protocol HomeViewControllerYOffsetDelegate {
    var horizontalSeparatorYOffset: CGFloat { get }
}

protocol HomeViewControllerEditDelegate {
    func updateTaskWith(_ task: Task)
}
