//
//  EventEditViewController.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit
import JTAppleCalendar

class EventEditViewController: UITableViewController {
    
    private var titleCell: EventTextViewCell!
    private var typeCell: TypeCell!
    private var startSelectionCell: SelectionCell!
    private var startPickerCell: PickerCell!
    private var endSelectionCell: SelectionCell!
    private var endPickerCell: PickerCell!
    private var alarmCell: AlarmCell!
    private var locationCell: EventTextViewCell!
    private var descriptionCell: EventTextViewCell!
    
    private var oldTitle: String!
    private var oldType: Task.Type_!
    private var oldStart: Date!
    private var oldEnd: Date!
    private var oldHasAlarm: Bool!
    private var oldLocation: String!
    private var oldDescription: String!
    private var isContentChanged: Bool {
        return oldTitle != titleCell.textView.content
            || oldType != typeCell.type
            || oldStart.dateRepresentation() != startPickerCell.dateAndTime.dateRepresentation()
            || oldStart.timeRepresentation() != startPickerCell.dateAndTime.timeRepresentation()
            || oldEnd.dateRepresentation() != endPickerCell.dateAndTime.dateRepresentation()
            || oldEnd.timeRepresentation() != endPickerCell.dateAndTime.timeRepresentation()
            || oldHasAlarm != alarmCell.alarmSwitch.isOn
            || oldLocation != locationCell.textView.content
            || oldDescription != descriptionCell.textView.content
    }
    
    private var isDatePickerInRowTwoHidden: Bool {
        return startPickerCell?.leftPicker.isHidden ?? true
    }
    private var isTimePickerInRowTwoHidden: Bool {
        return startPickerCell?.timePicker.isHidden ?? true
    }
    
    private var isDatePickerInRowFourHidden: Bool {
        return endPickerCell?.leftPicker.isHidden ?? true
    }
    private var isTimePickerInRowFourHidden: Bool {
        return endPickerCell?.timePicker.isHidden ?? true
    }
    
    private var defaultStartDate: Date = EventEditViewController.defaultStartDate
    private var defaultEndDate: Date = EventEditViewController.defaultEndDate
    
    private var isDateSelectable: Bool!
        
    private var shouldDisplayStart: Bool! {  // Controls whether the startDateAndTime* should be displayed.
        guard let typeCell = typeCell else {
            return false
        }
        return typeCell.type == .event
    }
    private var shouldDisplayEnd: Bool! {  // Controls whether the endDateAndTime* should be displayed.
        guard let typeCell = typeCell else {
            return false
        }
        return typeCell.type != .anytime
    }
    
    private var isTimetableMode: Bool!
    
    // MARK: - Models
    
    private var task: Task?
    
    // MARK: - Controllers
    
    private var delegate: HomeTimetableDelegate!
        
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(
            EventTextViewCell.classForCoder(),
            forCellReuseIdentifier: EventEditViewController.eventTextViewCellReusableIdentifier
        )
        tableView.register(
            SelectionCell.classForCoder(),
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
            image: UIImage(imageLiteralResourceName: "cancel"),
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(imageLiteralResourceName: "done"),
            style: .done,
            target: self,
            action: #selector(saveButtonTapped)
        )
        
        tableView.tableFooterView = UIView()
    }
    
    func updateLayouts() {
    }
    
    func updateValues(
        task: Task? = nil,
        delegate: HomeTimetableDelegate,
        defaultStartDate: Date? = nil, defaultEndDate: Date? = nil,
        isDateSelectable: Bool = true, isTimetableMode: Bool = false
    ) {
        self.task = task
        self.delegate = delegate
        
        self.defaultStartDate = defaultStartDate ?? self.defaultStartDate
        self.defaultEndDate = defaultEndDate ?? self.defaultEndDate
        
        self.isDateSelectable = isDateSelectable
        self.isTimetableMode = isTimetableMode
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
    
    private func displayStartAndEndDateNotInSameDayWarning() {
        let alert = UIAlertController(
            title: "Invalid Date Interval",
            message: "The event start time is not in the same day as the event end time, which is currently not supported.",
            preferredStyle: .alert
        )
        
        let okButton = UIAlertAction(
            title: "OK",
            style: .default,
            handler: { (action) -> Void in
                return
        })
        
        alert.addAction(okButton)
        
        self.present(alert, animated: true, completion: nil)
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
    
    private func displayStartBeforeCurrentWarning(completion: @escaping (_ isOk: Bool) -> Void) {
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
            message: "The current date interval conflicts with task:  \(conflictedTask.title)"
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
        startPickerCell.leftPicker.isHidden = true
        startPickerCell.timePicker.isHidden = true
        endPickerCell.leftPicker.isHidden = true
        endPickerCell.timePicker.isHidden = true
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

extension EventEditViewController {
    
    private func save(
        title: String,
        type: Task.Type_,
        startDateAndTime: Date, 
        endDateAndTime: Date,
        hasAlarm: Bool,
        location: String,
        description: String
    ) {
                
        let newTask = Task(
            identifier: task?.identifier,
            title: title,
            type: type,
            dateInterval: DateInterval(
                start: startDateAndTime,
                end: endDateAndTime
            ),
            hasAlarm: hasAlarm,
            location: location,
            description: description,
            isCompleted: task?.isCompleted ?? false,
            isTimetableTask: isTimetableMode
        )
        
        if let conflictedTask = delegate.taskConflicted(with: newTask) {
            displayDateIntervalConflictWarning(conflictedTask: conflictedTask)
            return
        }
        
        if let task = task {
            delegate.replace(
                task,
                with: newTask
            )
        } else {
            delegate.add(newTask)
        }
        delegate.dismiss(
            animated: true,
            completion: nil
        )
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
    
    @objc private func saveButtonTapped() {
        let title = titleCell.textView.content
        let type = typeCell.type!
        var startDateAndTime = startPickerCell.dateAndTime
        var endDateAndTime = endPickerCell.dateAndTime
        let hasAlarm = alarmCell.alarmSwitch.isOn
        let location = locationCell.textView.content
        let description = descriptionCell.textView.content
        
        if type == .anytime {
            startDateAndTime = Calendar.current.date(
                bySettingHour: 0,
                minute: 0,
                second: 0,
                of: startDateAndTime
            )!
            endDateAndTime = Calendar.current.date(
                bySettingHour: 23,
                minute: 55,
                second: 59,
                of: endDateAndTime
            )!
        }
        
        if startDateAndTime > endDateAndTime {
            displayInvalidDateIntervalWarning()
            return
        }
        // TODO: - Tmp solution.
        if !Calendar.current.isDate(startDateAndTime, inSameDayAs: endDateAndTime) {
            displayStartAndEndDateNotInSameDayWarning()
            return
        }
        
        if startDateAndTime + TimeInterval.Minute < Date()
            && task == nil
            && !isTimetableMode
            && type != .anytime {
            displayStartBeforeCurrentWarning { (isOk) in
                if !isOk {
                    return
                }
                self.save(
                    title: title,
                    type: type,
                    startDateAndTime: startDateAndTime,
                    endDateAndTime: endDateAndTime,
                    hasAlarm: hasAlarm,
                    location: location,
                    description: description
                )
            }
        } else {
            self.save(
                title: title,
                type: type,
                startDateAndTime: startDateAndTime,
                endDateAndTime: endDateAndTime,
                hasAlarm: hasAlarm,
                location: location,
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
        9
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        switch row {
        case EventEditViewController.titleCellIndex:
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
        case EventEditViewController.typeCellIndex:
            oldType = task?.type ?? .event
            
            typeCell = TypeCell()
            typeCell.updateValues(
                iconName: "time",
                type: oldType,
                delegate: self,
                shouldDisplayAccessory: !isTimetableMode
            )
            typeCell.removeSeparator()
            return typeCell
        case EventEditViewController.startDateAndTimeSelectionCellIndex:
            startSelectionCell = SelectionCell()
            startSelectionCell.updateValues(
                iconName: nil,
                delegate: self,
                targetPickerRow: row + 1
            )
            let dateAndTime = task?.dateInterval.start ?? defaultStartDate
            startSelectionCell.updateDateAndTimeRepr(with: dateAndTime, displayWeek: isTimetableMode)
            startSelectionCell.removeSeparator()
            return startSelectionCell
        case EventEditViewController.startDateAndTimePickerCellIndex:
            oldStart = task?.dateInterval.start ?? defaultStartDate
            
            startPickerCell = isTimetableMode
                ? WeekdayAndTimePickerCell()
                : DateAndTimePickerCell()
            startPickerCell.updateValues(
                targetSelectionRow: row - 1,
                delegate: self,
                dateAndTime: oldStart
            )
            startPickerCell.removeSeparator()
            return startPickerCell
        case EventEditViewController.endDateAndTimeSelectionCellIndex:
            endSelectionCell = SelectionCell()
            endSelectionCell.updateValues(
                iconName: nil,
                delegate: self,
                targetPickerRow: row + 1
            )
            let dateAndTime = task?.dateInterval.end ?? defaultEndDate
            endSelectionCell.updateDateAndTimeRepr(with: dateAndTime, displayWeek: isTimetableMode)
            endSelectionCell.removeSeparator()
            return endSelectionCell
        case EventEditViewController.endDateAndTimePickerCellIndex:
            oldEnd = task?.dateInterval.end ?? defaultEndDate
            
            endPickerCell = isTimetableMode
                ? WeekdayAndTimePickerCell()
                : DateAndTimePickerCell()
            endPickerCell.updateValues(
                targetSelectionRow: row - 1,
                delegate: self,
                dateAndTime: oldEnd
            )
            endPickerCell.removeSeparator()
            return endPickerCell
        case EventEditViewController.alarmCellIndex:
            oldHasAlarm = task?.hasAlarm ?? false
            
            alarmCell = AlarmCell()
            alarmCell.updateValues(
                iconName: "alarm",
                hasAlarm: oldHasAlarm,
                delegate: self
            )
            return alarmCell
        case EventEditViewController.locationCellIndex:
            oldLocation = task?.location ?? ""
            
            locationCell = EventTextViewCell()
            locationCell.updateValues(
                iconName: "location",
                placeHolder: EventEditViewController.locationPlaceHolder,
                text: oldLocation,
                delegate: self
            )
            return locationCell
        case EventEditViewController.descriptionCellIndex:
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row

        if row == EventEditViewController.typeCellIndex {
            if let isTimetableMode = isTimetableMode {
                typeCell.isHidden = isTimetableMode
                if isTimetableMode {
                    return 0
                }
            }
        }
        
        if row == EventEditViewController.startDateAndTimeSelectionCellIndex
            || row == EventEditViewController.startDateAndTimePickerCellIndex {
            if shouldDisplayStart {
                startSelectionCell?.isHidden = false
                startPickerCell?.isHidden = false
                
                if row == EventEditViewController.startDateAndTimePickerCellIndex {
                    if isDatePickerInRowTwoHidden
                        && isTimePickerInRowTwoHidden {
                        return 0
                    } else if isDatePickerInRowTwoHidden {
                        return EventEditViewController.timePickerCellHeight
                    } else if isTimePickerInRowTwoHidden {
                        if !isTimetableMode {
                            return EventEditViewController.datePickerCellHeight
                        } else {
                            return EventEditViewController.weekdayPickerCellHeight
                        }
                    }
                }
            } else {
                startSelectionCell?.isHidden = true
                startPickerCell?.isHidden = true
                
                return 0
            }
        }
        
        if row == EventEditViewController.endDateAndTimeSelectionCellIndex
            || row == EventEditViewController.endDateAndTimePickerCellIndex {
            if shouldDisplayEnd {
                endSelectionCell?.isHidden = false
                endPickerCell?.isHidden = false
                
                if row == EventEditViewController.endDateAndTimePickerCellIndex {
                   if isDatePickerInRowFourHidden
                       && isTimePickerInRowFourHidden {
                       return 0
                   } else if isDatePickerInRowFourHidden {
                       return EventEditViewController.timePickerCellHeight
                   } else if isTimePickerInRowFourHidden {
                       if !isTimetableMode {
                           return EventEditViewController.datePickerCellHeight
                       } else {
                           return EventEditViewController.weekdayPickerCellHeight
                       }
                   }
               }
            } else {
                endSelectionCell?.isHidden = true
                endPickerCell?.isHidden = true
                
                return 0
            }
        }
                
        return UITableView.automaticDimension
    }
}

extension EventEditViewController: PickerDelegate {
        
    private func validateStartDateAndTime() {
        guard endPickerCell != nil else {
            return
        }
        
        let startDateAndTime = startPickerCell.dateAndTime
        let endDateAndTime = endPickerCell.dateAndTime
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
            
            endPickerCell.dateAndTime = newEndDateAndTime
            endSelectionCell.updateDateAndTimeRepr(with: newEndDateAndTime, displayWeek: isTimetableMode)
        }
        
        validateEndDateAndTime()
    }
    
    private func validateEndDateAndTime() {
        if startPickerCell.dateAndTime <= endPickerCell.dateAndTime {
            endSelectionCell.isDateValid = true
        } else {
            endSelectionCell.isDateValid = false
        }
    }
    
    // MARK: - Picker Delegate
    
    internal func updateDateAndTime(ofCellInRow row: Int, with newDateAndTime: Date) {
        
        // Handles the start if it is hidden.
        if !shouldDisplayStart {
            if !isTimetableMode {
                (startPickerCell.leftPicker as! JTACMonthView).selectDates(
                    [newDateAndTime],
                    triggerSelectionDelegate: false,  // Important. If set to true, it will result in recursion.
                    keepSelectionIfMultiSelectionAllowed: false
                )
            }
            
            startPickerCell.timePicker.date = newDateAndTime
            
            startSelectionCell.updateDateAndTimeRepr(
                with: newDateAndTime,
                displayWeek: isTimetableMode
            )
            validateStartDateAndTime()
        }
        
        // Handles the end if it is hidden.
        if !shouldDisplayEnd
            && endSelectionCell != nil
            && endPickerCell != nil
        {
            if !isTimetableMode {
                (endPickerCell.leftPicker as! JTACMonthView).selectDates(
                    [newDateAndTime],
                    triggerSelectionDelegate: false,
                    keepSelectionIfMultiSelectionAllowed: false
                )
            }
            
            endPickerCell.timePicker.date = newDateAndTime
            
            endSelectionCell.updateDateAndTimeRepr(
                with: newDateAndTime,
                displayWeek: isTimetableMode
            )
            validateEndDateAndTime()
        }
        
        if row == EventEditViewController.startDateAndTimeSelectionCellIndex {
            startSelectionCell.updateDateAndTimeRepr(
                with: newDateAndTime,
                displayWeek: isTimetableMode
            )
            validateStartDateAndTime()
        } else if row == EventEditViewController.endDateAndTimeSelectionCellIndex {
            endSelectionCell.updateDateAndTimeRepr(
                with: newDateAndTime,
                displayWeek: isTimetableMode
            )
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
        
    private func currentPickerCellOf(_ row: Int) -> PickerCell {
        return row == EventEditViewController.startDateAndTimePickerCellIndex
            ? startPickerCell
            : endPickerCell
    }
    
    private func theOtherPickerCellOf(_ row: Int) -> PickerCell {
        return row == EventEditViewController.startDateAndTimePickerCellIndex
            ? endPickerCell
            : startPickerCell
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
            currentPickerCell.leftPicker.isHidden.toggle()
            currentPickerCell.timePicker.isHidden = true
        } else {
            currentPickerCell.timePicker.isHidden.toggle()
            currentPickerCell.leftPicker.isHidden = true
        }
        
        theOtherPickerCell.leftPicker.isHidden = true
        theOtherPickerCell.timePicker.isHidden = true
        
        tableView.beginUpdates()
        tableView.endUpdates()
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

extension EventEditViewController {
    static let titleCellIndex: Int = 0
    static let typeCellIndex: Int = 1
    static let startDateAndTimeSelectionCellIndex: Int = 2
    static let startDateAndTimePickerCellIndex: Int = 3
    static let endDateAndTimeSelectionCellIndex: Int = 4
    static let endDateAndTimePickerCellIndex: Int = 5
    static let alarmCellIndex: Int = 6
    static let locationCellIndex: Int = 7
    static let descriptionCellIndex: Int = 8
    
    static let cellHeight: CGFloat = 60
    static let datePickerCellHeight: CGFloat = 250
    static let weekdayPickerCellHeight: CGFloat = 150
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
    
    static let titlePlaceHolder = "Title"
    static let locationPlaceHolder = "Location"
    static let descriptionPlaceHolder = "Description"
}
