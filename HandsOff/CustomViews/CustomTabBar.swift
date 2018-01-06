//
//  CustomTabBar.swift
//  HandsOff
//
//  Created by Alex Blanchard on 12/26/17.
//  Copyright © 2017 Alex Blanchard. All rights reserved.
//

import Foundation
import UIKit

// This class builds our tab bar and gives it a unique style
class CustomTabBar: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeTabBarAppearance()
    }
    
    func customizeTabBarAppearance() {
        customizeTabBarSelectionAppearance()
        createCustomTabBarSeperator()
    }
    
    func customizeTabBarSelectionAppearance() {
        let attrsNormal = [
            NSAttributedStringKey.foregroundColor: UIColor.lightGray,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15.0)
        ]
        
        let attrsSelected = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15.0)
        ]
        
        UITabBarItem.appearance().setTitleTextAttributes(attrsNormal, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(attrsSelected, for: .selected)
    }
    
    func createCustomTabBarSeperator() {
        if let items = self.tabBar.items {
            
            let height = self.tabBar.bounds.height
            let numItems = CGFloat(items.count)
            let itemSize = CGSize(width: tabBar.frame.width / numItems, height: tabBar.frame.height)
            
            for (index, _) in items.enumerated() {
                if index > 0 {
                    let xPosition = itemSize.width * CGFloat(index)
                    let separator = createCustomSizeSeparator(x: xPosition, y: 0, width: 0.5, height: height)
                    separator.backgroundColor = UIColor.lightGray
                    tabBar.insertSubview(separator, at: 1)
                }
            }
        }
    }
    
    func createCustomSizeSeparator(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> UIView {
        return UIView(frame: CGRect( x: x, y: y, width: width, height: height))
    }
}
