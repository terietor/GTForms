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
import SnapKit

private class DatePreviewView<L: UILabel>: ControlLabelView<L>  {

    override var formAxis: FormAxis {
        didSet { configureUI() }
    }

    let displayLabel: UILabel = {
        let label = L()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        
        self.control = self.displayLabel
        configureUI()
    }

    private func configureUI() {
        configureView() { (label, control) in

            if self.formAxis == .horizontal {
                label.snp.remakeConstraints() { make in
                    make.left.equalTo(self)
                    make.width.equalTo(self).multipliedBy(0.3)
                    make.top.equalTo(self)
                    make.bottom.equalTo(self)
                }// end label


                control.snp.remakeConstraints() { make in
                    make.leading.equalTo(label.snp.trailing).offset(10)
                    make.trailing.equalTo(self)
                    make.top.equalTo(self)
                    make.bottom.equalTo(self)
                } // end control
            } else {
                label.snp.remakeConstraints() { make in
                    make.top.equalTo(self)
                    make.leading.equalTo(self).offset(10)
                    make.trailing.equalTo(self).offset(-10)
                }

                control.snp.remakeConstraints() { make in
                    make.top.equalTo(label.snp.bottom).offset(10)
                    make.bottom.equalTo(self)
                    make.leading.equalTo(self).offset(10)
                    make.trailing.equalTo(self).offset(-10)
                }
            }
        } // end configureView
    }
}

protocol FormDatePickerType: class {
    var shouldExpand: Bool? { get set }
    var datePicker: UIDatePicker { get }
}

public class FormDatePicker<L: UILabel>: BaseResultForm<Date> {

    public var formAxis: FormAxis = .horizontal {
        didSet {self.datePreviewView.formAxis = self.formAxis }
    }

    lazy private(set) var datePickerView: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.addTarget(
            self,
            action: #selector(changeDisplayedDate),
            for: .valueChanged
        )

        return datePicker
    }()

    private let datePreviewView = DatePreviewView<L>()
    
    var shouldExpand: Bool?

    /**
        The UIDatePicker of the form
     */
    public var datePicker: UIDatePicker {
        return self.datePickerView
    }
    
    /**
        The text label of form
     */
    public var textLabel: UILabel {
        return self.datePreviewView.controlLabel
    }
    
    /**
        The date label of form
     */
    public var dateLabel: UILabel {
        return self.datePreviewView.displayLabel
    }
    
    /**
        The dateFormatter will be used for the
        date label
     */
    public var dateFormatter: DateFormatter? {
        didSet { changeDisplayedDate() }
    }
    
    public init(text: String) {
        super.init()
        
        self.text = text
        self.datePreviewView.controlLabel.text = self.text

        changeDisplayedDate()
    }
    
    public override func formView() -> UIView {
        return self.datePreviewView
    }

    @objc private func changeDisplayedDate() {
        let date = self.datePicker.date

        defer { self.updateResult(date) }

        if let dateFormatter = self.dateFormatter {
            self.datePreviewView.displayLabel.text =
                dateFormatter.string(from: date)
            return
        }

        self.datePreviewView.displayLabel.text = String(describing: date)
    }
}

extension FormDatePicker: FormDatePickerType {}
