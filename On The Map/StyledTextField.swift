//
//  StyledTextField.swift
//  On The Map
//
//  Created by Josh on 11/23/15.
//  Copyright © 2015 Josh Nerius. All rights reserved.
//

import UIKit

class StyledTextField: UITextField {
    let inset: CGFloat = 8
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, inset, inset)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return textRectForBounds(bounds)
    }
}