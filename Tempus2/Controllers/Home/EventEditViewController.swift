//
//  EventEditViewController.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class EventEditViewController: UITableViewController {
    
    private var bothPickersInRowTwoAreHidden: Bool {
        guard startDateAndTimePickerCell != nil else {
            return true
        }
        
        return startDateAndTimePickerCell.datePicker.isHidden
            && startDateAndTimePickerCell.timePicker.isHidden
    }
    private var bothPickersInRowFourAreHidden: Bool {
        get {
            guard endDateAndTimePickerCell != nil else {
                return true
            }
            
            return endDateAndTimePickerCell.datePicker.isHidden
                && endDateAndTimePickerCell.timePicker.isHidden
        }
        set {
            if !newValue {
                endDateAndTimeSelectionCell.removeSeparator()
            }
        }
    }
    
    private var titleCell: EventTextViewCell!
    private var startDateAndTimeSelectionCell: DateAndTimeSelectionCell!
    private var startDateAndTimePickerCell: DateAndTimePickerCell!
    private var endDateAndTimeSelectionCell: DateAndTimeSelectionCell!
    private var endDateAndTimePickerCell: DateAndTimePickerCell!
    private var descriptionCell: EventTextViewCell!
    
    private var oldTitle: String!
    private var oldStartDateAndTime: Date!
    private var oldEndDateAndTime: Date!
    private var oldDescription: String!
    private var isContentChanged: Bool {
        return oldTitle != titleCell.textView.content
            || oldStartDateAndTime.dateRepr != startDateAndTimePickerCell.dateAndTime.dateRepr
            || oldStartDateAndTime.timeRepr != startDateAndTimePickerCell.dateAndTime.timeRepr
            || oldEndDateAndTime.dateRepr != endDateAndTimePickerCell.dateAndTime.dateRepr
            || oldEndDateAndTime.timeRepr != endDateAndTimePickerCell.dateAndTime.timeRepr
            || oldDescription != descriptionCell.textView.content
    }
    
    // MARK: - Models
    
    private var task: Task?
    
    // MARK: - Controllers
    
    private var delegate: HomeViewController!
        
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(
            EventTextViewCell.classForCoder(),
            forCellReuseIdentifier: EventEditViewController.eventTextViewCellReusableIdentifier
        )
        tableView.register(
            DateAndTimeSelectionCell.classForCoder(),
            forCellReuseIdentifier: EventEditViewController.dateAndTimeSelectionCellReuseIdentifier
        )
        tableView.register(
            DateAndTimePickerCell.classForCoder(),
            forCellReuseIdentifier: EventEditViewController.dateAndTimePickerCellReuseIdentifier
        )
        
        // https://sarunw.com/posts/modality-changes-in-ios13/
        navigationController?.presentationController?.delegate = self
        
        updateViews()
        updateLayouts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // https://stackoverflow.com/questions/27652227/add-placeholder-text-inside-uitextview-in-swift
        // "(Note: Since the OP wanted to have the text view selected as soon as the view loads, I incorporated text view selection into the above code. If this is not your desired behavior and you do not want the text view selected upon view load, remove the last two lines from the above code chunk.)"
        let _ = titleCell.textView.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.hideBarSeparator()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.showBarSeparator()
    }
    
    func updateViews() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveBarButtonItemTapped)
        )
        
        tableView.tableFooterView = UIView()
    }
    
    func updateLayouts() {
    }
    
    func updateValues(task: Task? = nil, delegate: HomeViewController) {
        self.task = task
        self.delegate = delegate
    }
}

extension EventEditViewController {
    
    // MARK: - Utils
    
    // http://swiftdeveloperblog.com/uialertcontroller-confirmation-dialog-swift/
    private func displayInvalidDateIntervalWarning() {
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
    
    // https://stackoverflow.com/questions/36116490/how-to-create-alert-sliding-from-bottom-with-buttons-on-ios
    // https://stackoverflow.com/questions/28487743/show-a-space-below-actions-in-uialertcontroller
    //
    // https://stackoverflow.com/questions/38990882/closure-use-of-non-escaping-parameter-may-allow-it-to-escape
    private func displayEditDiscardingWarning(completion: @escaping (_ shouldDiscard: Bool) -> Void) {
        let unsaveAndQuitAlert = UIAlertController(
            title: nil,
            message: "Changes may be made.\nAre you sure you want to discard your changes?",
            preferredStyle: .actionSheet
        )
        
        let discardChangesButton = UIAlertAction(
            title: "Discard Changes",
            style: .default,
            handler: { (action) -> Void in
                completion(true)
        })
        
        let keepEditingButton = UIAlertAction(
            title: "Keep Editing",
            style: .cancel
        ) { (action) -> Void in
            completion(false)
        }
        
        unsaveAndQuitAlert.addAction(discardChangesButton)
        unsaveAndQuitAlert.addAction(keepEditingButton)
        
        self.present(unsaveAndQuitAlert, animated: true, completion: nil)
    }
    
    func displayDateIntervalConflictWarning(conflictedTask: Task) {
        let dateIntervalConflictAlert = UIAlertController(
            title: "Date interval conflict",
            message: "The current date interval is conflicted with task:  \(conflictedTask.title)"
                + " (\(conflictedTask.timeReprText))",
            preferredStyle: .alert
        )
        
        let okButton = UIAlertAction(
            title: "OK",
            style: .default,
            handler: { (action) -> Void in
                return
        })
        
        dateIntervalConflictAlert.addAction(okButton)
        
        self.present(dateIntervalConflictAlert, animated: true, completion: nil)
    }
}


extension EventEditViewController {
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        if !isContentChanged {
            self.delegate.dismiss(animated: true, completion: nil)
            return
        }
        
        // https://stackoverflow.com/questions/36241970/trouble-returning-a-string-from-alert
        displayEditDiscardingWarning { (shouldDiscard) in
            if shouldDiscard {
                self.delegate.dismiss(animated: true, completion: nil)
            } else {
                return
            }
        }
    }
    
    @objc private func saveBarButtonItemTapped() {
        let title = titleCell.textView.content
        let startDateAndTime = startDateAndTimePickerCell.dateAndTime
        let endDateAndTime = endDateAndTimePickerCell.dateAndTime
        let description = descriptionCell.textView.content
        
        if startDateAndTime > endDateAndTime {
            displayInvalidDateIntervalWarning()
            return
        }
        let dateInterval = DateInterval(
            start: startDateAndTime,
            end: endDateAndTime
        )
        
        let newTask = Task(
            title: title,
            dateInterval: dateInterval,
            description: description,
            isCompleted: task?.isCompleted ?? false
        )
        
        if let task = task {
            delegate.replace(task, with: newTask)
        } else {
            if let conflictedTask = delegate.findTaskConflicted(with: newTask) {
                displayDateIntervalConflictWarning(conflictedTask: conflictedTask)
                return
            } else {
                delegate.add(newTask)
            }
        }
        delegate.dismiss(animated: true, completion: nil)
    }
}

extension EventEditViewController: UIAdaptivePresentationControllerDelegate {

    // MARK: - UIAdaptivePresentationController Delegate
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        if !isContentChanged {
            return true
        }

        displayEditDiscardingWarning { (shouldDiscard) in
            if shouldDiscard {
                self.delegate.dismiss(animated: true, completion: nil)
            } else {
                return
            }
        }
        return false
    }
}

extension EventEditViewController {
    
    // MARK: - UITableView Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        switch row {
        case 0:
            oldTitle = task?.title ?? ""
            
            titleCell = EventTextViewCell()
            titleCell.updateValues(
                iconName: "title",
                placeHolder: EventEditViewController.titlePlaceHolder,
                text: oldTitle,
                delegate: self
            )
            titleCell.textView.font = Theme.title2Font
            return titleCell
        case 1:
            startDateAndTimeSelectionCell = DateAndTimeSelectionCell()
            startDateAndTimeSelectionCell.updateValues(
                iconName: "startTime",
                delegate: self,
                targetPickerRow: row + 1
            )
            let dateAndTime = task?.dateInterval.start ?? EventEditViewController.defaultStartDate
            startDateAndTimeSelectionCell.updateDateAndTimeRepr(with: dateAndTime)
            startDateAndTimeSelectionCell.removeSeparator()
            return startDateAndTimeSelectionCell
        case 2:
            oldStartDateAndTime = task?.dateInterval.start ?? EventEditViewController.defaultStartDate
            
            startDateAndTimePickerCell = DateAndTimePickerCell()
            startDateAndTimePickerCell.updateValues(
                targetSelectionRow: row - 1,
                delegate: self,
                dateAndTime: oldStartDateAndTime
            )
            startDateAndTimePickerCell.removeSeparator()
            return startDateAndTimePickerCell
        case 3:
            endDateAndTimeSelectionCell = DateAndTimeSelectionCell()
            endDateAndTimeSelectionCell.updateValues(
                iconName: "finishTime",
                delegate: self,
                targetPickerRow: row + 1
            )
            let dateAndTime = task?.dateInterval.end ?? EventEditViewController.defaultEndDate
            endDateAndTimeSelectionCell.updateDateAndTimeRepr(with: dateAndTime)
            return endDateAndTimeSelectionCell
        case 4:
            oldEndDateAndTime = task?.dateInterval.end ?? EventEditViewController.defaultEndDate
            
            endDateAndTimePickerCell = DateAndTimePickerCell()
            endDateAndTimePickerCell.updateValues(
                targetSelectionRow: row - 1,
                delegate: self,
                dateAndTime: oldEndDateAndTime
            )
            return endDateAndTimePickerCell
        case 5:
            oldDescription = task?.description ?? ""
            
            descriptionCell = EventTextViewCell()
            descriptionCell.updateValues(
                iconName: "description",
                placeHolder: EventEditViewController.descriptionPlaceHolder,
                text: oldDescription,
                delegate: self
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

extension EventEditViewController: DateAndTimePickerDelegate {
    
    // MARK: - DateAndTimePicker Delegate
    
    private func validateStartDateAndTime() {
        guard endDateAndTimePickerCell != nil else {
            return
        }
        
        if startDateAndTimePickerCell.dateAndTime > endDateAndTimePickerCell.dateAndTime {
            let startDateAndTime = startDateAndTimePickerCell.dateAndTime
            let newEndDateAndTime = Date(
                timeInterval: 40 * TimeInterval.secsOfOneMinute,
                since: startDateAndTime
            )
            endDateAndTimePickerCell.dateAndTime = newEndDateAndTime
            
            endDateAndTimeSelectionCell.updateDateAndTimeRepr(with: newEndDateAndTime)
            validateEndDateAndTime()
        } else {
            return
        }
    }
    
    private func validateEndDateAndTime() {
        if startDateAndTimePickerCell.dateAndTime <= endDateAndTimePickerCell.dateAndTime {
            endDateAndTimeSelectionCell.isDateValid = true
        } else {
            endDateAndTimeSelectionCell.isDateValid = false
        }
    }
    
    // MARK: - DateAndTimePicker Delegate
    
    internal func updateDateAndTime(ofCellInRow row: Int, with newDateAndTime: Date) {
        if row == 1 {
            startDateAndTimeSelectionCell.updateDateAndTimeRepr(with: newDateAndTime)
            validateStartDateAndTime()
        } else if row == 3 {
            endDateAndTimeSelectionCell.updateDateAndTimeRepr(with: newDateAndTime)
            validateEndDateAndTime()
        } else {
            return
        }
    }
}

extension EventEditViewController: UITextViewDelegate {
    
    // MARK: - UITextView Delegate
    
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
        }
    }
    
    // https://stackoverflow.com/questions/27652227/add-placeholder-text-inside-uitextview-in-swift
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let textView = textView as? TextViewWithPlaceHolder else {
            return true
        }
        
        let currentText: String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if updatedText.isEmpty {
            textView.content = ""
            return false
        } else if textView.isShowingPlaceHolder {
            textView.content = text
            return false
        } else {
            return true
        }
    }
    
    // Ensures that always the left of the placeholders are selected.
    func textViewDidChangeSelection(_ textView: UITextView) {
        guard let textView = textView as? TextViewWithPlaceHolder else {
            return
        }
        
        if textView.isShowingPlaceHolder {
            textView.selectMostLeft()
        }
    }
    
    // Ensures that always the left of the placeholders are selected.
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        guard let textView = textView as? TextViewWithPlaceHolder else {
            return true
        }
        
        if textView.isShowingPlaceHolder {
            textView.selectMostLeft()
        }
        return true
    }
}

extension EventEditViewController: DateAndTimeSelectionCellDelegate {
        
    private func currentPickerCellOf(_ row: Int) -> DateAndTimePickerCell {
        return row == 2
            ? startDateAndTimePickerCell
            : endDateAndTimePickerCell
    }
    
    private func theOtherPickerCellOf(_ row: Int) -> DateAndTimePickerCell {
        return row == 2
            ? endDateAndTimePickerCell
            : startDateAndTimePickerCell
    }
    
    private func togglePickersVisibility(in row: Int, shouldToggleDatePicker: Bool, shouldToggleTimePicker: Bool) {
        let currentPickerCell = currentPickerCellOf(row)
        let theOtherPickerCell = theOtherPickerCellOf(row)
        
        if shouldToggleDatePicker {
            currentPickerCell.datePicker.isHidden.toggle()
            currentPickerCell.timePicker.isHidden = true
        } else {
            currentPickerCell.timePicker.isHidden.toggle()
            currentPickerCell.datePicker.isHidden = true
        }
        
        theOtherPickerCell.datePicker.isHidden = true
        theOtherPickerCell.timePicker.isHidden = true
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: - DateAndTimeSelectionCell Delegate
    
    internal func toggleDatePickerVisibility(inRow row: Int) {
        togglePickersVisibility(in: row, shouldToggleDatePicker: true, shouldToggleTimePicker: false)
    }
    
    internal func toggleTimePickerVisibility(inRow row: Int) {
        togglePickersVisibility(in: row, shouldToggleDatePicker: false, shouldToggleTimePicker: true)
    }
}

protocol EventEditViewControllerDelegate {
        
    func add(_ task: Task)
    func replace(_ oldTask: Task, with newTask: Task)
    func findTaskConflicted(with newTask: Task) -> Task?
}

extension EventEditViewController {
    static let cellHeight: CGFloat = 60
    static let largeCellHeight: CGFloat = 250
    
    static var defaultStartDate: Date {
        Date()
    }
    static var defaultEndDate: Date {
        Date(
            timeInterval: 40 * TimeInterval.secsOfOneMinute,
            since: EventEditViewController.defaultStartDate
        )
    }
    
    static let eventTextViewCellReusableIdentifier = "EventTextViewCell"
    static let dateAndTimeSelectionCellReuseIdentifier = "DateAndTimeSelectionCell"
    static let dateAndTimePickerCellReuseIdentifier = "DateAndTimePickerCell"
    
    static let titlePlaceHolder = "Add title"
    static let descriptionPlaceHolder = "Add description"
}
