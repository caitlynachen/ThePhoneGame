//
//  CustomButton.swift
//  HandsOff
//
//  Created by Alex Blanchard on 12/30/17.
//  Copyright © 2017 Alex Blanchard. All rights reserved.
//

import Foundation
import UIKit

// A custom class allowing uniformity of all buttons that inherit from it. This saves development time when changes are made
class CustomButton: UIButton {
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.white.cgColor

        self.layer.cornerRadius = 15.0
        
        self.titleLabel?.textColor = UIColor.white
        self.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 18.0)
        
        self.clipsToBounds = true
        self.reversesTitleShadowWhenHighlighted = true
        
    }
}
