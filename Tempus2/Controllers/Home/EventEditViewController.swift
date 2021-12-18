//
//  EventEditViewController.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class EventEditViewController: UITableViewController {
    
    private var isDatePickerInRowTwoHidden: Bool {
        guard startDateAndTimePickerCell != nil else {
            return true
        }
        return startDateAndTimePickerCell.datePicker.isHidden
    }
    private var isTimePickerInRowTwoHidden: Bool {
        guard startDateAndTimePickerCell != nil else {
            return true
        }
        return startDateAndTimePickerCell.timePicker.isHidden
    }
    private var bothPickersInRowTwoAreHidden: Bool {
        return isDatePickerInRowTwoHidden
            && isTimePickerInRowTwoHidden
    }
    
    private var isDatePickerInRowFourHidden: Bool {
        guard endDateAndTimePickerCell != nil else {
            return true
        }
        return endDateAndTimePickerCell.datePicker.isHidden
    }
    private var isTimePickerInRowFourHidden: Bool {
        guard endDateAndTimePickerCell != nil else {
            return true
        }
        return endDateAndTimePickerCell.timePicker.isHidden
    }
    private var bothPickersInRowFourAreHidden: Bool {
        return isDatePickerInRowFourHidden
            && isTimePickerInRowFourHidden
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
            || oldStartDateAndTime.dateRepresentation() != startDateAndTimePickerCell.dateAndTime.dateRepresentation()
            || oldStartDateAndTime.timeRepresentation() != startDateAndTimePickerCell.dateAndTime.timeRepresentation()
            || oldEndDateAndTime.dateRepresentation() != endDateAndTimePickerCell.dateAndTime.dateRepresentation()
            || oldEndDateAndTime.timeRepresentation() != endDateAndTimePickerCell.dateAndTime.timeRepresentation()
            || oldDescription != descriptionCell.textView.content
    }
    
    private var defaultStartDate: Date = EventEditViewController.defaultStartDate
    private var defaultEndDate: Date = EventEditViewController.defaultEndDate
    
    private var isDateSelectable: Bool!
    
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
    
    func updateValues(
        task: Task? = nil,
        delegate: HomeViewController,
        defaultStartDate: Date? = nil, defaultEndDate: Date? = nil,
        isDateSelectable: Bool = true
    ) {
        self.task = task
        self.delegate = delegate
        
        self.defaultStartDate = defaultStartDate ?? self.defaultStartDate
        self.defaultEndDate = defaultEndDate ?? self.defaultEndDate
        
        self.isDateSelectable = isDateSelectable
    }
}

extension EventEditViewController {
    
    // MARK: - Utils
    
    // http://swiftdeveloperblog.com/uialertcontroller-confirmation-dialog-swift/
    private func displayInvalidDateIntervalWarning() {
        let invalidDateIntervalAlert = UIAlertController(
            title: "Invalid Date Interval",
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
            title: "Discarding Edits",
            message: "Changes may be made.\nAre you sure you want to discard your changes?",
            preferredStyle: .actionSheet
        )
        
        let discardChangesButton = UIAlertAction(
            title: "Discarding Changes",
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
    
    private func displayStartAfterCurrentWarning(completion: @escaping (_ isOk: Bool) -> Void) {
        let startBeforeCurrentAlert = UIAlertController(
            title: "Starting before Current",
            message: "The event starts before current, is it Ok?",
            preferredStyle: .actionSheet
        )
        
        let isOkButton = UIAlertAction(
            title: "Yes",
            style: .default,
            handler: { (action) -> Void in
                completion(true)
        })
        
        let isNotOkButton = UIAlertAction(
            title: "No",
            style: .cancel
        ) { (action) -> Void in
            completion(false)
        }
        
        startBeforeCurrentAlert.addAction(isOkButton)
        startBeforeCurrentAlert.addAction(isNotOkButton)
        
        self.present(startBeforeCurrentAlert, animated: true, completion: nil)
    }
    
    private func displayDelayTasksWarning(conflictedTask: Task, completion: @escaping (_ shouldDelay: Bool) -> Void) {
        let delayTasksAlert = UIAlertController(
            title: "Date Interval Conflict",
            message: "The current date interval is conflicted with task:  \(conflictedTask.title)"
                + " (\(conflictedTask.timeReprsentation))."
                + " Should delay all subsequent tasks?",
            preferredStyle: .actionSheet
        )
        
        let shouldDelay = UIAlertAction(
            title: "Yes",
            style: .default,
            handler: { (action) -> Void in
                completion(true)
        })
        
        let shouldNotDelay = UIAlertAction(
            title: "No",
            style: .cancel
        ) { (action) -> Void in
            completion(false)
        }
        
        delayTasksAlert.addAction(shouldDelay)
        delayTasksAlert.addAction(shouldNotDelay)
        
        self.present(delayTasksAlert, animated: true, completion: nil)
    }
    
    func displayDateIntervalConflictWarning(conflictedTask: Task) {
        let dateIntervalConflictAlert = UIAlertController(
            title: "Date Interval Conflict",
            message: "The current date interval is conflicted with task:  \(conflictedTask.title)"
                + " (\(conflictedTask.timeReprsentation))",
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
    
    private func hideAllPickers() {
        startDateAndTimePickerCell.datePicker.isHidden = true
        startDateAndTimePickerCell.timePicker.isHidden = true
        endDateAndTimePickerCell.datePicker.isHidden = true
        endDateAndTimePickerCell.timePicker.isHidden = true
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
        configCellSeparators()
    }
    
    private func configCellSeparators() {
        if bothPickersInRowFourAreHidden {
            endDateAndTimeSelectionCell.resetSeparator()
        } else {
            endDateAndTimeSelectionCell.removeSeparator()
            endDateAndTimePickerCell.resetSeparator()
        }
    }
}

extension EventEditViewController {
    
    private func save(title: String, startDateAndTime: Date, endDateAndTime: Date, description: String) {
        let dateInterval = DateInterval(
            start: startDateAndTime,
            end: endDateAndTime
        )
        
        let newTask = Task(
            identifier: task?.identifier,
            title: title,
            dateInterval: dateInterval,
            description: description,
            isCompleted: task?.isCompleted ?? false
        )
        
//        if let conflictedTask = delegate.taskConflicted(with: newTask) {
//            if conflictedTask.dateInterval.start < newTask.dateInterval.start
//                && conflictedTask.dateInterval.end > newTask.dateInterval.start {
//                displayDateIntervalConflictWarning(conflictedTask: conflictedTask)
//                return
//            } else {
//                displayDelayTasksWarning(conflictedTask: conflictedTask) { (shouldDelay) in
//                    if shouldDelay {
//                        let secsToDelay = conflictedTask.dateInterval.start.distance(to: newTask.dateInterval.end)
//                        self.delegate.delay(tasksInTheSameDayAfter: newTask, for: secsToDelay)
//                    }
//
//                    if let task = self.task {
//                        self.delegate.replace(task, with: newTask)
//                    } else {
//                        self.delegate.add(newTask)
//                    }
//                    self.delegate.dismiss(animated: true, completion: nil)
//                }
//            }
//        } else {
//            if let task = task {
//                delegate.replace(task, with: newTask)
//            } else {
//                delegate.add(newTask)
//            }
//            delegate.dismiss(animated: true, completion: nil)
//        }
        
        if let conflictedTask = delegate.taskConflicted(with: newTask) {
            displayDateIntervalConflictWarning(conflictedTask: conflictedTask)
            return
        }
        
        if let task = task {
            delegate.replace(task, with: newTask)
        } else {
            delegate.add(newTask)
        }
        delegate.dismiss(animated: true, completion: nil)
    }
    
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
        
        if startDateAndTime + TimeInterval.Minute < Date()
            && task == nil {
            displayStartAfterCurrentWarning { (isOk) in
                if !isOk {
                    return
                } else {
                    self.save(
                        title: title,
                        startDateAndTime: startDateAndTime,
                        endDateAndTime: endDateAndTime,
                        description: description
                    )
                }
            }
        } else {
            self.save(
                title: title,
                startDateAndTime: startDateAndTime,
                endDateAndTime: endDateAndTime,
                description: description
            )
        }
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
            let dateAndTime = task?.dateInterval.start ?? defaultStartDate
            startDateAndTimeSelectionCell.updateDateAndTimeRepr(with: dateAndTime)
            startDateAndTimeSelectionCell.removeSeparator()
            return startDateAndTimeSelectionCell
        case 2:
            oldStartDateAndTime = task?.dateInterval.start ?? defaultStartDate
            
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
            let dateAndTime = task?.dateInterval.end ?? defaultEndDate
            endDateAndTimeSelectionCell.updateDateAndTimeRepr(with: dateAndTime)
            return endDateAndTimeSelectionCell
        case 4:
            oldEndDateAndTime = task?.dateInterval.end ?? defaultEndDate
            
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
            return bothPickersInRowTwoAreHidden
                ? 0
                : (
                    isDatePickerInRowTwoHidden
                        ? EventEditViewController.timePickerCellHeight
                        : EventEditViewController.datePickerCellHeight
            )
        } else {
            return bothPickersInRowFourAreHidden
                ? 0
                : (
                    isDatePickerInRowFourHidden
                        ? EventEditViewController.timePickerCellHeight
                        : EventEditViewController.datePickerCellHeight
            )
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        
        if row != 2 && row != 4 {
            return UITableView.automaticDimension
        } else if row == 2 {
            return bothPickersInRowTwoAreHidden
                ? 0
                : (
                    isDatePickerInRowTwoHidden
                        ? EventEditViewController.timePickerCellHeight
                        : EventEditViewController.datePickerCellHeight
            )
        } else {
            return bothPickersInRowFourAreHidden
                ? 0
                : (
                    isDatePickerInRowFourHidden
                        ? EventEditViewController.timePickerCellHeight
                        : EventEditViewController.datePickerCellHeight
            )
        }
    }
}

extension EventEditViewController: DateAndTimePickerDelegate {
    
    // MARK: - DateAndTimePicker Delegate
    
    private func validateStartDateAndTime() {
        guard endDateAndTimePickerCell != nil else {
            return
        }
        
        let startDateAndTime = startDateAndTimePickerCell.dateAndTime
        let endDateAndTime = endDateAndTimePickerCell.dateAndTime
        if startDateAndTime >  endDateAndTime {
            var newEndDateAndTime = startDateAndTime + 40 * TimeInterval.Minute
            if !isDateSelectable && !Calendar.current.isDate(newEndDateAndTime, inSameDayAs: startDateAndTime) {
                newEndDateAndTime = Calendar.current.date(
                    bySettingHour: 23,
                    minute: 55,
                    second: 59,
                    of: startDateAndTime
                    )!
            }
            
            endDateAndTimePickerCell.dateAndTime = newEndDateAndTime
            endDateAndTimeSelectionCell.updateDateAndTimeRepr(with: newEndDateAndTime)
        }
        
        validateEndDateAndTime()
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
    // https://stackoverflow.com/questions/58583806/textview-capitalizes-first-two-characters-instead-of-one
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let textView = textView as? TextViewWithPlaceHolder else {
            return true
        }
        
        if text.isEmpty {  // Deletion.
            let updatedText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            if updatedText.isEmpty {  // All chrs are deleted.
                textView.content = ""  // Shows the placeholder.
            }
        } else {  // Insertion.
            if textView.isShowingPlaceHolder {
                textView.content = text  // Hides the placeholder.
            }
        }
        return true
    }
    
    // Ensures that always the left of the placeholders are selected.
    func textViewDidChangeSelection(_ textView: UITextView) {
        guard let textView = textView as? TextViewWithPlaceHolder else {
            return
        }
        
        if textView.isShowingPlaceHolder {
            textView.selectBeginning()
        }
    }
    
    // Ensures that always the left of the placeholders are selected.
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        hideAllPickers()
        
        guard let textView = textView as? TextViewWithPlaceHolder else {
            return true
        }
        
        if textView.isShowingPlaceHolder {
            textView.selectBeginning()
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
        // Without the two lines of code below,
        // the keyboard will be displayed when
        // one of the pickers are tapped.
        titleCell.textView.resignFirstResponder()
        descriptionCell.textView.resignFirstResponder()
        
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
        
        configCellSeparators()
    }
    
    // MARK: - DateAndTimeSelectionCell Delegate
    
    internal func toggleDatePickerVisibility(inRow row: Int) {
        guard isDateSelectable else {
            return
        }
        
        togglePickersVisibility(in: row, shouldToggleDatePicker: true, shouldToggleTimePicker: false)
    }
    
    internal func toggleTimePickerVisibility(inRow row: Int) {
        togglePickersVisibility(in: row, shouldToggleDatePicker: false, shouldToggleTimePicker: true)
    }
}

protocol EventEditViewControllerDelegate {
        
    func add(_ task: Task)
    func replace(_ oldTask: Task, with newTask: Task)
    
    func taskConflicted(with newTask: Task) -> Task?
//    func delay(tasksInTheSameDayAfter task: Task, for secsToDelay: TimeInterval)
}

extension EventEditViewController {
    static let cellHeight: CGFloat = 60
    static let datePickerCellHeight: CGFloat = 250
    static let timePickerCellHeight: CGFloat = 200
    
    static var defaultStartDate: Date {
        Date()
    }
    static var defaultEndDate: Date {
        EventEditViewController.defaultStartDate + 40 * TimeInterval.Minute
    }
    
    static let eventTextViewCellReusableIdentifier = "EventTextViewCell"
    static let dateAndTimeSelectionCellReuseIdentifier = "DateAndTimeSelectionCell"
    static let dateAndTimePickerCellReuseIdentifier = "DateAndTimePickerCell"
    
    static let titlePlaceHolder = "Add title"
    static let descriptionPlaceHolder = "Add description"
}
