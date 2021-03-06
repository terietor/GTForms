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
import GTForms

class MainTableViewController: FormTableViewController {
    fileprivate lazy var formButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "Forms",
            style: .done,
            target: self,
            action: #selector(didTapFormButton)
        )
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.formButton

        let section = FormSection()
        section.addRow(StaticForm(text: "Forms")).didSelectRow = {
            self.performSegue(withIdentifier: "showForms", sender: self)
        }

        section.addRow(StaticForm(text: "Selection Form")).didSelectRow = {
            self.performSegue(withIdentifier: "showSelectionForm", sender: self)
        }

        section.addRow(StaticForm(text: "Date Pickers")).didSelectRow = {
            self.performSegue(withIdentifier: "showDatePickers", sender: self)
        }

        section.addRow(StaticForm(text: "Test Keyboard")).didSelectRow = {
            self.performSegue(withIdentifier: "showTestKeyboard", sender: self)
        }

        let originalText = NSMutableAttributedString(string: "Text with ")

        let text =  NSAttributedString(
            string: "Color",
            attributes: [NSForegroundColorAttributeName: UIColor.green]
        )

        originalText.append(text)

        section.addRow(AttributedStaticForm(text: originalText))
        section.addRow(StaticForm(text: "Custom Form")).didSelectRow = {
            self.performSegue(withIdentifier: "showCustomForm", sender: self)
        }

        section.addRow(StaticForm(text: "TableView")).didSelectRow = {
            self.performSegue(withIdentifier: "showTableView", sender: self)
        }


        section.addRow(StaticForm(text: "TextField Errors")).didSelectRow = {
            self.performSegue(withIdentifier: "showTextFieldErrors", sender: self)
        }

        self.formSections.append(section)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "showFormsModally" {
            return
        }

        guard let
            nv = segue.destination as? UINavigationController,
            let vc = nv.topViewController as? FormsVC
        else {
            return
        }

        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(didTapCancelButton)
        )
    }

    @objc fileprivate func didTapFormButton() {
        self.performSegue(withIdentifier: "showFormsModally", sender: self)
    }

    @objc fileprivate func didTapCancelButton() {
        dismiss(animated: true, completion: nil)
    }
}
