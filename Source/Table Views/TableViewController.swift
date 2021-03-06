// Copyright (c) 2015-2016 Giorgos Tsiapaliokas <giorgos.tsiapaliokas@mykolab.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

protocol TableViewType: class {
    var formSections: [FormSection] { get set }
    var tableView: UITableView! { get }
}

class TableViewController: NSObject, UITableViewDataSource, UITableViewDelegate {
    private var datePickerHelper = DatePickerHelper()
    fileprivate var textFieldViews = [TextFieldViewType]()

    private let tableViewType: TableViewType
    private var viewController: UIViewController?

    private var tableView: UITableView {
        return self.tableViewType.tableView
    }

    init(tableViewType: TableViewType) {
        self.tableViewType = tableViewType

        super.init()
        commonInit()
    }

    init(tableViewType: TableViewType, viewController: UIViewController) {
        self.tableViewType = tableViewType
        self.viewController = viewController

        super.init()

        commonInit()
    }

    var formSections: [FormSection] = [FormSection]() {
        didSet {
            findTextFieldViews()
            self.tableView.reloadData()
            self.formSections.forEach() {
                $0.tableViewType = self.tableViewType
            }
        }
    }

    func registerCustomForm(_ customForm: CustomForm) {
        self.tableView.register(
            customForm.cellClass,
            forCellReuseIdentifier: customForm.reuseIdentifier
        )
    }

    func registerNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
    }

    func unRegisterNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.formSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.formSections[section].formItemsForSection().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        let cellItem = self.formSections[(indexPath as NSIndexPath).section].formItemsForSection()[(indexPath as NSIndexPath).row]

        if let selectionItem = cellItem as? BaseSelectionFormItem {
            cell = tableView.dequeueReusableCell(
                withIdentifier: selectionItem.cellReuseIdentifier,
                for: indexPath
            )

            cell.selectionStyle = .none
            if let selectionItem = selectionItem as? SelectionFormItem {
                cell.textLabel?.text = selectionItem.text
                cell.detailTextLabel?.text = selectionItem.detailText
                cell.accessoryType = selectionItem.selected ? selectionItem.accessoryType : .none
            } else if let
                selectionItem = selectionItem as? SelectionCustomizedFormItem,
                let cell = cell as? SelectionCustomizedFormItemCell
            {
                cell.configure(
                    selectionItem.text,
                    detailText: selectionItem.detailText,
                    isSelected: selectionItem.selected
                )
            }
            return cell
        } else if let datePicker = cellItem as? UIDatePicker {
            guard let
                datePickerCell = tableView.dequeueReusableCell(
                    withIdentifier: "DatePickerCell",
                    for: indexPath
                ) as? DatePickerTableViewCell
            else { return UITableViewCell() }

            datePickerCell.datePicker = datePicker
            return datePickerCell
        }

        guard let cellRow = cellItem as? FormRow else { return UITableViewCell() }

        if let customForm = cellRow.form as? CustomForm {
            let cell = tableView.dequeueReusableCell(withIdentifier: customForm.reuseIdentifier, for: indexPath)
            customForm.configureCell(cell)
            return cell
        } else if let staticForm = cellRow.form as? StaticForm {
            cell = tableView.dequeueReusableCell(withIdentifier: "ReadOnlyCell", for: indexPath)
            cell.textLabel?.text = staticForm.text
            cell.detailTextLabel?.text = staticForm.detailText
        } else if let staticForm = cellRow.form as? AttributedStaticForm {
            cell = tableView.dequeueReusableCell(withIdentifier: "AttributedReadOnlyCell", for: indexPath)
            cell.textLabel?.attributedText = staticForm.text
            cell.detailTextLabel?.attributedText = staticForm.detailText
        } else if let selectionForm = cellRow.form as? BaseSelectionForm {
            cell = tableView.dequeueReusableCell(withIdentifier: selectionForm.cellReuseIdentifier, for: indexPath)

            if let selectionForm = selectionForm as? SelectionForm {
                cell.textLabel?.text = selectionForm.text
                cell.detailTextLabel?.text = selectionForm.detailText

                if let textColor = selectionForm.textColor {
                    cell.textLabel?.textColor = textColor
                }

                if let textFont = selectionForm.textFont {
                    cell.textLabel?.font = textFont
                }

                if let detailTextColor = selectionForm.detailTextColor {
                    cell.detailTextLabel?.textColor = detailTextColor
                }

                if let detailTextFont = selectionForm.detailTextFont {
                    cell.textLabel?.font = detailTextFont
                }
            } else if let
                item = selectionForm as? SelectionCustomizedForm,
                let cell = cell as? SelectionCustomizedFormCell
            {
                cell.configure(item.text, detailText: item.detailText)
            }
            cell.selectionStyle = .none
        } else {
            let formCell: FormTableViewCell

            if let
                f = cellRow.form as? FormViewableType,
                let cellIdentifier = f.customCellIdentifier
            {
                formCell = tableView.dequeueReusableCell(
                    withIdentifier: cellIdentifier, for: indexPath
                ) as! FormTableViewCell
            } else {
                formCell = BaseFormTableViewCell()
            }
            
            if let formViewableCell = cellRow.form as? FormViewableType {
                formViewableCell.viewController = self.viewController
            }

            formCell.formRow = cellRow
            cell = formCell
        }

        cell.accessoryType = cellRow.accessoryType
        cell.selectionStyle = .none

        return cell
    }

    // MARK: tableview

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellItems = self.formSections[(indexPath as NSIndexPath).section].formItemsForSection()

        SelectionFormHelper.handleAccessory(
            cellItems,
            tableView: self.tableView,
            indexPath: indexPath
        )

        guard let formRow = cellItems[(indexPath as NSIndexPath).row] as? FormRow else { return }
        formRow.didSelectRow?()

        SelectionFormHelper.toggleItems(
            formRow,
            tableView: self.tableView,
            indexPath: indexPath
        )

        guard let
            datePickerForm = formRow.form as? FormDatePickerType
            else { return }
        self.datePickerHelper.currentSelectedDatePickerForm = datePickerForm

        self.datePickerHelper.removeAllDatePickers(self.tableViewType)

        hideKeyboard()

        self.datePickerHelper.showDatePicker(
            self.tableView,
            cellItems: self.formSections[(indexPath as NSIndexPath).section].formItemsForSection()
        )
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let cellItem = self.formSections[(indexPath as NSIndexPath).section].formItemsForSection()[(indexPath as NSIndexPath).row]

        if let _ = cellItem as? BaseSelectionFormItem {
            return true
        }

        guard let cellRow = cellItem as? FormRow
            else { return false }

        if let
            _ = cellRow.form as? StaticForm,
            let _ = cellRow.didSelectRow
        {
            return true
        } else if let
            _ = cellRow.form as? AttributedStaticForm,
            let _ = cellRow.didSelectRow
        {
            return true
        } else if let selectionForm = cellRow.form as? BaseSelectionForm
        {
            return !selectionForm.shouldAlwaysShowAllItems ? true : false
        } else if let _ = cellRow.form as? FormDatePickerType {
            return true
        }

        return false
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.formSections[section].title
    }

   func hideKeyboard() {
        self.textFieldViews.forEach() {
            if $0.textField.isFirstResponder {
                $0.textField.resignFirstResponder()
            }
        }
    }

    private func findTextFieldViews() {
        self.textFieldViews.removeAll()
        for section in self.formSections {
            for row in section.rows {
                if let form = row.form as? FormTextFieldViewType {
                    self.textFieldViews.append(form.textFieldViewType)
                }
            } // end for
        } // end for

        self.textFieldViews.forEach() { $0.delegate = self }
    }

    @objc private func keyboardWillAppear() {
        let datePicker = self.datePickerHelper.currentSelectedDatePickerForm
        self.datePickerHelper.currentSelectedDatePickerForm = nil

        self.datePickerHelper.removeAllDatePickers(self.tableViewType)
        self.datePickerHelper.currentSelectedDatePickerForm = datePicker
    }

    private func commonInit() {
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ReadOnlyCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AttributedReadOnlyCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SelectionCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SelectionItemCell")
        self.tableView.register(FormTableViewCell.self, forCellReuseIdentifier: "formCell")
        self.tableView.register(DatePickerTableViewCell.self, forCellReuseIdentifier: "DatePickerCell")
    }

}

extension TableViewController: TextFieldViewDelegate {
    func textFieldViewShouldReturn(_ textFieldView: TextFieldViewType) -> Bool {

        var index = -1
        for (i, it) in self.textFieldViews.enumerated() {
            if it === textFieldView {
                index = i
            }
        }

        if index == -1 {
            return false
        }
        
        if index + 1 >= self.textFieldViews.count {
            return false
        }
        
        let nextTextFieldView = self.textFieldViews[index + 1]
        return nextTextFieldView.textField.becomeFirstResponder()
    }
}
