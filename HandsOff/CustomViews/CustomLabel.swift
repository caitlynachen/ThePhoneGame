//
//  CustomLabel.swift
//  HandsOff
//
//  Created by Alex Blanchard on 12/30/17.
//  Copyright © 2017 Alex Blanchard. All rights reserved.
//

import Foundation
import UIKit

// A custom class allowing uniformity of all labels that inherit from it. This saves development time when changes are made
class CustomLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.textColor = UIColor.white
        self.font = UIFont(name: "Academy Engraved LET", size: 50)
    }
}
