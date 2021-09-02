//
//  TaskViewController.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class EventEditViewController: UITableViewController {
    
    var bothPickersInRowTwoAreHidden: Bool = true
    var bothPickersInRowFourAreHidden: Bool = true {
        didSet {
            if !bothPickersInRowFourAreHidden {
                removeSeparator(below: endDateAndTimeSelectionCell)
            }
        }
    }
    
    var titleCell: EventCell!
    var startDateAndTimeSelectionCell: DateAndTimeSelectionCell!
    var startDateAndTimePickerCell: DateAndTimePickerCell!
    var endDateAndTimeSelectionCell: DateAndTimeSelectionCell!
    var endDateAndTimePickerCell: DateAndTimePickerCell!
    var descriptionCell: EventCell!
    
    // MARK: - Models
    
    var task: Task?
    
    // MARK: - Controllers
    
    var delegate: HomeViewController!
    
    // MARK: - Views
    
    var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: nil,
            action: nil
        )
        return button
    }()
    
    var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: nil,
            action: nil
        )
        return button
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(
            EventCell.classForCoder(),
            forCellReuseIdentifier: EventEditViewController.eventCellReusableIdentifier
        )
        tableView.register(
            DateAndTimeSelectionCell.classForCoder(),
            forCellReuseIdentifier: EventEditViewController.dateAndTimeSelectionCellReuseIdentifier
        )
        tableView.register(
            DateAndTimePickerCell.classForCoder(),
            forCellReuseIdentifier: EventEditViewController.dateAndTimePickerCellReuseIdentifier
        )
        
        updateViews()
        updateLayouts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // https://stackoverflow.com/questions/27652227/add-placeholder-text-inside-uitextview-in-swift
        // "(Note: Since the OP wanted to have the text view selected as soon as the view loads, I incorporated text view selection into the above code. If this is not your desired behavior and you do not want the text view selected upon view load, remove the last two lines from the above code chunk.)"
        
        titleCell.textView.becomeFirstResponder()
        if titleCell.content == titleCell.placeHolder {
            titleCell.textView.selectMostLeft()
        }
    }
    
    func updateViews() {
        navigationItem.leftBarButtonItem = cancelButton
        cancelButton.target = self
        cancelButton.action = #selector(cancelButtonTapped)
        
        navigationItem.rightBarButtonItem = saveButton
        saveButton.target = self
        saveButton.action = #selector(saveBarButtonItemTapped)
    }
    
    func updateLayouts() {
    }
    
    func updateValues(task: Task? = nil, delegate: HomeViewController) {
        self.task = task
        
        self.delegate = delegate
    }
}

extension EventEditViewController {
    // https://stackoverflow.com/questions/36116490/how-to-create-alert-sliding-from-bottom-with-buttons-on-ios
    // https://stackoverflow.com/questions/28487743/show-a-space-below-actions-in-uialertcontroller
    @objc func cancelButtonTapped() {
        let unsaveAndQuitAlert = UIAlertController(
            title: nil,
            message: "Changes may be made.\nAre you sure you want to discard your changes?",
            preferredStyle: .actionSheet
        )
        
        let discardChangesButton = UIAlertAction(
            title: "Discard Changes",
            style: .destructive,
            handler: { (action) -> Void in
                self.delegate.dismiss(animated: true, completion: nil)
        })
        
        let keepEditingButton = UIAlertAction(
            title: "Keep Editing",
            style: .cancel
        ) { (action) -> Void in
            return
        }
        keepEditingButton.setValue(UIColor.systemRed, forKey: "titleTextColor")
        
        unsaveAndQuitAlert.addAction(discardChangesButton)
        unsaveAndQuitAlert.addAction(keepEditingButton)
        
        self.present(unsaveAndQuitAlert, animated: true, completion: nil)
    }
    
    @objc func saveBarButtonItemTapped() {
        let title = titleCell.content
        let startDateAndTime = startDateAndTimePickerCell.dateAndTime
        let endDateAndTime = endDateAndTimePickerCell.dateAndTime
        let description = descriptionCell.content
        
        if startDateAndTime > endDateAndTime {
            displayInvalidDateIntervalWarning()
            return
        }
        
        let newTask = Task(
            title: title,
            dateInterval: DateInterval(
                start: startDateAndTime,
                end: endDateAndTime
            ),
            description: description,
            isCompleted: task?.isCompleted ?? false
        )
        
        if let task = task {
            delegate.dismiss(animated: true, completion: nil)
            delegate.replace(task, with: newTask)
        } else {
            delegate.add(newTask)
            delegate.dismiss(animated: true, completion: nil)
        }
    }
}

extension EventEditViewController {
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        switch row {
        case 0:
            titleCell = tableView.dequeueReusableCell(
                withIdentifier: EventEditViewController.eventCellReusableIdentifier,
                for: indexPath
                ) as? EventCell
            
            let placeHolder = (task == nil || (task != nil && task!.title.isEmpty)) ? NSMutableAttributedString(string: "Add title") : nil
            placeHolder?.setFont(font: Theme.title2Font)
            let text = task != nil ? NSMutableAttributedString(string: task!.title) : nil
            text?.setFont(font: Theme.title2Font)
            
            titleCell.updateValues(
                icon: "title",
                placeHolder: placeHolder,
                text: text,
                delegate: self,
                row: row
            )
            return titleCell
        case 1:
            startDateAndTimeSelectionCell = tableView.dequeueReusableCell(
                withIdentifier: EventEditViewController.dateAndTimeSelectionCellReuseIdentifier,
                for: indexPath
                ) as? DateAndTimeSelectionCell
            
            let date = task?.dateInterval.start ?? EventEditViewController.defaultStartDate
            
            startDateAndTimeSelectionCell.updateValues(
                icon: "startTime",
                delegate: self,
                tag: row
            )
            startDateAndTimeSelectionCell.updateDateAndTime(with: date)
            removeSeparator(below: startDateAndTimeSelectionCell)
            return startDateAndTimeSelectionCell
        case 2:
            startDateAndTimePickerCell = tableView.dequeueReusableCell(
                withIdentifier: EventEditViewController.dateAndTimePickerCellReuseIdentifier,
                for: indexPath
                ) as? DateAndTimePickerCell
            
            let date = task?.dateInterval.start ?? EventEditViewController.defaultStartDate
            let time = date
            
            startDateAndTimePickerCell.updateValues(
                targetRow: row - 1,
                delegate: self,
                date: date,
                time: time
            )
            removeSeparator(below: startDateAndTimePickerCell)
            return startDateAndTimePickerCell
        case 3:
            endDateAndTimeSelectionCell = tableView.dequeueReusableCell(
                withIdentifier: EventEditViewController.dateAndTimeSelectionCellReuseIdentifier,
                for: indexPath
                ) as? DateAndTimeSelectionCell
            
            let date = task?.dateInterval.end ?? EventEditViewController.defaultEndDate
            
            endDateAndTimeSelectionCell.updateValues(
                icon: "finishTime",
                delegate: self,
                tag: row
            )
            endDateAndTimeSelectionCell.updateDateAndTime(with: date)
            return endDateAndTimeSelectionCell
        case 4:
            endDateAndTimePickerCell = tableView.dequeueReusableCell(
                withIdentifier: EventEditViewController.dateAndTimePickerCellReuseIdentifier,
                for: indexPath
                ) as? DateAndTimePickerCell
            
            let date = task?.dateInterval.end ?? EventEditViewController.defaultEndDate
            let time = date
            
            endDateAndTimePickerCell.updateValues(
                targetRow: row - 1,
                delegate: self,
                date: date,
                time: time
            )
            return endDateAndTimePickerCell
        case 5:
            descriptionCell = tableView.dequeueReusableCell(
                withIdentifier: EventEditViewController.eventCellReusableIdentifier,
                for: indexPath
                ) as? EventCell
            
            let placeHolder = (task == nil || (task != nil && task!.description.isEmpty)) ? NSMutableAttributedString(string: "Add description") : nil
            placeHolder?.setFont(font: Theme.bodyFont)
            let text = task != nil ? NSMutableAttributedString(string: task!.description) : nil
            text?.setFont(font: Theme.bodyFont)
            
            descriptionCell.updateValues(
                icon: "description",
                placeHolder: placeHolder,
                text: text,
                delegate: self,
                row: row
            )
            return descriptionCell
        default:
            break
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        
        if row != 2 && row != 4 {
            return EventEditViewController.cellHeight
        } else if row == 2 {
            return bothPickersInRowTwoAreHidden ? 0 : EventEditViewController.largeCellHeight
        } else {
            return bothPickersInRowFourAreHidden ? 0 : EventEditViewController.largeCellHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        
        if row != 2 && row != 4 {
            return UITableView.automaticDimension
        } else if row == 2 {
            return bothPickersInRowTwoAreHidden ? 0 : EventEditViewController.largeCellHeight
        } else {
            return bothPickersInRowFourAreHidden ? 0 : EventEditViewController.largeCellHeight
        }
    }
}

extension EventEditViewController {
    // MARK: - Utils
    
    // https://stackoverflow.com/questions/8561774/hide-separator-line-on-one-uitableviewcell
    func removeSeparator(below cell: UITableViewCell) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
    }
    
    // https://stackoverflow.com/questions/42326892/uiview-appereance-from-bottom-to-top-and-vice-versacore-animation
//    func displayInvalidDateIntervalWarning() {
//        let invalidDateIntervalWarningView = InvalidDateIntervalWarningView(
//            frame: CGRect(x: view.frame.minX, y: view.frame.height, width: view.frame.width, height: 0)
//        )
//        view.addSubview(invalidDateIntervalWarningView)
//
//        let height: CGFloat = 150
//        UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseIn], animations: {
//            invalidDateIntervalWarningView.backgroundColor = .darkGray
//            invalidDateIntervalWarningView.frame = CGRect(
//                x: invalidDateIntervalWarningView.frame.minX,
//                y: invalidDateIntervalWarningView.frame.minY - height,
//                width: invalidDateIntervalWarningView.frame.width,
//                height: height
//            )
//        }, completion: { (_: Bool) -> Void in
//
//            UIView.animate(withDuration: 1.0, delay: 2, options: [.curveEaseOut], animations: {
//                invalidDateIntervalWarningView.backgroundColor = .darkGray
//                invalidDateIntervalWarningView.frame = CGRect(
//                    x: invalidDateIntervalWarningView.frame.minX,
//                    y: invalidDateIntervalWarningView.frame.minY + height,
//                    width: invalidDateIntervalWarningView.frame.width,
//                    height: 0
//                )
//            }, completion: { (_: Bool) -> Void in
//                invalidDateIntervalWarningView.removeFromSuperview()
//            })
//        })
//    }
    
    // http://swiftdeveloperblog.com/uialertcontroller-confirmation-dialog-swift/
    func displayInvalidDateIntervalWarning() {
        let invalidDateIntervalAlert = UIAlertController(
            title: "Invalid date interval",
            message: "The event end time cannot be set before the start time.",
            preferredStyle: .alert
        )
        
        let okButton = UIAlertAction(
            title: "OK",
            style: .default,
            handler: { (action) -> Void in
                return
        })
        
        invalidDateIntervalAlert.addAction(okButton)
        
        self.present(invalidDateIntervalAlert, animated: true, completion: nil)
    }
}

extension EventEditViewController: DateAndTimePickerDelegate {
    
    func validateStartDateAndTime() {
        guard endDateAndTimePickerCell != nil else {
            return
        }
        
        if startDateAndTimePickerCell.dateAndTime > endDateAndTimePickerCell.dateAndTime {
            let startDateAndTime = startDateAndTimePickerCell.dateAndTime
            let newEndDateAndTime = Date(timeInterval: 40 * TimeInterval.secsOfOneMin, since: startDateAndTime)
            endDateAndTimePickerCell.dateAndTime = newEndDateAndTime
            
            endDateAndTimeSelectionCell.updateDateAndTime(with: newEndDateAndTime)
            validateEndDateAndTime()
        } else {
            return
        }
    }
    
    func validateEndDateAndTime() {
        if startDateAndTimePickerCell.dateAndTime <= endDateAndTimePickerCell.dateAndTime {
            endDateAndTimeSelectionCell.textView.textColor = Theme.textColor
            endDateAndTimeSelectionCell.button.setTitleColor(Theme.textColor, for: .normal)
        } else {
            endDateAndTimeSelectionCell.textView.textColor = Theme.errorTextColor
            endDateAndTimeSelectionCell.button.setTitleColor(Theme.errorTextColor, for: .normal)
        }
    }
    
    // MARK: - DateAndTimePicker Delegate
    
    func updateDateAndTime(ofCellInRow row: Int, with newDateAndTime: Date) {
        if row == 1 {
            startDateAndTimeSelectionCell.updateDateAndTime(with: newDateAndTime)
            validateStartDateAndTime()
        } else if row == 3 {
            endDateAndTimeSelectionCell.updateDateAndTime(with: newDateAndTime)
            validateEndDateAndTime()
        } else {
            return
        }
    }
}

extension EventEditViewController: UITextViewDelegate {
    
    // https://stackoverflow.com/questions/37014919/expand-uitextview-and-uitableview-when-uitextviews-text-extends-beyond-1-line
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(
            width: size.width,
            height: CGFloat.greatestFiniteMagnitude
        ))
        
        // Resizes the cell only when cell's size is changed.
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView?.beginUpdates()
            tableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
            
            let indexPath = IndexPath(row: textView.tag, section: 0)
            tableView?.scrollToRow(
                at: indexPath,
                at: .bottom,
                animated: false
            )
        }
    }
    
    // https://stackoverflow.com/questions/27652227/add-placeholder-text-inside-uitextview-in-swift
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText: String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            var cell: EventCell
            if textView.tag == 0 {
                cell = titleCell
            } else if textView.tag == 5 {
                cell = descriptionCell
            } else {
                return true
            }
            
            textView.text = cell.placeHolder
            textView.textColor = Theme.placeHolderColor
            
            textView.selectMostLeft()
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, set
            // the text color to black then set its text to the
            // replacement string
        else if textView.textColor == Theme.weakTextColor && !text.isEmpty {
            textView.textColor = Theme.textColor
            textView.text = text
        }
            
            // For every other case, the text should change with the usual
            // behavior...
        else {
            return true
        }
        
        // ...otherwise return false since the updates have already
        // been made
        return false
    }
    
    // Ensures that always the left of the placeholders are selected.
    func textViewDidChangeSelection(_ textView: UITextView) {
        var cell: EventCell
        if textView.tag == 0 {
            cell = titleCell
        } else if textView.tag == 5 {
            cell = descriptionCell
        } else {
            return
        }
        
        if textView.text == cell.placeHolder {
            textView.selectMostLeft()
        }
    }
    // Ensures that always the left of the placeholders are selected.
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        var cell: EventCell
        if textView.tag == 0 {
            cell = titleCell
        } else if textView.tag == 5 {
            cell = descriptionCell
        } else {
            return true
        }
        
        if textView.text == cell.placeHolder {
            textView.selectMostLeft()
        }
        return true
    }
}

extension EventEditViewController: DateAndTimeSelectionCellDelegate {
    
    func checkHidden() {
        bothPickersInRowTwoAreHidden = startDateAndTimePickerCell.datePicker.isHidden
            && startDateAndTimePickerCell.timePicker.isHidden
        bothPickersInRowFourAreHidden = endDateAndTimePickerCell.datePicker.isHidden
            && endDateAndTimePickerCell.timePicker.isHidden
    }
    
    // MARK: - DateAndTimeSelectionCell Delegate
    
    func displayOrHideDatePicker(inRow row: Int) {
        let currentPickerCell: DateAndTimePickerCell = row == 2 ? startDateAndTimePickerCell : endDateAndTimePickerCell
        let theOtherPickerCell: DateAndTimePickerCell = row == 2 ? endDateAndTimePickerCell : startDateAndTimePickerCell
        
        currentPickerCell.datePicker.isHidden.toggle()
        currentPickerCell.timePicker.isHidden = true
        
        theOtherPickerCell.datePicker.isHidden = true
        theOtherPickerCell.timePicker.isHidden = true
        
        checkHidden()
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func displayOrHideTimePicker(inRow row: Int) {
        let currentPickerCell: DateAndTimePickerCell = row == 2 ? startDateAndTimePickerCell : endDateAndTimePickerCell
        let theOtherPickerCell: DateAndTimePickerCell = row == 2 ? endDateAndTimePickerCell : startDateAndTimePickerCell
        
        currentPickerCell.timePicker.isHidden.toggle()
        currentPickerCell.datePicker.isHidden = true
        
        theOtherPickerCell.datePicker.isHidden = true
        theOtherPickerCell.timePicker.isHidden = true
        
        checkHidden()
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

protocol TaskViewControllerDelegate {
    func add(_ task: Task)
    func replace(_ oldTask: Task, with newTask: Task)
}

extension EventEditViewController {
    static let cellHeight: CGFloat = 60
    static let largeCellHeight: CGFloat = 250
    
    static var defaultStartDate: Date {
        Date()
    }
    static var defaultEndDate: Date {
        Date(timeInterval: 40 * TimeInterval.secsOfOneMin, since: EventEditViewController.defaultStartDate)
    }
    
    static let eventCellReusableIdentifier = "EventCell"
    static let dateAndTimeSelectionCellReuseIdentifier = "DateAndTimeSelectionCell"
    static let dateAndTimePickerCellReuseIdentifier = "DateAndTimePickerCell"
}
