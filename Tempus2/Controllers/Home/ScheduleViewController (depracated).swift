////
////  ScheduleViewController.swift
////  Tempus2
////
////  Created by Sola on 2021/8/30.
////  Copyright © 2021 Sola. All rights reserved.
////
//
//import UIKit
//
//class ScheduleViewController: UITableViewController {
//    
//    // TimelinePoint, Timeline back color, title, description, lineInfo, thumbnails, illustration
//    let data: [Int: [(TimelinePoint, UIColor, String, String, String?, [String]?, String?)]] = [
//        0: [
//            (
//                TimelinePoint(),
//                UIColor.black,
//                "12:30", "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
//                nil,
//                nil,
//                "Sun"
//            ),
//            (
//                TimelinePoint(),
//                UIColor.blue,
//                "15:30",
//                "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
//                nil,
//                nil,
//                "Sun"
//            ),
//            (TimelinePoint(), UIColor.black, "16:30", "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", "2.5 h", ["Apple"], "Sun"),
//            (TimelinePoint(), UIColor.black, "19:00", "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", nil, nil, "Moon"),
//            (TimelinePoint(), UIColor.lightGray, "08:30", "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", "60 m", nil, "Sun"),
//            (TimelinePoint(), UIColor.lightGray, "09:30", "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", "30 m", nil, "Sun"),
//            (TimelinePoint(), UIColor.lightGray, "10:00", "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", "1.5 h", nil, "Sun"),
//            (TimelinePoint(), UIColor.lightGray, "11:30", "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", "1 h", nil, "Sun"),
//            (TimelinePoint(color: UIColor.red, filled: false), UIColor.red, "12:30", "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", "30 m", ["Apple", "Apple", "Apple", "Apple"], "Sun"),
//            (TimelinePoint(color: UIColor.red, filled: false), UIColor.red, "13:00", "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", "2 h", ["Apple", "Apple", "Apple", "Apple", "Apple"], "Sun"),
//            (TimelinePoint(color: UIColor.red, filled: false), UIColor.lightGray, "15:00", "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", "2.5 h", ["Apple", "Apple"], "Sun"),
//            (TimelinePoint(), UIColor.lightGray, "17:30", "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", "1 h", nil, "Sun")
//        ]]
//
//    // MARK: - Init
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        navigationItem.title = "Schedule"
//        navigationItem.largeTitleDisplayMode = .always
//
//        tableView.separatorStyle = .none
//        self.tableView.register(
//            TimelineTableViewCell.classForCoder(),
//            forCellReuseIdentifier: "TimelineTableViewCell"
//        )
//    }
//}
//
//extension ScheduleViewController {
//    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return data.count
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let sectionData = data[section] else {
//            return 0
//        }
//        return sectionData.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableViewCell", for: indexPath)
//            as! TimelineTableViewCell
//
//        // Configure the cell...
//        guard let sectionData = data[indexPath.section] else {
//            return cell
//        }
//
//        let (timelinePoint, timelineBackColor, title, description, lineInfo, _, _) = sectionData[indexPath.row]
//
//        var timelineFrontColor = UIColor.clear
//        if (indexPath.row > 0) {
//            timelineFrontColor = sectionData[indexPath.row - 1].1
//        }
//
//        cell.timePoint = timelinePoint
//        cell.timeline.frontColor = timelineFrontColor
//        cell.timeline.backColor = timelineBackColor
//
//        cell.timeLabel.text = "\(title) - \(title)"
//        cell.contentLabel.text = description
//        cell.durationLabel.text = lineInfo
//
//        return cell
//    }
//}
//
//extension ScheduleViewController {
//
//    //    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//    //        return "Day " + String(describing: section + 1)
//    //    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let sectionData = data[indexPath.section] else {
//            return
//        }
//
//        print(sectionData[indexPath.row])
//    }
//}
