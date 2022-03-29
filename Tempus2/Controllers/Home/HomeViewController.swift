//
//  HomeViewController.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    private var width: CGFloat!
    private var height: CGFloat!
    private var currentDate: Date = Date() {
        didSet {
            navigationItem.title = currentDate.dateRepresentation()
            
            // Resets to nil.
            // Otherwise the date of it remains
            // the date before `currentDate` is updaated.
            endDateAndTimeOfLastAddedTask = nil
            
            // For loop view.
            reloadTables(scrollToTop: true)
            loopScrollView.contentOffset = CGPoint(x: width, y: 0)
        }
    }
    
    private var notificationCenter = UNUserNotificationCenter.current()
    
    // Convenient for continuous event creation.
    private var endDateAndTimeOfLastAddedTask: Date? = nil
    
    // MARK: - Models
    
    private var tasks: [Task]! {
        didSet {
            tasks.sort {
                $0.dateInterval.start < $1.dateInterval.start
                    || $0.dateInterval.end < $1.dateInterval.end
            }
            Task.save(tasks)
            prepareForNotifications()
            
            // For event adding, deleting and editing.
            if tableView1.frame != .zero {
                reloadTables(scrollToTop: false)
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
    
    internal var tableView1: UITableView = {
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
    
    private let currentTimeIndicator = CurrentTimeIndicator()

    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Loads tasks.
        tasks = Task.load()
        
        // The line of code below cannot be placed in `updateViews()`
        // as the func will be called every time the tables are reloaded,
        // making that the date displayed is changed to the date of today.
        navigationItem.title = Date().dateRepresentation()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
//            image: UIImage(systemName: HomeViewController.calendarIconName),
            image: UIImage(imageLiteralResourceName: "calendar"),  // TODO: - Antoher way to make the icon smaller?
            style: .plain,
            target: self,
            action: #selector(calendarButtonTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            title: "Today",
            image: UIImage(imageLiteralResourceName: "now"),
            style: .plain,
            target: self,
            action: #selector(todayButtonTapped)
        )
        
        loopScrollView.delegate = self
        
        tableView0.dataSource = self
        tableView0.delegate = self
        tableView0.register(
            HomeEventCell.classForCoder(),
            forCellReuseIdentifier: HomeViewController.homeEventCellReuseIdentifier
        )
        tableView0.register(
            PseudoCell.classForCoder(),
            forCellReuseIdentifier: HomeViewController.pseudoCellReuseIdentifier
        )
        tableView1.dataSource = self
        tableView1.delegate = self
        tableView1.register(
            HomeEventCell.classForCoder(),
            forCellReuseIdentifier: HomeViewController.homeEventCellReuseIdentifier
        )
        tableView1.register(
            PseudoCell.classForCoder(),
            forCellReuseIdentifier: HomeViewController.pseudoCellReuseIdentifier
        )
        tableView2.dataSource = self
        tableView2.delegate = self
        tableView2.register(
            HomeEventCell.classForCoder(),
            forCellReuseIdentifier: HomeViewController.homeEventCellReuseIdentifier
        )
        tableView2.register(
            PseudoCell.classForCoder(),
            forCellReuseIdentifier: HomeViewController.pseudoCellReuseIdentifier
        )
        
        newEventButton.addTarget(
            self,
            action: #selector(newEventButtonTapped),
            for: .touchUpInside
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.hideBarSeparator()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.showBarSeparator()
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
    
    // MARK: - UIScrollView Delegate
    
    internal func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // For the "Today" button.
        if scrollView == loopScrollView {
            self.currentDate = Date()
        }
    }
    
    internal func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Note that the scroll view delegate will affect both the loop view and
        // the table views. And they should be processed separately.
                
        if scrollView.tag != 0 {
            // A tableview is scrolled.
        } else {
            // The loop view is scrolled.
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
    
    @objc private func calendarButtonTapped() {
        navigationItem.hideBackBarButtonItem()
        
        let calendarViewController = CalendarViewController()
        calendarViewController.updateValues(date: currentDate, delegate: self)
        navigationController?.pushViewController(
            calendarViewController,
            animated: true
        )
    }
    
    @objc private func todayButtonTapped() {
        if Calendar.current.isDateInToday(currentDate) {
            return
        }
        
        if currentDate < Date() {
            loopScrollView.setContentOffset(CGPoint(x: 2 * self.width, y: 0), animated: true)
        } else {
            loopScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    @objc private func newEventButtonTapped() {
        var defaultStartDate: Date
        if let endDateAndTimeOfLastAddedTask = endDateAndTimeOfLastAddedTask {
            // Convenient for creating multiple events.
            defaultStartDate = endDateAndTimeOfLastAddedTask + 10 * TimeInterval.Minute
        } else {
            defaultStartDate = currentDate
        }
        // Event of today cannot start at before the current.
        if Calendar.current.isDateInToday(currentDate) && defaultStartDate < Date() {
            defaultStartDate = Date()
        }
        // min % 5 == 0.
        let minuteOffset = defaultStartDate.get(.minute) % 5
        if minuteOffset != 0 {  // If minuteOffset is 0, the defaultStartTime will be added 15 mins.
            defaultStartDate += TimeInterval(5 - minuteOffset) * TimeInterval.Minute
        }
        
        var defaultEndDate = defaultStartDate + 40 * TimeInterval.Minute
        if !Calendar.current.isDate(defaultStartDate, inSameDayAs: defaultEndDate) {
            defaultEndDate = Calendar.current.date(
                bySettingHour: 23,
                minute: 55,
                second: 59,
                of: defaultStartDate
                )!
        }
        
        let taskViewController = EventEditViewController()
        taskViewController.updateValues(delegate: self, defaultStartDate: defaultStartDate, defaultEndDate: defaultEndDate, isDateSelectable: false)
        navigationController?.present(
            EventEditNavController(rootViewController: taskViewController),
            animated: true,
            completion: nil
        )
    }
}

extension HomeViewController {
    
    // MARK: - Utils
    
    private func makeNotificationRequest(title: String, body: String, identifier: String, triggerDate: Date) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "eventNotification"

        let triggerDate = triggerDate
        // Sets up trigger time.
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        var triggerDateComponents = DateComponents()
        triggerDateComponents.year = triggerDate.get(.year)
        triggerDateComponents.month = triggerDate.get(.month)
        triggerDateComponents.day = triggerDate.get(.day)
        triggerDateComponents.hour = triggerDate.get(.hour)
        triggerDateComponents.minute = triggerDate.get(.minute)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)

        // Creates request.
//        let uniqueID = UUID().uuidString
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        return request
    }
    
    // https://stackoverflow.com/questions/52009454/how-do-i-send-local-notifications-at-a-specific-time-in-swift
    private func prepareForNotifications() {
        // Removes old notifications.
        // https://stackoverflow.com/questions/40562912/how-to-cancel-usernotifications
        UNUserNotificationCenter
            .current()
            .removeAllPendingNotificationRequests()
                
        for task in tasksOfToday {
            if task.isCompleted {
                continue
            }
            
            notificationCenter.add(makeNotificationRequest(
                title: task.titleRepresentation,
                body: "Will start at " + task.dateInterval.start.timeRepresentation(),
                identifier: task.identifier + "-will-start",
                triggerDate: task.dateInterval.start - 10 * TimeInterval.Minute
            ))
            notificationCenter.add(makeNotificationRequest(
                title: task.titleRepresentation,
                body: (task.dateInterval.duration >= 1 * TimeInterval.Minute
                    ? "Started: "
                    : ""
                ) + task.timeAndDurationRepresentation,
                identifier: task.identifier + "-start",
                triggerDate: task.dateInterval.start
            ))
            if task.dateInterval.duration >= 1 * TimeInterval.Minute {
                notificationCenter.add(makeNotificationRequest(
                    title: task.titleRepresentation,
                    body: "Finished",
                    identifier: task.identifier + "-finish",
                    triggerDate: task.dateInterval.end
                ))
            }
        }
        
        // https://stackoverflow.com/questions/40270598/ios-10-how-to-view-a-list-of-pending-notifications-using-unusernotificationcente
        notificationCenter.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print(
                    "request title: \(request.content.title)"
                        + ", "
                        + "request body: \(request.content.body)"
                )
            }
        })
    }
    
    private func reloadTables(scrollToTop: Bool = false) {
        for tableView in [tableView0, tableView1, tableView2] {
            tableView.reloadData()
            // Scrolls to top.
            // The following code is crucial to make the transition smooth.
            if scrollToTop && tableView.numberOfRows(inSection: 0) > 0 {
                tableView.scrollToRow(
                    at: IndexPath(row: 0, section: 0),
                    at: .top,
                    animated: false
                )
            }
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    
    // MARK: - UITableView Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        
        if tableView.tag == 1 {
            numberOfRows = tasksOfLastDate.count
        } else if tableView.tag == 2 {
            numberOfRows = tasksOfCurrentDate.count
        } else if tableView.tag == 3 {
            numberOfRows = tasksOfNextDate.count
        }
        
        if numberOfRows == 0 {
            numberOfRows = 1  // For pseudo cell.
        }
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tasksToLoad: [Task] = []
        if tableView.tag == 1 {
            tasksToLoad = tasksOfLastDate
        } else if tableView.tag == 2 {
            tasksToLoad = tasksOfCurrentDate
        } else if tableView.tag == 3 {
            tasksToLoad = tasksOfNextDate
        }
        
        if !tasksToLoad.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeViewController.homeEventCellReuseIdentifier)
                as! HomeEventCell
            cell.updateValues(task: tasksToLoad[indexPath.row], delegate: self)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeViewController.pseudoCellReuseIdentifier)
                as! PseudoCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HomeViewController.homeEventCellHeight
    }
}

extension HomeViewController: UITableViewDelegate {
    
    // MARK: - UITableView Delegate
    
    internal func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        " "
    }
    
    internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        HomeViewController.headerHeight
    }
    
    internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        return headerView
    }
}

extension HomeViewController: EventEditViewControllerDelegate {
    
    // MARK: - EventEditViewController Delegate
    
    internal func add(_ task: Task) {
        tasks.append(task)
        
        endDateAndTimeOfLastAddedTask = task.dateInterval.end
        
        // Scrolls to the newly added cell.
        let indexOfAddedCell = tasksOfCurrentDate.firstIndex { (currentTask) -> Bool in
            return currentTask.dateInterval == task.dateInterval
        }!
        tableView1.scrollToRow(
            at: IndexPath(row: indexOfAddedCell, section: 0),
            at: .bottom,
            animated: true
        )
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
            if task.identifier == newTask.identifier {
                continue
            }
            
            if let intersectionInterval = task.dateInterval.intersection(with: newTask.dateInterval) {
                let componentsToCompare: [Calendar.Component] = [.year, .month, .day, .hour, .minute]
                if intersectionInterval.start.get(componentsToCompare) == intersectionInterval.end.get(componentsToCompare) {
                    // 8:00-8:30, 8:30-9:30. Has intersection but is allowed.
                    continue
                }
                
                return task
            }
        }
        return nil
    }
    
//    internal func delay(tasksInTheSameDayAfter targetTask: Task, for secsToDelay: TimeInterval) {
//        for (i, task) in tasks.enumerated() {
//            if Calendar.current.isDate(task.dateInterval.start, inSameDayAs: targetTask.dateInterval.start) {
//                if task.dateInterval.start >= targetTask.dateInterval.start {
//                    tasks[i].dateInterval.start += secsToDelay
//                }
//            }
//        }
//    }
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
        eventEditViewController.updateValues(task: task, delegate: self, isDateSelectable: true)
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
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [task.identifier])
    }
}

extension HomeViewController: CalendarViewControllerDelegate {
    
    // CalendarViewController Delegate
    
    internal func updateCurrentDate(to date: Date) {
        currentDate = date
    }
    
    internal func containsTasksOf(date: Date) -> Bool {
        return !tasks.tasksOf(date).isEmpty
    }
}

extension HomeViewController {
    static var homeEventCellReuseIdentifier = "HomeEventCell"
    static var homeEventCellHeight: CGFloat = 90
    static var headerHeight: CGFloat = 30
    
    static let pseudoCellReuseIdentifier = "PseudoCell"
    
    static let newEventButtonDiameter = 65
    
    static let leftRatioThreshold: CGFloat = 0.7
    static let rightRatioThreshold: CGFloat = 1.3
    
    static let calendarIconName = "calendar.circle"
}

protocol HomeViewControllerYOffsetDelegate {
    var horizontalSeparatorYOffset: CGFloat { get }
}

protocol HomeViewControllerEditDelegate {
    func updateTaskWith(_ task: Task)
}
