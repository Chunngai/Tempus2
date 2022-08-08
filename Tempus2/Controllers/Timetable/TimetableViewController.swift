//
//  CollectionViewController.swift
//  Tempus2
//
//  Created by Sola on 2022/7/10.
//  Copyright © 2022 Sola. All rights reserved.
//

import UIKit

class TimetableViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, HomeTimetableDelegate {
    
    private var earliestStart: Int {
        var earliestStart: Int = 25
        for task in timetableTasks {
            let currentStart = Calendar.current.component(.hour, from: task.dateInterval.start)
            earliestStart = min(earliestStart, currentStart)
        }
        
        earliestStart = min(earliestStart, 8)
        
        return earliestStart
    }
    
    private var latestEnd: Int {
        var latestEnd: Int = 0
        for task in timetableTasks {
            let currentEnd = Calendar.current.component(.hour, from: task.dateInterval.end)
            latestEnd = max(latestEnd, currentEnd)
        }
        
        latestEnd = max(latestEnd, 22)
        
        return latestEnd
    }
    
    // MARK: - Models
    
    private var tasks: [Task]! {
        get {
            return delegate.tasks
        }
        set {
            delegate.tasks = newValue
            
            // Reloads earliest and latest time.
            timetableCollectionView.reloadData()
            draw()
        }
    }
    
    private var timetableTasks: [Task] {
        return tasks.timetableTasks
    }
    
    // MARK: - Delegates
    
    private var delegate: HomeViewController!
    
    // MARK: - Views
    
    private lazy var weekdaysCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: constructLayout())
        collectionView.tag = TimetableViewController.weekdayCollectionViewTag
        return collectionView
    }()
    
    private lazy var timetableCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: constructLayout())
        collectionView.tag = TimetableViewController.timetableCollectionViewTag
        return collectionView
    }()
    
    // TODO: - update
    private let newEventButtonShadowView: UIView = {
        let shadowView = UIView()
        shadowView.layer.shadowColor = UIColor.gray.cgColor
        shadowView.layer.shadowOpacity = 0.3
        shadowView.layer.shadowRadius = 2
        shadowView.layer.shadowOffset = CGSize(width: 3, height: 3)
        return shadowView
    }()
    // TODO: - update
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
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.hideBarSeparator()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.showBarSeparator()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(weekdaysCollectionView)
        weekdaysCollectionView.dataSource = self
        weekdaysCollectionView.delegate = self
        weekdaysCollectionView.register(
            TimetableCell.classForCoder(),
            forCellWithReuseIdentifier: TimetableViewController.reuseIdentifier
        )
        
        view.addSubview(timetableCollectionView)
        timetableCollectionView.dataSource = self
        timetableCollectionView.delegate = self
        timetableCollectionView.register(
            TimetableCell.classForCoder(),
            forCellWithReuseIdentifier: TimetableViewController.reuseIdentifier
        )
        
        // TODO: - update
        view.addSubview(newEventButtonShadowView)
        newEventButtonShadowView.addSubview(newEventButton)
        newEventButton.addTarget(
            self,
            action: #selector(newEventButtonTapped),
            for: .touchUpInside
        )
        
        updateViews()
        updateLayouts()
        
        draw()
    }
    
    private func updateViews() {
        view.backgroundColor = .white
        
        navigationItem.title = "Timetable"
        
        weekdaysCollectionView.backgroundColor = .white
        timetableCollectionView.backgroundColor = .white
    }
    
    private func updateLayouts() {
        weekdaysCollectionView.snp.makeConstraints { (make) in
            make.leading.equalTo(0)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.width.equalToSuperview()
            make.height.equalTo(TimetableViewController.weekdayCellHeight)
        }
        
        timetableCollectionView.snp.makeConstraints { (make) in            
            make.leading.equalTo(0)
            make.top.equalTo(weekdaysCollectionView.snp.bottom)
            make.width.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        // TODO: - update
        newEventButtonShadowView.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        // TODO: - update
        newEventButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalTo(HomeViewController.newEventButtonDiameter)
            make.height.equalTo(HomeViewController.newEventButtonDiameter)
        }
    }
    
    internal func updateValues(delegate: HomeViewController) {
        self.delegate = delegate
    }
}

extension TimetableViewController {
    
    // MARK: - Utils
    
    // Should be different for each collection view,
    // thus closure creation is not proper.
    private func constructLayout() -> UICollectionViewFlowLayout {
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = TimetableViewController.sectionInset
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = TimetableViewController.minimumLineSpacing
            layout.minimumInteritemSpacing = TimetableViewController.minimumInteritemSpacing
            return layout
    }
    
    private func draw() {
        for subView in timetableCollectionView.subviews {
            if type(of: subView) == TimetableTaskCell.self {
                subView.removeFromSuperview()
            }
        }
        
        for task in timetableTasks {
            let weekday = Calendar.current.component(.weekday, from: task.dateInterval.start)
            
            let startHour = Calendar.current.component(.hour, from: task.dateInterval.start)
            let startMinute = Calendar.current.component(.minute, from: task.dateInterval.start)
            
            let endHour = Calendar.current.component(.hour, from: task.dateInterval.end)
            let endMinute = Calendar.current.component(.minute, from: task.dateInterval.end)
                        
            let x = TimetableViewController.cellWidth * CGFloat(weekday)
            let width = TimetableViewController.cellWidth
            let y = CGFloat(startHour - earliestStart) * TimetableViewController.normalCellHeight
                + CGFloat(startMinute) * (TimetableViewController.normalCellHeight / CGFloat(TimeInterval.Minute))
            let height = CGFloat((endHour * Int(TimeInterval.Minute) + endMinute) - (startHour * Int(TimeInterval.Minute) + startMinute))
                * (TimetableViewController.normalCellHeight / CGFloat(TimeInterval.Minute))
            
            let taskCell = TimetableTaskCell(frame: CGRect(
                x: x,
                y: y,
                width: width,
                height: height
            ))
            taskCell.updateValues(task: task, delegate: self)
            timetableCollectionView.addSubview(taskCell)
        }
    }
}

extension TimetableViewController {
    
    // MARK: - Actions
    
    @objc private func newEventButtonTapped() {
        let taskViewController = EventEditViewController()
        taskViewController.updateValues(
            delegate: self,
            defaultStartDate: Date(),  // TODO: - update
            defaultEndDate: Date(timeIntervalSinceNow: 1 * TimeInterval.Hour),  // TODO: - update
            isDateSelectable: true,
            isTimetableMode: true
        )
        navigationController?.present(
            EventEditNavController(rootViewController: taskViewController),
            animated: true,
            completion: nil
        )
    }
}

extension TimetableViewController {
    
    // MARK: - HomeTimetable delegate
    
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
        // TODO: - check.
        //        return tasks.taskConflicted(with: newTask)
        return nil
    }
    
    internal func display(_ task: Task) {
        navigationItem.hideBackBarButtonItem()
        
        let eventDisplayViewController = EventDisplayViewController()
        eventDisplayViewController.updateValues(task: task, delegate: self, isTimetableMode: true)
        navigationController?.pushViewController(
            eventDisplayViewController,
            animated: true
        )
    }
    
    internal func edit(_ task: Task) {
        let eventEditViewController = EventEditViewController()
        eventEditViewController.updateValues(
            task: task,
            delegate: self,
            isDateSelectable: true,
            isTimetableMode: true
        )
        navigationController?.present(
            EventEditNavController(rootViewController: eventEditViewController),
            animated: true,
            completion: nil
        )
    }
    
    internal func remove(_ task: Task) {
        tasks.remove(task)
    }
}

extension TimetableViewController {
    
    // MARK: UICollectionView data source

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView.tag == TimetableViewController.weekdayCollectionViewTag {
            return 1
        } else {
            return (latestEnd - earliestStart) + 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TimetableViewController.reuseIdentifier,
            for: indexPath
        ) as! TimetableCell
        
        if collectionView.tag == TimetableViewController.weekdayCollectionViewTag && indexPath.row >= 1 {
            cell.updateValues(text: Calendar.current.veryShortWeekdaySymbols[indexPath.row - 1])
        } else if collectionView.tag == TimetableViewController.timetableCollectionViewTag {
            if indexPath.row == 0 {
                cell.updateValues(text: "\(indexPath.section + earliestStart):00")
            } else {
                cell.updateValues(drawHSepLine: true)
            }
        }

        return cell
    }
}

extension TimetableViewController {
    
    // MARK: - UICollectionView delegate flow layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == TimetableViewController.weekdayCollectionViewTag {
            return TimetableViewController.weekDayItemSize
        } else {
            return TimetableViewController.timeItemSize
        }
    }
}

extension TimetableViewController {
    static let reuseIdentifier = "timetableCell"
    static let weekdayCollectionViewTag: Int = 0
    static let timetableCollectionViewTag: Int = 1
    static let cellWidth: CGFloat = UIScreen.main.bounds.width / 8
    static let weekdayCellHeight: CGFloat = 20
    static let normalCellHeight: CGFloat = 60
    static let weekDayItemSize = CGSize(
        width: TimetableViewController.cellWidth,
        height: TimetableViewController.weekdayCellHeight
    )
    static let timeItemSize = CGSize(
        width: TimetableViewController.cellWidth,
        height: TimetableViewController.normalCellHeight
    )
    static let sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    static let minimumLineSpacing: CGFloat = 0
    static let minimumInteritemSpacing: CGFloat = 0
}
