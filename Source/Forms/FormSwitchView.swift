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

private class Switcher<S: UISwitch, L: UILabel>: ControlLabelView<L>  {
    
    private lazy private(set) var switcher: UISwitch = {
        let switcher = S()
        
        switcher.addTarget(
            self,
            action: #selector(switchValueDidChange),
            for: .valueChanged
        )
                
        return switcher
    }()
    
    var valueDidChange: ((Bool) -> ())?
    
    override init() {
        super.init()
        
        self.control = self.switcher
        
        configureView() { (label, control) in
            
            label.snp.makeConstraints() { make in
                make.left.equalTo(self)
                make.width.equalTo(self).multipliedBy(0.8)
                make.top.equalTo(self)
                make.bottom.equalTo(self)
            } // end label
            
            
            control.snp.makeConstraints() { make in
                make.right.equalTo(self)
                make.centerY.equalTo(label.snp.centerY)
            } // end control
            
        } // end configureView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func switchValueDidChange() {
        self.valueDidChange?(self.switcher.isEnabled)
    }
}


public class FormSwitch<S: UISwitch, L: UILabel>: BaseResultForm<Bool> {

    private let switcher = Switcher<S, L>()

    public init(text: String) {
        super.init()
        
        self.text = text

        self.switcher.controlLabel.text = self.text
        
        self.switcher.valueDidChange = { result in
            self.updateResult(result)
        }
    }
        
    public override func formView() -> UIView {
        return self.switcher
    }
    
}

